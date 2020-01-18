//
//  BytesConvertible.swift
//  SwiftUtilities
//
//  Created by HongXiangWen on 2020/1/18.
//  Copyright © 2020 WHX. All rights reserved.
//

import Foundation

public protocol BytesConvertible {
    
    /// 小端byte数组
    var littleEndianBytes: [UInt8] { get }
    
    /// 大端byte数组
    var bigEndianBytes: [UInt8] { get }
}

extension UInt16: BytesConvertible {
    
    public var littleEndianBytes: [UInt8] {
        return [
            UInt8(truncatingIfNeeded: self),
            UInt8(truncatingIfNeeded: self >> 8)
        ]
    }
    
    public var bigEndianBytes: [UInt8] {
        return littleEndianBytes.reversed()
    }

}

extension UInt32: BytesConvertible {
    
    public var littleEndianBytes: [UInt8] {
        return [
            UInt8(truncatingIfNeeded: self),
            UInt8(truncatingIfNeeded: self >> 8),
            UInt8(truncatingIfNeeded: self >> 16),
            UInt8(truncatingIfNeeded: self >> 24)
        ]
    }
    
    public var bigEndianBytes: [UInt8] {
        return littleEndianBytes.reversed()
    }
    
}

extension UInt64: BytesConvertible {
    
    public var littleEndianBytes: [UInt8] {
        return [
            UInt8(truncatingIfNeeded: self),
            UInt8(truncatingIfNeeded: self >> 8),
            UInt8(truncatingIfNeeded: self >> 16),
            UInt8(truncatingIfNeeded: self >> 24),
            UInt8(truncatingIfNeeded: self >> 32),
            UInt8(truncatingIfNeeded: self >> 40),
            UInt8(truncatingIfNeeded: self >> 48),
            UInt8(truncatingIfNeeded: self >> 56)
        ]
    }
    
    public var bigEndianBytes: [UInt8] {
        return littleEndianBytes.reversed()
    }
    
}
