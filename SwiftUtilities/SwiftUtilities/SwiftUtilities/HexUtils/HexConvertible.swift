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

extension String {
    
    /// 是否是16进制字符串
    public var isHexString: Bool {
        let hexChars = "0123456789abcdef"
        if let _ = lowercased().first(where: { !hexChars.contains($0) }) {
            return false
        } else {
            return true
        }
    }

    /// 转为hexData
    public var hexData: Data? {
        guard isHexString else {
            return nil
        }
        var data = Data()
        for i in stride(from: 0, to: count, by: 2) {
            let hex = (self as NSString).substring(with: NSRange(location: i, length: 2))
            let scanner = Scanner(string: hex)
            var intValue: UInt64 = 0
            scanner.scanHexInt64(&intValue)
            data.append(UInt8(intValue))
        }
        return data
    }
    
}

extension Data {
    
    /// 通过hexString初始化
    ///
    /// - Parameter hexString: 16进制字符串
    public init?(hexString: String) {
        guard let data = hexString.hexData else {
            return nil
        }
        self = data
    }
    
}
