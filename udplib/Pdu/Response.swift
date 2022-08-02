//
//  Response.swift
//  udplib
//
//  Created by Ярослав Стрельников on 29.07.2022.
//

import Foundation

class Response: Pdu {
    static var SUCCESS: Byte = 0
    static var NO_CLIENT_ADDRESS_FOUND: Byte = 100
    static var SEND_DATA_RESPONSE_TIMEOUT: Byte = 110
    static var NO_ACTIVE_CHANNEL: Byte = 120
    static var FAIL: Byte = 0
    
    internal var code: Byte
    
    override var type: Pdu.`Type` {
        return .registerResponse
    }
    
    init(seqNum: Int, code: Byte) {
        self.code = code
        super.init(seqNum: seqNum, inetAddress: "", remotePort: -1)
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, data: inout [Byte]) {
        self.code = data[0]
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, code: Byte) {
        self.code = code
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort)
    }
    
    override func writeData(to bytes: inout [Byte]) throws -> Int {
        bytes.append(code)
        return 1
    }
}
