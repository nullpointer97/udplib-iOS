//
//  Nack.swift
//  udplib
//
//  Created by Ярослав Стрельников on 29.07.2022.
//

import Foundation

class Nack: Response {
    override var type: Pdu.`Type` {
        get {
            return super.type
        }
    }
    
    init(seqNum: Int) {
        super.init(seqNum: seqNum, code: Response.FAIL)
    }
}
