//
//  Pdu.swift
//  udplib
//
//  Created by Ярослав Стрельников on 28.07.2022.
//

import Foundation

class Pdu: NSObject {
    public static var AVARAGE_DATA_SIZE: Int = 128
    public static var HEADER_SIZE: Int = 7
    private var seqNum: Int
    private var inetAddress: String?
    private var remotePort: Int?

    init(seqNum: Int, inetAddress: String, remotePort: Int) {
        self.seqNum = seqNum
        self.inetAddress = inetAddress
        self.remotePort = remotePort
    }
    
    override init() {
        self.seqNum = 1
        self.inetAddress = nil
        self.remotePort = -1
    }
    
    enum `Type`: Byte {
        case nack = 1
        case registerRequest = 10
        case registerResponse = 11
        case addressQueryRequest = 20
        case addressQueryResponse = 21
        case sendDataRequest = 30
        case sendDataResponse = 31
        case forwardDataRequest = 40
        case forwardDataResponse = 41
        case unknown = 0
        
        static func getType(from bytes: Byte) -> Type {
            switch bytes {
            case 1:
                return .nack
            case 10:
                return .registerRequest
            case 11:
                return .registerResponse
            case 20:
                return .addressQueryRequest
            case 21:
                return .addressQueryResponse
            case 30:
                return .sendDataRequest
            case 31:
                return .sendDataResponse
            case 40:
                return .forwardDataRequest
            case 41:
                return .forwardDataResponse
            default:
                return .unknown
            }
        }
    }
    
    var type: Type {
        get {
            return .unknown
        }
    }
    
    static func buildFromBytes(remoteIp: String, remotePort: Int, bytes: inout [Byte]) throws -> Pdu {
        if bytes.isEmpty || bytes.count < Pdu.HEADER_SIZE {
            throw "Not enought data"
        } else {
            var position = 0
            let length = Bytes.toInt16(src: &bytes, srcIndex: position)
            
            position += 2
            
            if length > bytes.count {
                throw "Not enough data, invalid length value: \(length)"
            } else {
                let seqNum = Bytes.toInt(src: &bytes, srcIndex: position)
                position += 4
                
                let type = Type.getType(from: bytes[position++])
                guard var data = copyOfRange(arr: bytes, from: position, to: length.toInt) else {
                    throw "Not enought data"
                }
                let payloadSize = length.toInt - Pdu.HEADER_SIZE
                
                switch type {
                case .nack:
                    return Nack(seqNum: seqNum)
                case .registerRequest:
                    return RegisterRequest(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, data: data)
                case .registerResponse:
                    return RegisterResponse(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, data: &data)
                case .addressQueryRequest:
                    return AddressQueryRequest(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, data: data)
                case .addressQueryResponse:
                    return AddressQueryResponse(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, data: &data)
                case .sendDataRequest:
                    if payloadSize < 8 /*ip + port*/ {
                        throw "Not enough data in SendDataRequest payload: \(payloadSize)"
                    }
                    
                    guard let replyToAddress = String(data: Data(bytes: [data[0...3]], count: 4), encoding: .utf8) else {
                        throw "No reply IP address"
                    }
                    let replyToPort = Bytes.toInt(src: &data, srcIndex: 4)
                    
                    return SendDataRequest(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, replyToAddress: replyToAddress, replyToPort: replyToPort, data: data)
                case .sendDataResponse:
                    return SendDataResponse(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, data: &data)
                case .forwardDataResponse:
                    return ForwardDataResponse(seqNum: seqNum, inetAddress: remoteIp, remotePort: remotePort, data: &data)
                default:
                    throw "Unexpected request type: \(type)"
                }
            }
        }
    }
    
    public func writeTo(to bytes: inout [Byte]) -> Int {
        var headerBytes: [Byte] = [0, 0, 0, 0, 0, 0, type.rawValue]
        
        Bytes.toByteArray(i: seqNum, dst: &headerBytes, dstIndex: 2)
        seqNum += 1

        Bytes.toByteArray(i: Int16(headerBytes.count + bytes.count), dst: &headerBytes, dstIndex: 0)
        
        bytes.insert(contentsOf: headerBytes, at: 0)

        print("UDP ⇨ packet bytes", bytes.hex)
        
        return bytes.count
    }
    
    func writeData(to bytes: inout [Byte]) throws -> Int { return 0 }
}
