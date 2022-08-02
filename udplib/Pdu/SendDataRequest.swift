//
//  SendDataRequest.swift
//  udplib
//
//  Created by Ярослав Стрельников on 29.07.2022.
//

import Foundation

class SendDataRequest: Pdu {
    private var replyToAddress: String
    private var replyToPort: Int
    
    private var data: String?
    
    override var type: Pdu.`Type` {
        get {
            return .sendDataRequest
        }
    }
    
    init(replyToAddress: String, replyToPort: Int, data: String) {
        self.replyToAddress = replyToAddress
        self.replyToPort = replyToPort
        self.data = data
        super.init()
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, replyToAddress: String, replyToPort: Int, data: [Byte]) {
        self.replyToAddress = replyToAddress
        self.replyToPort = replyToPort
        self.data = String(data: Data(bytes: data, count: data.count), encoding: .utf8)
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, replyToAddress: String, replyToPort: Int, data: String) {
        self.replyToAddress = replyToAddress
        self.replyToPort = replyToPort
        self.data = data
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    override func writeData(to bytes: inout [Byte]) throws -> Int {
        bytes.append(contentsOf: [Byte](replyToAddress.utf8))
        var replyPortBytes: [Byte] = [Byte](repeating: 0, count: 4)
        
        Bytes.toByteArray(i: replyToPort, dst: &replyPortBytes, dstIndex: 0)
        
        bytes.append(contentsOf: replyPortBytes)
        
        guard let data = data else {
            return 0
        }

        let dataBytes = [Byte](data.utf8)
        bytes.append(contentsOf: dataBytes)
        
        return bytes.count
    }
}
