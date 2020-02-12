//
//  CryptoUtils.swift
//  SwiftUtilities
//
//  Created by HongXiangWen on 2020/1/20.
//  Copyright © 2020 WHX. All rights reserved.
//

import Foundation

public class CryptoUtils {
    
    public enum RSAError: LocalizedError {
        
        case dataCorrupted
        case encryptFail(_ status: Int)
        case decryptFail(_ status: Int)
        case signFail(_ status: Int)
        
        public var errorDescription: String? {
            switch self {
            case .dataCorrupted:
                return "DataCorrupted"
            case .encryptFail(let status):
                return "EncryptFail: \(status)"
            case .decryptFail(let status):
                return "DecryptFail: \(status)"
            case .signFail(let status):
                return "SignFail: \(status)"
            }
        }
    }
    
    /// 使用公钥加密
    ///
    /// - Parameters:
    ///   - publicKey: 公钥
    ///   - plainText: 明文
    /// - Returns: 密文
    public static func rsaEncrypt(_ publicKey: SecKey, plainText: String) throws -> String {
        guard let plainData = plainText.data(using: .utf8) else {
            throw RSAError.dataCorrupted
        }
        let totalLength = plainData.count
        let blockLength = SecKeyGetBlockSize(publicKey)
        var cipherBuffer = [UInt8](repeating: 0, count: blockLength)
        var cipherLength = blockLength
        var index = 0
        var cipherData = Data()
        while index < totalLength {
            var currentDataLength = totalLength - index
            // kSecPaddingNone = 0，要加密的数据块大小 <= SecKeyGetBlockSize的大小，如这里的256
            // kSecPaddingPKCS1 = 1, 要加密的数据块大小 <= 256-11
            // kSecPaddingOAEP = 2, 要加密的数据块大小 <= 256-42
            if currentDataLength > blockLength - 11 {
                currentDataLength = blockLength - 11
            }
            let currentData = plainData.subdata(in: index ..< index + currentDataLength)
            var subCipherData: Data
            if #available(iOS 10.0, *) {
                var error: Unmanaged<CFError>?
                guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, currentData as CFData, &error) else {
                    print("Encrypt fail: \(error!.takeRetainedValue().localizedDescription)")
                    throw RSAError.encryptFail(-1)
                }
                subCipherData = encryptedData as Data
            } else {
                let status = SecKeyEncrypt(publicKey, .PKCS1, [UInt8](currentData), currentDataLength, &cipherBuffer, &cipherLength)
                guard status == errSecSuccess else {
                    throw RSAError.encryptFail(Int(status))
                }
                subCipherData = Data(bytes: cipherBuffer, count: cipherLength)
            }
            cipherData.append(subCipherData)
            index += currentDataLength
        }
        return cipherData.base64EncodedString()
    }
    
    /// 使用私钥解密
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - cipherText: 密文
    /// - Returns: 明文
    public static func rsaDecrypt(_ privateKey: SecKey, cipherText: String) throws -> String {
        guard let cipherData = Data(base64Encoded: cipherText) else {
            throw RSAError.dataCorrupted
        }
        let totalLength = cipherData.count
        let blockLength = SecKeyGetBlockSize(privateKey)
        var plainBuffer = [UInt8](repeating: 0, count: blockLength)
        var plainLength = blockLength
        var index = 0
        var plainData = Data()
        while index < totalLength {
            var currentDataLength = totalLength - index
            if currentDataLength > blockLength {
                currentDataLength = blockLength
            }
            let currentData = cipherData.subdata(in: index ..< index + currentDataLength)
            var subPlainData: Data
            if #available(iOS 10.0, *) {
                var error: Unmanaged<CFError>?
                guard let encryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionPKCS1, currentData as CFData, &error) else {
                    print("Decrypt fail: \(error!.takeRetainedValue().localizedDescription)")
                    throw RSAError.decryptFail(-1)
                }
                subPlainData = encryptedData as Data
            } else {
                let status = SecKeyDecrypt(privateKey, .PKCS1, [UInt8](currentData), currentDataLength, &plainBuffer, &plainLength)
                guard status == errSecSuccess else {
                    throw RSAError.decryptFail(Int(status))
                }
                subPlainData = Data(bytes: plainBuffer, count: plainLength)
            }
            plainData.append(subPlainData)
            index += currentDataLength
        }
        guard let plainText = String(data: plainData, encoding: .utf8) else {
            throw RSAError.dataCorrupted
        }
        return plainText
    }
    
    /// 使用私钥签名
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - message: 要签名的数据
    /// - Returns: 签名的结果
    static func rsaSign(_ privateKey: SecKey, message: String) throws -> String {
        if #available(iOS 10.0, *) {
            guard let msgData = message.data(using: .utf8) else {
                throw RSAError.dataCorrupted
            }
            var error: Unmanaged<CFError>?
            guard let sigData = SecKeyCreateSignature(privateKey, .rsaSignatureMessagePKCS1v15SHA256, msgData as CFData, &error) else {
                print("Sign fail: \(error!.takeRetainedValue().localizedDescription)")
                throw RSAError.signFail(-1)
            }
            return (sigData as Data).base64EncodedString()
        } else {
            guard let SHA256Data = message.sha256String.hexData else {
                throw RSAError.dataCorrupted
            }
            var sigLength = SecKeyGetBlockSize(privateKey)
            var sigBuffer = [UInt8](repeating: 0, count: sigLength)
            let status = SecKeyRawSign(privateKey, .PKCS1SHA256, [UInt8](SHA256Data), SHA256Data.count, &sigBuffer, &sigLength)
            guard status == errSecSuccess else {
                throw RSAError.signFail(Int(status))
            }
            return Data(bytes: sigBuffer, count: sigLength).base64EncodedString()
        }
    }
    
    /// 使用公钥验证签名
    ///
    /// - Parameters:
    ///   - publicKey: 公钥
    ///   - message: 要签名的数据
    ///   - signature: 签名
    /// - Returns: 验证结果
    static func rsaVerify(_ publicKey: SecKey, message: String, signature: String) throws -> Bool {
        guard let sigData = Data(base64Encoded: signature) else {
            throw RSAError.dataCorrupted
        }
        if #available(iOS 10.0, *) {
            guard let msgData = message.data(using: .utf8) else {
                throw RSAError.dataCorrupted
            }
            var error: Unmanaged<CFError>?
            let result = SecKeyVerifySignature(publicKey, .rsaSignatureMessagePKCS1v15SHA256, msgData as CFData, sigData as CFData, &error)
            if !result {
                print("Verify fail: \(error!.takeRetainedValue().localizedDescription)")
            }
            return result
        } else {
            guard let SHA256Data = message.sha256String.hexData else {
                throw RSAError.dataCorrupted
            }
            let status = SecKeyRawVerify(publicKey, .PKCS1SHA256, [UInt8](SHA256Data), SHA256Data.count, [UInt8](sigData), sigData.count)
            guard status == errSecSuccess else {
                print("Verify fail: \(status)")
                return false
            }
            return true
        }
    }
    
}
