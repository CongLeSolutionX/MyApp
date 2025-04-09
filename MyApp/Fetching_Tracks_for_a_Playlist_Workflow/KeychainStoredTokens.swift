////
////  TokenStorage.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//
//import Foundation
//import Security // Required for Keychain access
//
//// MARK: - Data Models (Ensure StoredTokens is defined as Codable)
//// Make sure this struct definition exists or is accessible here.
//// It should match the one used in SpotifyAuthManager.
//struct KeychainStoredTokens: Codable {
//    let accessToken: String
//    let refreshToken: String?
//    let expiryDate: Date?
//}
//
//// MARK: - Token Storage Strategy Protocol
///// Defines the interface for saving, loading, and clearing authentication tokens.
///// This allows different storage mechanisms (UserDefaults, Keychain) to be used interchangeably.
//protocol TokenStorageStrategy {
//    /// Saves the provided tokens securely.
//    /// - Parameter tokens: The `StoredTokens` object to save.
//    /// - Returns: `true` if saving was successful, `false` otherwise.
//    func saveTokens(_ tokens: KeychainStoredTokens) -> Bool
//
//    /// Loads previously saved tokens.
//    /// - Returns: The `StoredTokens` object if found and successfully decoded, otherwise `nil`.
//    func loadTokens() -> KeychainStoredTokens?
//
//    /// Clears any previously saved tokens.
//    /// - Returns: `true` if clearing was successful or if no tokens existed, `false` on error.
//    func clearTokens() -> Bool
//}
//
//// MARK: - Keychain Token Storage Strategy Implementation
///// Implements the `TokenStorageStrategy` protocol using the iOS Keychain for secure storage.
//final class KeychainTokenStorageStrategy: TokenStorageStrategy {
//
//    // Define unique identifiers for the Keychain item.
//    // Best practice: Use your app's bundle ID or a unique domain.
//    private let keychainService = "tech.CongLeSolutionX.myapp.spotify.tokens" // <-- REPLACE with your unique service name
//    private let keychainAccount = "userSpotifyTokens"
//
//    /// Saves tokens to the Keychain. Encodes the StoredTokens object to Data.
//    /// It attempts to update an existing item first, and adds a new one if not found.
//    func saveTokens(_ tokens: KeychainStoredTokens) -> Bool {
//        guard let data = encodeTokens(tokens) else {
//            print("Keychain Error: Failed to encode tokens.")
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
//            // Add accessibility option - kSecAttrAccessibleWhenUnlockedThisDeviceOnly is a common choice
//            // Adjust if your app needs background access (e.g., kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
//            newItemQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
//            status = SecItemAdd(newItemQuery as CFDictionary, nil)
//        }
//
//        if status != errSecSuccess {
//             print("Keychain Error: Failed to save tokens. Status: \(status) (\(keychainErrorToString(status)))")
//        }
//
//        return status == errSecSuccess
//    }
//
//    /// Loads tokens from the Keychain. Retrieves the Data and decodes it back to StoredTokens.
//    func loadTokens() -> KeychainStoredTokens? {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: keychainService,
//            kSecAttrAccount as String: keychainAccount,
//            kSecReturnData as String: kCFBooleanTrue!, // Return the data
//            kSecMatchLimit as String: kSecMatchLimitOne // Expect only one item
//        ]
//
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//
//        guard status == errSecSuccess else {
//            if status != errSecItemNotFound { // It's okay if not found, just means no saved tokens
//                print("Keychain Error: Failed to load tokens. Status: \(status) (\(keychainErrorToString(status)))")
//            }
//            return nil
//        }
//
//        guard let data = item as? Data else {
//            print("Keychain Error: Failed to cast retrieved item to Data.")
//            return nil
//        }
//
//        return decodeTokens(from: data)
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
//        // errSecItemNotFound is acceptable here (means it was already cleared)
//        if status != errSecSuccess && status != errSecItemNotFound {
//            print("Keychain Error: Failed to clear tokens. Status: \(status) (\(keychainErrorToString(status)))")
//        }
//
//        return status == errSecSuccess || status == errSecItemNotFound
//    }
//
//    // MARK: - Helpers
//
//    private func encodeTokens(_ tokens: KeychainStoredTokens) -> Data? {
//        let encoder = JSONEncoder()
//         // Optional: Use date encoding strategy if needed, though default ISO8601 should work
//        encoder.dateEncodingStrategy = .iso8601
//        return try? encoder.encode(tokens)
//    }
//
//    private func decodeTokens(from data: Data) -> KeychainStoredTokens? {
//        let decoder = JSONDecoder()
//         // Optional: Match date decoding strategy if needed
//        decoder.dateDecodingStrategy = .iso8601
//        return try? decoder.decode(KeychainStoredTokens.self, from: data)
//    }
//
//     // Helper to get a descriptive string for Keychain errors (Optional but helpful)
//     private func keychainErrorToString(_ status: OSStatus) -> String {
//         return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown OSStatus \(status)"
//     }
//}
//
//// MARK: - (Optional) UserDefaults Token Storage Strategy Implementation
///// Example implementation using UserDefaults (Less Secure - Not Recommended for Tokens)
///// Kept here for comparison and demonstration of the strategy pattern.
//final class UserDefaultsTokenStorageStrategy: TokenStorageStrategy {
//
//    private let userDefaultsKey = "spotifyTokens_UserDefaultsStrategy" // Use a distinct key
//
//    func saveTokens(_ tokens: KeychainStoredTokens) -> Bool {
//        guard let data = encodeTokens(tokens) else {
//            print("UserDefaults Error: Failed to encode tokens.")
//            return false
//        }
//        UserDefaults.standard.set(data, forKey: userDefaultsKey)
//        return true // UserDefaults set doesn't directly report errors like Keychain
//    }
//
//    func loadTokens() -> KeychainStoredTokens? {
//        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
//            return nil // No data found for the key
//        }
//        return decodeTokens(from: data)
//    }
//
//    func clearTokens() -> Bool {
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
//        return true // UserDefaults remove doesn't report errors
//    }
//
//    // MARK: - Helpers (Shared logic can be extracted if desired)
//
//    private func encodeTokens(_ tokens: KeychainStoredTokens) -> Data? {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        return try? encoder.encode(tokens)
//    }
//
//    private func decodeTokens(from data: Data) -> KeychainStoredTokens? {
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        return try? decoder.decode(KeychainStoredTokens.self, from: data)
//    }
//}
