////
////  asdasd.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//
//import Foundation
//import Security // Required for Keychain access
//
//// MARK: - Data Models (Ensure BOTH are Codable)
//
//// 1. Standard Tokens (as defined before)
//struct StoredTokens: Codable {
//    let accessToken: String
//    let refreshToken: String?
//    let expiryDate: Date?
//}
//
//// 2. NEW: Keychain-Specific Tokens (Define its structure as needed)
//struct KeychainStoredTokens: Codable {
//    // Example properties - replace with your actual needs
//    let deviceSpecificId: String
//    let encryptedPayload: Data // Example: Some extra data relevant only to this type
//    let creationDate: Date
//    // Add any other properties relevant to this token type
//}
//
//// MARK: - Generic Token Storage Strategy Protocol
///// Defines the interface for saving, loading, and clearing a specific type of authentication token.
///// The protocol is generic over the `TokenType` it manages.
//protocol TokenStorageStrategy<TokenType> where TokenType: Codable {
//    associatedtype TokenType // Explicit declaration of the associated type
//
//    /// Saves the provided tokens securely.
//    /// - Parameter tokens: The `TokenType` object to save.
//    /// - Returns: `true` if saving was successful, `false` otherwise.
//    func saveTokens(_ tokens: TokenType) -> Bool
//
//    /// Loads previously saved tokens of `TokenType`.
//    /// - Returns: The `TokenType` object if found and successfully decoded, otherwise `nil`.
//    func loadTokens() -> TokenType?
//
//    /// Clears any previously saved tokens of `TokenType`.
//    /// - Returns: `true` if clearing was successful or if no tokens existed, `false` on error.
//    func clearTokens() -> Bool
//}
//
//// MARK: - Generic Keychain Token Storage Strategy Implementation
///// Implements the `TokenStorageStrategy` protocol using the iOS Keychain for secure storage.
///// It is generic over the `TokenType` and configured with unique service/account identifiers during initialization.
//final class KeychainTokenStorageStrategy<T: Codable>: TokenStorageStrategy {
//    typealias TokenType = T // Satisfy the associated type requirement
//
//    // --- Configuration ---
//    private let keychainService: String
//    private let keychainAccount: String
//
//    /// Initializes the Keychain strategy for a specific token type.
//    /// - Parameters:
//    ///   - service: A unique string identifying the service for this token type in the Keychain (e.g., "com.yourapp.spotify.standardtokens").
//    ///   - account: A unique string identifying the account/key for this token type within the service (e.g., "userStandardSpotifyTokens").
//    init(service: String, account: String) {
//        guard !service.isEmpty && !account.isEmpty else {
//            // Using fatalError here because empty identifiers would lead to unpredictable Keychain behavior.
//            // Consider throwing an error or using preconditions depending on your error handling strategy.
//            fatalError("Keychain service and account identifiers cannot be empty.")
//        }
//        self.keychainService = service
//        self.keychainAccount = account
//        print("Initialized KeychainStrategy <\(T.self)> for service:'\(service)', account:'\(account)'")
//    }
//
//    /// Saves tokens to the Keychain. Encodes the TokenType object to Data.
//    func saveTokens(_ tokens: TokenType) -> Bool {
//        guard let data = encodeTokens(tokens) else {
//            print("Keychain Error <\(T.self)> [\(keychainService)/\(keychainAccount)]: Failed to encode tokens.")
//            return false
//        }
//
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: keychainService,
//            kSecAttrAccount as String: keychainAccount
//        ]
//
//        let attributesToUpdate: [String: Any] = [
//            kSecValueData as String: data
//        ]
//
//        // Try to update existing item
//        var status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
//
//        // If item doesn't exist, add it
//        if status == errSecItemNotFound {
//            var newItemQuery = query
//            newItemQuery[kSecValueData as String] = data
//            newItemQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Accessibility
//            status = SecItemAdd(newItemQuery as CFDictionary, nil)
//        }
//
//        if status != errSecSuccess {
//            print("Keychain Error <\(T.self)> [\(keychainService)/\(keychainAccount)]: Failed to save. Status: \(status) (\(keychainErrorToString(status)))")
//        }
//
//        return status == errSecSuccess
//    }
//
//    /// Loads tokens from the Keychain. Retrieves the Data and decodes it back to TokenType.
//    func loadTokens() -> TokenType? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: keychainService,
//            kSecAttrAccount as String: keychainAccount,
//            kSecReturnData as String: kCFBooleanTrue!,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//
//        guard status == errSecSuccess else {
//            if status != errSecItemNotFound {
//                print("Keychain Error <\(T.self)> [\(keychainService)/\(keychainAccount)]: Failed to load. Status: \(status) (\(keychainErrorToString(status)))")
//            }
//            return nil
//        }
//
//        guard let data = item as? Data else {
//            print("Keychain Error <\(T.self)> [\(keychainService)/\(keychainAccount)]: Failed to cast retrieved item to Data.")
//            return nil
//        }
//
//        guard let decodedTokens = decodeTokens(from: data) else {
//            print("Keychain Error <\(T.self)> [\(keychainService)/\(keychainAccount)]: Failed to decode data.")
//            // It might be wise to clear the corrupted data here to prevent future load failures.
//            // clearTokens()
//            return nil
//        }
//        return decodedTokens
//    }
//
//    /// Deletes the tokens from the Keychain.
//    func clearTokens() -> Bool {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: keychainService,
//            kSecAttrAccount as String: keychainAccount
//        ]
//
//        let status = SecItemDelete(query as CFDictionary)
//
//        if status != errSecSuccess && status != errSecItemNotFound {
//            print("Keychain Error <\(T.self)> [\(keychainService)/\(keychainAccount)]: Failed to clear. Status: \(status) (\(keychainErrorToString(status)))")
//        }
//
//        return status == errSecSuccess || status == errSecItemNotFound
//    }
//
//    // MARK: - Helpers
//
//    // These helpers work for any Codable type T
//    private func encodeTokens(_ tokens: T) -> Data? {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601 // Keep consistent date strategy
//        return try? encoder.encode(tokens)
//    }
//
//    private func decodeTokens(from data: Data) -> T? {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601 // Keep consistent date strategy
//        return try? decoder.decode(T.self, from: data)
//    }
//
//    private func keychainErrorToString(_ status: OSStatus) -> String {
//         return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown OSStatus \(status)"
//     }
//}
//
//// MARK: - (Optional) Generic UserDefaults Strategy
///// Example generic implementation using UserDefaults (Less Secure).
///// Useful for demonstrating the pattern or non-sensitive data.
//final class UserDefaultsTokenStorageStrategy<T: Codable>: TokenStorageStrategy {
//    typealias TokenType = T
//
//    private let userDefaultsKey: String
//
//    /// Initializes the UserDefaults strategy for a specific token type.
//    /// - Parameter key: A unique key to use in UserDefaults for this token type.
//    init(key: String) {
//        guard !key.isEmpty else {
//            fatalError("UserDefaults key cannot be empty.")
//        }
//        self.userDefaultsKey = key
//        print("Initialized UserDefaultsStrategy <\(T.self)> for key:'\(key)'")
//    }
//
//    func saveTokens(_ tokens: TokenType) -> Bool {
//        guard let data = encodeTokens(tokens) else {
//            print("UserDefaults Error <\(T.self)> [\(userDefaultsKey)]: Failed to encode tokens.")
//            return false
//        }
//        UserDefaults.standard.set(data, forKey: userDefaultsKey)
//        return true
//    }
//
//    func loadTokens() -> TokenType? {
//        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
//            return nil
//        }
//        guard let decoded = decodeTokens(from: data) else {
//            print("UserDefaults Error <\(T.self)> [\(userDefaultsKey)]: Failed to decode data.")
//            // UserDefaults.standard.removeObject(forKey: userDefaultsKey) // Optionally clear bad data
//            return nil
//        }
//        return decoded
//    }
//
//    func clearTokens() -> Bool {
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//        return true
//    }
//
//    // MARK: - Helpers
//    private func encodeTokens(_ tokens: T) -> Data? {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        return try? encoder.encode(tokens)
//    }
//
//    private func decodeTokens(from data: Data) -> T? {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        return try? decoder.decode(T.self, from: data)
//    }
//}
