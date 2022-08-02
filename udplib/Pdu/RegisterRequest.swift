//
//  RegisterRequest.swift
//  udplib
//
//  Created by Ярослав Стрельников on 29.07.2022.
//

import Foundation

class RegisterRequest: Pdu {
    private var token: String?
    
    override var type: Pdu.`Type` {
        get {
            return .registerRequest
        }
    }
    
    init(token: String) {
        self.token = token
        super.init()
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, data: [Byte]) {
        self.token = String(data: Data(bytes: data, count: data.count), encoding: .utf8)
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, token: String) {
        self.token = token
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    override func writeData(to bytes: inout [Byte]) throws -> Int {
        guard let token = token else {
            return 0
        }

        let tokenBytes = [Byte](token.utf8)
        bytes.append(contentsOf: tokenBytes)
        
        print("UDP ⇨ packet bytes", bytes.hex)
        
        return bytes.count
    }
}
