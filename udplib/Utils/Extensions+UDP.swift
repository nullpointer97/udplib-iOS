//
//  Extensions+UDP.swift
//  WingsPushSDK
//
//  Created by Ярослав Стрельников on 02.08.2022.
//  Copyright © 2022 Wings Solutions. All rights reserved.
//

import Foundation
import UIKit

internal typealias Byte = UInt8

extension String: Error {}

extension short {
    var toInt: Int {
        return Int(self)
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    
    func parseToJson() -> Dictionary<String, Any>? {
        do {
            if let json = try JSONSerialization.jsonObject(with: self, options : .allowFragments) as? Dictionary<String,Any> {
                return json
            } else {
                print("bad json")
                return nil
            }
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    func pretty(_ encoding: String.Encoding = .utf8) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: [.mutableContainers, .fragmentsAllowed, .mutableLeaves]),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: encoding) else { return "None" }

        return prettyPrintedString
    }
    
    var prettyPrintedJSONString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }

        return prettyPrintedString
    }
}

extension Array where Element == Byte {
    var hex: String {
        return compactMap { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension UNNotificationAttachment {
    static func saveImageToDisk(fileIdentifier: String, data: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
             print("error \(error)")
        }
        
        return nil
    }
}

extension Byte {
    var toInt: Int {
        return Int(self)
    }
}

prefix operator --
prefix operator ++
postfix operator --
postfix operator ++

prefix func ++(_ a : inout Int) -> Int {
    a += 1
    return a
}
prefix func --(_ a : inout Int) -> Int {
    a -= 1
    return a
}
postfix func ++(_ a: inout Int) -> Int {
    defer { a += 1 }
    return a
}
postfix func --(_ a: inout Int) -> Int {
    defer { a -= 1 }
    return a
}
