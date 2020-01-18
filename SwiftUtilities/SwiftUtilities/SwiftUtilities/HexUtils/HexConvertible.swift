//
//  HexConvertible.swift
//  SwiftUtilities
//
//  Created by HongXiangWen on 2020/1/18.
//  Copyright © 2020 WHX. All rights reserved.
//

import Foundation

public protocol HexConvertible {
    
    /// hex dump
    ///
    /// - Parameters:
    ///   - separator: 分隔符
    ///   - uppercase: 是否大写
    /// - Returns: hexString
    func hexDump(separator: String, uppercase: Bool) -> String
    
    /// 16进制字符串
    var hexString: String { get }
}

extension HexConvertible where Self: Collection, Element == UInt8 {
    
    /// hex dump
    ///
    /// - Parameters:
    ///   - separator: 分隔符，默认为空格
    ///   - uppercase: 是否大写，默认为true
    /// - Returns: hexString
    public func hexDump(separator: String = " ", uppercase: Bool = true) -> String {
        return String(reduce("", { $0 + String(format: (uppercase ? "%02X" : "%02x") + separator, $1)} ).dropLast(separator.count))
    }
    
    public var hexString: String {
        return hexDump(separator: "", uppercase: false)
    }
    
}

extension Array: HexConvertible where Element == UInt8 { }
extension Data: HexConvertible { }
