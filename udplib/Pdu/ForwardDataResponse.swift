//
//  ForwardDataResponse.swift
//  udplib
//
//  Created by Ярослав Стрельников on 29.07.2022.
//

import Foundation

class ForwardDataResponse: Response {
    override var type: Pdu.`Type` {
        get {
            return .forwardDataResponse
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
