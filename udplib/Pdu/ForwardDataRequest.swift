//
//  ForwardDataRequest.swift
//  udplib
//
//  Created by Ярослав Стрельников on 28.07.2022.
//

import Foundation

class ForwardDataRequest: Pdu {
    private var token: String
    private var data: String
    
    override var type: Pdu.`Type` {
        get {
            return .forwardDataRequest
        }
    }
    
    init(token: String, data: String) {
        self.token = token
        self.data = data
        super.init()
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, token: String, data: String) {
        self.token = token
        self.data = data
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    override func writeData(to bytes: inout [Byte]) throws -> Int {
        var length = writeString(s: token, to: &bytes)
        length += writeString(s: data, to: &bytes)
        
        return length
    }
    
    private func writeString(s: String, to bytes: inout [Byte]) -> Int {
        let sBytes = [Byte](s.utf8)
        var lengthBytes = [Byte](repeating: 0, count: 4)
        
        Bytes.toByteArray(i: sBytes.count, dst: &lengthBytes, dstIndex: 0)
        
        bytes.append(contentsOf: lengthBytes)
        bytes.append(contentsOf: sBytes)
        
        return bytes.count
    }
}
