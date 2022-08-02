//
//  AddressQueryResponse.swift
//  udplib
//
//  Created by Ярослав Стрельников on 28.07.2022.
//

import Foundation

class AddressQueryResponse: Response {
    private var address: String?
    private var port: Int?
    
    override var type: Pdu.`Type` {
        get {
            return .addressQueryResponse
        }
    }
    
    override init(seqNum: Int, inetAddress: String, remotePort: Int, data: inout [Byte]) {
        self.address = String(data: Data(bytes: data, count: data.count), encoding: .utf8)
        self.port = Bytes.toInt(src: &data, srcIndex: 4)
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort, data: &data)
    }
    
    init(seqNum: Int, inetAddress: String, remotePort: Int, address: String, port: Int, code: Byte) {
        self.address = address
        self.port = port
        super.init(seqNum: seqNum, inetAddress: inetAddress, remotePort: remotePort, code: code)
    }
    
    override func writeData(to bytes: inout [Byte]) throws -> Int {
        guard let address = address, let port = port else {
            return bytes.count
        }

        bytes.append(contentsOf: [Byte](address.utf8))
        
        var codeBytes = [Byte](repeating: 0, count: 5)
        codeBytes[4] = code
        
        Bytes.toByteArray(i: port, dst: &codeBytes, dstIndex: 0)
        
        bytes.append(contentsOf: codeBytes)
        
        return 9
    }
}
