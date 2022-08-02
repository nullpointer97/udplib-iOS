//
//  WingsUDPClient.swift
//  udplib
//
//  Created by Ярослав Стрельников on 21.07.2022.
//

import Foundation
import UserNotifications
import UIKit

@_silgen_name("yudpsocket_get_server_ip") func c_yudpsocket_get_server_ip(_ host: UnsafePointer<Int8>, ip: UnsafePointer<Int8>) -> Int32

enum RequestTag: Int {
    case register = 0x561
    case status = 0x573
    
    static func tag(for value: Int) -> RequestTag {
        switch value {
        case 0x573: return .register
        default: return .register
        }
    }
}

public class WingsUDPClient: NSObject {
    public var address: String = "cloudless.wsoft.ru"
    public var port: UInt16 = 5001

    private var socket: SwiftAsyncUDPSocket!

    private var registerTimer: Timer?
    
    private var token: String
    
    private var registerTag = 0x561
    private var statusTag = 0x573
    
    private let center = NotificationCenter.default
    
    deinit {
        registerTimer?.invalidate()
        center.removeObserver(self)
    }

    public init(address: String = "cloudless.wsoft.ru", port: UInt16 = 5001, token: String) {
        self.token = token

        super.init()
        
        socket = SwiftAsyncUDPSocket(delegate: self, delegateQueue: .global(), socketQueue: .main)
        do {
            try socket.enableBroadcast(isEnable: true)
        } catch {
            print("UDP ⇨ \(error)")
        }
        socket.maxReceiveIPv4BufferSize = 2048
        socket.maxSendBufferSize = 2048
        socket.maxSendSizeStore = 2048
        socket.maxReceiveIPv6BufferSize = 2048
        socket.max4ReceiveSizeStore = 2048
        socket.max6ReceiveSizeStore = 2048

        let remoteipbuff: [Int8] = [Int8](repeating: 0x0, count: 16)
        let ret = c_yudpsocket_get_server_ip(address, ip: remoteipbuff)
        
        guard let ip = String(cString: remoteipbuff, encoding: .utf8), ret == 0 else {
            return
        }
        
        self.address = ip
        self.port = port
        
        center.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    static func generateToken() -> String {
        let letters = "0123456789"
        return "udp\(String((0..<14).map { _ in letters.randomElement()! } ))"
    }
    
    public func connect() {
        do {
            try socket.connect(to: address, port: port)
            
            registerTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                var bytes: [Byte] = []
                try? self.sendRegistration(to: &bytes)
            }
        } catch {
            print("UDP ⇨ \(error)")
        }
    }
    
    private func sendRegistration(to bytes: inout [Byte]) throws {
        let registerRequest = RegisterRequest(token: token)
        _ = try registerRequest.writeData(to: &bytes)
        
        send(to: &bytes, pdu: registerRequest, address: address, port: Int(port), tag: registerTag)
    }
    
    func send(to bytes: inout [Byte], pdu: Pdu, address: String, port: Int, tag: Int) {
        _ = pdu.writeTo(to: &bytes)
        
        do {
            socket.send(data: Data(bytes: bytes, count: bytes.count), tag: tag)
            try socket.receiveAlways()
        } catch {
            print("UDP ⇨ \(error)")
        }
    }
    
    internal func sendStatus(from remoteAddress: SwiftAsyncUDPSocketAddress, to bytes: inout [Byte]) throws {
        let sendDataResponse = SendDataResponse(seqNum: statusTag, inetAddress: remoteAddress.host, remotePort: Int(remoteAddress.port), code: 0)
        _ = try sendDataResponse.writeData(to: &bytes)

        send(to: &bytes, pdu: sendDataResponse, address: remoteAddress.host, port: Int(remoteAddress.port), tag: statusTag)
    }
    
    func getRange(arr: [UInt8], from: Int, to: Int) -> [UInt8]? {
        if from >= 0 && to >= from && to <= arr.count {
            return Array(arr[from..<to])
        }
        
        return nil
    }

    func disconnect() {
        guard socket.flags.contains(.didConnect) else { return }
        socket.close()
        registerTimer?.invalidate()
    }

    func reconnect() {
        disconnect()
        connect()
    }
    
    @objc func appMovedToBackground() {
        disconnect()
    }

    @objc func appMovedToForeground() {
        connect()
    }
}

extension WingsUDPClient: SwiftAsyncUDPSocketDelegate {
    public func updSocket(_ socket: SwiftAsyncUDPSocket, didConnectTo address: SwiftAsyncUDPSocketAddress) {
        print("UDP ⇨ connect to", address.host, address.port, address.type)
        
        var bytes: [Byte] = []
        try? sendRegistration(to: &bytes)
    }

    public func updSocket(_ socket: SwiftAsyncUDPSocket, didNotConnect error: SwiftAsyncSocketError) {
        print("UDP ⇨ not connect with", error)
    }

    public func updSocket(_ socket: SwiftAsyncUDPSocket, didSendDataWith tag: Int) {
        print("UDP ⇨ send data with", RequestTag.tag(for: tag))
    }

    public func updSocket(_ socket: SwiftAsyncUDPSocket, didNotSendDataWith tag: Int, dueTo error: SwiftAsyncSocketError) {
        print("UDP ⇨ not send data with", RequestTag.tag(for: tag), error)
        reconnect()
    }

    public func updSocket(_ socket: SwiftAsyncUDPSocket, didReceive data: Data, from address: SwiftAsyncUDPSocketAddress, withFilterContext filterContext: Any?) {
        var bytes = [Byte](repeating: 0, count: data.count)
        data.copyBytes(to: &bytes, count: data.count)
        
        var position = 0
        let length = Bytes.toInt16(src: &bytes, srcIndex: position)
        
        position += 2
        
        guard length <= bytes.count else { return }
        
        position += 4

        guard let strPacketData = Bytes.toString(src: bytes, srcIndex: 15 /* the only working index for parsing */, encoding: .ascii /* .utf8 not encode */) else { return }
        
        guard let data = strPacketData.data(using: .utf8), let json = data.parseToJson() else { return }
        
        PushNotificationHandler.shared.sheduleNotification(withJSON: json)
        
        do {
            var statusBytes = [Byte]()
            try sendStatus(from: address, to: &statusBytes)
        } catch {
            print(error)
        }
    }

    public func updSocket(_ socket: SwiftAsyncUDPSocket, didCloseWith error: SwiftAsyncSocketError?) {
        print("UDP ⇨ closed with", error ?? "unknown")
    }
}
