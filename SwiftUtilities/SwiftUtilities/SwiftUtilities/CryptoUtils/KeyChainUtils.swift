//
//  KeyChainUtils.swift
//  SwiftUtilities
//
//  Created by HongXiangWen on 2020/1/19.
//  Copyright © 2020 WHX. All rights reserved.
//

import Foundation

public class KeyChainUtils {
    
    ///  访问控制
    public enum Accessible: RawRepresentable, CustomStringConvertible {
        
        /// Item data can only be accessed while the device is unlocked.
        /// This is recommended for items that only need be accesible while the application is in the foreground.
        /// Items with this attribute will migrate to a new device when using encrypted backups.
        case whenUnlocked
        
        /// Item data can only be accessed once the device has been unlocked after a restart.
        /// This is recommended for items that need to be accesible by background applications.
        /// Items with this attribute will migrate to a new device when using encrypted backups.
        case afterFirstUnlock
        
        /// Item data can always be accessed regardless of the lock state of the device.
        /// This is not recommended for anything except system use.
        /// Items with this attribute will migrate to a new device when using encrypted backups.
        case always
        
        /// Item data can only be accessed while the device is unlocked.
        /// This is recommended for items that only need to be accessible while the application is in the foreground
        /// and requires a passcode to be set on the device.
        /// Items with this attribute will never migrate to a new device, so after a backup is restored to a new device, these items will be missing.
        /// This attribute will not be available on devices without a passcode.
        /// Disabling the device passcode will cause all previously protected items to be deleted.
        @available(iOS 8.0, *)
        case whenPasscodeSetThisDeviceOnly
        
        /// Item data can only be accessed while the device is unlocked.
        /// This is recommended for items that only need be accesible while the application is in the foreground.
        /// Items with this attribute will never migrate to a new device, so after backup is restored to a new device, these items will be missing.
        case whenUnlockedThisDeviceOnly

        /// Item data can only be accessed once the device has been unlocked after a restart.
        /// This is recommended for items that need to be accessible by background applications.
        /// Items with this attribute will never migrate to a new  device, so after a backup is restored to a new device these items will be missing.
        case afterFirstUnlockThisDeviceOnly
        
        /// Item data can always be accessed regardless of the lock state of the device.
        /// This option is not recommended for anything except system use.
        /// Items with this attribute will never migrate to a new device, so after a backup is restored to a new device, these items will be missing.
        case alwaysThisDeviceOnly
        
        public init?(rawValue: String) {
            switch rawValue {
            case String(kSecAttrAccessibleWhenUnlocked):
                self = .whenUnlocked
            case String(kSecAttrAccessibleAfterFirstUnlock):
                self = .afterFirstUnlock
            case String(kSecAttrAccessibleAlways):
                self = .always
            case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
                self = .whenPasscodeSetThisDeviceOnly
            case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
                self = .whenUnlockedThisDeviceOnly
            case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
                self = .afterFirstUnlockThisDeviceOnly
            case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
                self = .alwaysThisDeviceOnly
            default:
                return nil
            }
        }

        public var rawValue: String {
            switch self {
            case .whenUnlocked:
                return String(kSecAttrAccessibleWhenUnlocked)
            case .afterFirstUnlock:
                return String(kSecAttrAccessibleAfterFirstUnlock)
            case .always:
                return String(kSecAttrAccessibleAlways)
            case .whenPasscodeSetThisDeviceOnly:
                return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            case .whenUnlockedThisDeviceOnly:
                return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
            case .afterFirstUnlockThisDeviceOnly:
                return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            case .alwaysThisDeviceOnly:
                return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
            }
        }

        public var description: String {
            switch self {
            case .whenUnlocked:
                return "WhenUnlocked"
            case .afterFirstUnlock:
                return "AfterFirstUnlock"
            case .always:
                return "Always"
            case .whenPasscodeSetThisDeviceOnly:
                return "WhenPasscodeSetThisDeviceOnly"
            case .whenUnlockedThisDeviceOnly:
                return "WhenUnlockedThisDeviceOnly"
            case .afterFirstUnlockThisDeviceOnly:
                return "AfterFirstUnlockThisDeviceOnly"
            case .alwaysThisDeviceOnly:
                return "AlwaysThisDeviceOnly"
            }
        }
    }
        
    public enum RSAError: LocalizedError {
        
        case createAccessControlFail
        case generateKeypairFail(_ status: Int)
        case getPublicKeyFail(_ status: Int)
        case getPrivateKeyFail(_ status: Int)
        
        public var errorDescription: String? {
            switch self {
            case .createAccessControlFail:
                return "CreateAccessControlFail"
            case .generateKeypairFail(let status):
                return "GenerateKeypairFail: \(status)"
            case .getPublicKeyFail(let status):
                return "GetPublicKeyFail: \(status)"
            case .getPrivateKeyFail(let status):
                return "GetPrivateKeyFail: \(status)"
            }
        }
    }
    
    public enum RSAKeyType {
        
        case privateKey
        case publicKey
        
