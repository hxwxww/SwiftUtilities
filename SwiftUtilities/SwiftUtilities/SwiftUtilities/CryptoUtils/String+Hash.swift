//
//  String+Hash.swift
//  SwiftUtilities
//
//  Created by HongXiangWen on 2020/1/18.
//  Copyright © 2020 WHX. All rights reserved.
//

import Foundation
import CommonCrypto

// MARK: -  hash算法类型
public enum HashAlgorithm {
    
    /// MD5算法
    case MD5
    
    /// SHA1算法
    case SHA1
    
    /// SHA224算法
    case SHA224
    
    /// SHA256算法
    case SHA256
    
    /// SHA384算法
    case SHA384
    
    /// SHA512算法
    case SHA512
    
    /// 摘要长度
    public var digestLength: Int {
        switch self {
        case .MD5:
            return Int(CC_MD5_DIGEST_LENGTH)
        case .SHA1:
            return Int(CC_SHA1_DIGEST_LENGTH)
        case .SHA224:
            return Int(CC_SHA224_DIGEST_LENGTH)
        case .SHA256:
            return Int(CC_SHA256_DIGEST_LENGTH)
        case .SHA384:
            return Int(CC_SHA384_DIGEST_LENGTH)
        case .SHA512:
            return Int(CC_SHA512_DIGEST_LENGTH)
        }
    }
    
    /// hmac算法类型
    public var hmacAlgorithm: CCHmacAlgorithm {
        switch self {
        case .MD5:
            return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .SHA1:
            return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .SHA224:
            return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .SHA256:
            return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .SHA384:
            return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .SHA512:
            return CCHmacAlgorithm(kCCHmacAlgSHA512)
        }
    }
}


// MARK: -  哈希/散列算法
extension String {
    
    /// md5
    public var md5String: String {
        return hashString(.MD5)
    }
    
    /// sha1
    public var sha1String: String {
        return hashString(.SHA1)
    }
    
    /// sha224
    public var sha224String: String {
        return hashString(.SHA224)
    }
    
    /// sha256
    public var sha256String: String {
        return hashString(.SHA256)
    }
    
    /// sha384
    public var sha384String: String {
        return hashString(.SHA384)
    }
    
    /// sha512
    public var sha512String: String {
        return hashString(.SHA512)
    }
 
    /// 计算hashString
    ///
    /// - Parameter algorithm: 算法类型
    /// - Returns: 计算结果
    public func hashString(_ algorithm: HashAlgorithm) -> String {
        let cStr = self.cString(using: .utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        let digestLength = algorithm.digestLength
        let digest = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        switch algorithm {
        case .MD5:
            CC_MD5(cStr, strLen, digest)
        case .SHA1:
            CC_SHA1(cStr, strLen, digest)
        case .SHA224:
            CC_SHA224(cStr, strLen, digest)
        case .SHA256:
            CC_SHA256(cStr, strLen, digest)
        case .SHA384:
            CC_SHA384(cStr, strLen, digest)
        case .SHA512:
            CC_SHA512(cStr, strLen, digest)
        }
        return Data(bytes: digest, count: digestLength).hexString
    }
    
    /// 计算hmacString
    ///
    /// - Parameters:
    ///   - algorithm: 算法类型
    ///   - key: 密钥
    /// - Returns: 计算结果
    public func hmacString(_ algorithm: HashAlgorithm, key: String) -> String {
        let kStr = key.cString(using: .utf8)
        let keyLen = CC_LONG(key.lengthOfBytes(using: .utf8))
        let cStr = self.cString(using: .utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: .utf8))
        let digestLength = algorithm.digestLength
        let digest = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        CCHmac(algorithm.hmacAlgorithm, kStr, Int(keyLen), cStr, Int(strLen), digest)
        return Data(bytes: digest, count: digestLength).hexString
    }
    
}
