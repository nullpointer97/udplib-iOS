//
//  RegisterResponse.swift
//  udplib
//
//  Created by Ярослав Стрельников on 29.07.2022.
//

import Foundation

class RegisterResponse: Response {
    override var type: Pdu.`Type` {
        get {
            return .registerResponse
        }
    }
    
    override init(seqNum: Int, code: Byte) {
        super.init(seqNum: seqNum, code: code)
    }

    override init(seqNum: Int, inetAddress: String, remotePort: Int, data: inout [Byte]) {
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort, data: &data)
    }
    
    override init(seqNum: Int, inetAddress: String, remotePort: Int, code: Byte) {
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort, code: code)
    }
}