        var attrKeyClass: String {
            switch self {
            case .privateKey:
                return String(kSecAttrKeyClassPrivate)
            case .publicKey:
                return String(kSecAttrKeyClassPublic)
            }
        }
    }
    
    /// 生成RSA密钥对，会直接持久化到钥匙串中
    ///
    /// - Parameters:
    ///   - privateKeyLabel: 私钥标识
    ///   - publicKeyLabel: 公钥标识
    ///   - keySize: 密钥大小，支持512，768，1024，2048位，默认2048
    ///   - accessible: 访问控制，默认 .afterFirstUnlockThisDeviceOnly
    ///   - flags: 访问控制验证方式，默认为nil
    /// - Returns: 密钥对
    public static func generateRSAKeyPair(privateKeyLabel: String, publicKeyLabel: String, keySize: Int = 2048, accessible: Accessible = .afterFirstUnlockThisDeviceOnly, flags: SecAccessControlCreateFlags? = nil) throws -> (privateKey: SecKey, publicKey: SecKey) {
        var parameters: [String: Any] = [:]
        parameters[String(kSecClass)] = String(kSecClassKey)
        parameters[String(kSecAttrKeyType)] = String(kSecAttrKeyTypeRSA)
        parameters[String(kSecAttrKeySizeInBits)] = keySize
        parameters[String(kSecPrivateKeyAttrs)] = permanentAttributes(lebel: privateKeyLabel)
        parameters[String(kSecPublicKeyAttrs)] = permanentAttributes(lebel: publicKeyLabel)
        if let flags = flags {
            var error: Unmanaged<CFError>?
            guard let accessControl = SecAccessControlCreateWithFlags(nil, accessible.rawValue as CFTypeRef, flags, &error) else {
                print(error!.takeRetainedValue().localizedDescription)
                throw RSAError.createAccessControlFail
            }
            parameters[String(kSecAttrAccessControl)] = accessControl
        } else {
            parameters[String(kSecAttrAccessible)] = accessible.rawValue
        }
        if #available(iOS 10.0, *) {
            var error: Unmanaged<CFError>?
            guard let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error) else {
                print(error!.takeRetainedValue().localizedDescription)
                throw RSAError.generateKeypairFail(-1)
            }
            guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
                throw RSAError.getPublicKeyFail(-1)
            }
            return (privateKey, publicKey)
        } else {
            var privateKey: SecKey?
            var publicKey: SecKey?
            let status = SecKeyGeneratePair(parameters as CFDictionary, &publicKey, &privateKey)
            guard status == errSecSuccess else {
                throw RSAError.generateKeypairFail(Int(status))
            }
            return (privateKey!, publicKey!)
        }
    }
    
    /// 从钥匙串中获取公钥
    ///
    /// - Parameter label: 公钥标识
    /// - Returns: 公钥对象
    public static func getRSAPublicKey(label: String) throws -> SecKey {
        let query = rsaKeyQuery(type: .publicKey, label: label)
        var publicKey: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &publicKey)
        guard status == errSecSuccess else {
            throw RSAError.getPublicKeyFail(Int(status))
        }
        return publicKey as! SecKey
    }
    
    /// 从钥匙串中获取私钥
    ///
    /// - Parameter label: 私钥标识
    /// - Returns: 私钥对象
    public static func getRSAPrivateKey(label: String) throws -> SecKey {
        let query = rsaKeyQuery(type: .privateKey, label: label)
        var privateKey: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &privateKey)
        guard status == errSecSuccess else {
            throw RSAError.getPrivateKeyFail(Int(status))
        }
        return privateKey as! SecKey
    }
            
    /// 从钥匙串中删除密钥对
    ///
    /// - Parameters:
    ///   - privateKeyLabel: 私钥标识
    ///   - publicKeyLabel: 公钥标识
    public static func removeRSAKeypair(privateKeyLabel: String, publicKeyLabel: String) {
        /// 删除私钥
        let privateKeyQuery = rsaKeyQuery(type: .privateKey, label: privateKeyLabel)
        let priStatus = SecItemDelete(privateKeyQuery as CFDictionary)
        if (priStatus != errSecSuccess && priStatus != errSecItemNotFound) {
            print("Remove private key fail: \(priStatus)")
        }
        /// 删除公钥
        let publickKeyQuery = rsaKeyQuery(type: .publicKey, label: publicKeyLabel)
        let pubStatus = SecItemDelete(publickKeyQuery as CFDictionary)
        if (pubStatus != errSecSuccess && pubStatus != errSecItemNotFound) {
            print("Remove public key fail: \(pubStatus)")
        }
    }
    
    private static func permanentAttributes(lebel: String) -> [String: Any] {
        return [
            String(kSecAttrIsPermanent): true,  // 持久化到钥匙串中
            String(kSecAttrLabel): lebel
        ]
    }
    
    private static func rsaKeyQuery(type: RSAKeyType, label: String) -> [String: Any] {
        return [
            String(kSecClass): String(kSecClassKey),
            String(kSecAttrKeyClass): type.attrKeyClass,
            String(kSecMatchLimit): String(kSecMatchLimitOne),
            String(kSecAttrLabel): label,
            String(kSecReturnRef): true
        ]
    }
 
}
