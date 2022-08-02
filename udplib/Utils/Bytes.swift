//
//  Bytes.swift
//  udplib
//
//  Created by Ярослав Стрельников on 13.07.2022.
//

import Foundation

typealias short = Int16

internal class Bytes {
    static func toInt(src: inout [Byte], srcIndex: Int) -> Int {
        var _srcIndex = srcIndex
        
        _srcIndex += 1
        
        let __srcIndex = _srcIndex + 1
        
        var value = src[_srcIndex] & 255 << 24 | (src[__srcIndex] & 255) << 16
        
        _srcIndex += 1
        
        value = value | (src[_srcIndex]) & 255 << 8 | src[_srcIndex] & 255
        return value.toInt
    }

    static func toInt16(src: inout [Byte], srcIndex: Int) -> short {
        var _srcIndex = srcIndex
        
        _srcIndex += 1
        
        var value: Int16 = short(src[_srcIndex]) & 255 << 8
        value = value | short(src[_srcIndex]) & 255
        return value
    }
    
    static func toByteArray(i: Int16, dst: inout [Byte], dstIndex: Int) {
        var _dstIndex = dstIndex
        
        _dstIndex += 1
        
        dst[_dstIndex] = Byte(i >> 8 & 255)
        dst[_dstIndex] = Byte(i & 255)
    }
    
    static func toByteArray(i: Int, dst: inout [Byte], dstIndex: Int) {
        var _dstIndex = dstIndex
        
        _dstIndex += 1
        
        dst[_dstIndex] = Byte(i >> 24 & 255)
        
        _dstIndex += 1
        
        dst[_dstIndex] = Byte(i >> 16 & 255)
        
        _dstIndex += 1
        
        dst[_dstIndex] = Byte(i >> 8 & 255)
        dst[_dstIndex] = Byte(i & 255)
    }
    
    static func toString(src: [Byte], srcIndex: Int, encoding: String.Encoding = .utf8) -> String? {
        guard let copyBytes = copyOfRange(arr: src, from: srcIndex, to: src.count) else { return nil }
        return String(bytes: copyBytes, encoding: encoding)
    }
}

func copyOfRange<T>(arr: [T], from: Int, to: Int) -> [T]? where T: ExpressibleByIntegerLiteral {
    guard from >= 0 && from <= arr.count && from <= to else { return nil }

    var to = to
    var padding = 0

    if to > arr.count {
        padding = to - arr.count
        to = arr.count
    }

    return Array(arr[from..<to]) + [T](repeating: 0, count: padding)
}
