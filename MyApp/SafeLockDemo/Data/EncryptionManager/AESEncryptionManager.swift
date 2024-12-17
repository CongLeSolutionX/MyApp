//
//  AESEncryptionManager.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/
// Article: https://canopas.com/consistent-data-encryption-in-android-ios-and-flutter-apps-with-aes-535fc64ad80c

import CryptoKit
import Foundation


public class AESEncryptionManager {
    
    static func encrypt(plainText: String, key: String, keySize: Int = 32) -> String? {
        guard let data = plainText.data(using: .utf8), let keyData = key.data(using: .utf8)?.prefix(keySize) else {
            return nil
        }
        let symmetricKey = SymmetricKey(data: keyData.padWithZeros(targetSize: keySize))
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: AES.GCM.Nonce()).combined
            return sealedBox?.base64EncodedString() ?? nil
        } catch {
            print("AESEncryption: Encryption failed with error \(error)")
            return nil
        }
    }
    
    static func decrypt(encryptedText: String, key: String, keySize: Int = 32) -> String? {
        guard let combinedData = Data(base64Encoded: encryptedText), let keyData = key.data(using: .utf8)?.prefix(keySize) else {
            return nil
        }
        let symmetricKey = SymmetricKey(data: keyData.padWithZeros(targetSize: keySize))
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch let error {
            print("AESEncryption: Decryption failed with error \(error)")
            return nil
        }
    }
}



extension Data {
    func padWithZeros(targetSize: Int) -> Data {
        var paddedData = self
        
        // Get the current size (number of bytes) of the data
        let dataSize = self.count
        
        // Check if padding is needed
        if dataSize < targetSize {
            
            // Calculate the amount of padding required
            let paddingSize = targetSize - dataSize
            
            // Create padding data filled with zeros
            let padding = Data(repeating: 0, count: paddingSize)
            
            // Append the padding to the original data
            paddedData.append(padding)
        }
        return paddedData
    }
}
