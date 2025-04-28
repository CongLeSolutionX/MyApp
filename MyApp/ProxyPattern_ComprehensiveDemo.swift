//
//  ProxyPattern_ComprehensiveDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import Foundation
import UIKit // For UIImageView example, though not strictly needed for core pattern


// MARK: - 1. Subject Protocol

/// Defines the common interface for both the Real Subject and the Proxies.
/// Clients interact with objects conforming to this protocol.
protocol FileDownloader {
    func downloadFile(url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

// Custom Error for Demonstration
enum DownloadError: Error, LocalizedError {
    case accessDenied
    case downloadFailed(reason: String)
    case cachingError

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access Denied: You do not have permission to download this file."
        case .downloadFailed(let reason):
            return "Download Failed: \(reason)"
        case .cachingError:
            return "Caching Error: Could not retrieve or store the file in cache."
        }
    }
}

// MARK: - 2. Real Subject

/// The actual object that performs the core task (downloading the file).
/// Often resource-intensive to create or operate.
class RealFileDownloader: FileDownloader {

    private var activeDownloads: [URL: URLSessionDataTask] = [:]
    private let session: URLSession

    init(sessionConfiguration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: sessionConfiguration)
        print("➡️ RealFileDownloader: Initialized. Ready to download.")
    }

    func downloadFile(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        print("➡️ RealFileDownloader: Starting download for \(url.lastPathComponent)...")

        // Prevent downloading the same URL multiple times concurrently
        guard activeDownloads[url] == nil else {
            print("➡️ RealFileDownloader: Download for \(url.lastPathComponent) already in progress.")
            // Optionally, queue the completion handler or return an error
            // For simplicity, we don't handle queueing here.
            return
        }

        let task = session.dataTask(with: url) { [weak self] data, response, error in
            // Ensure task is removed once completed
            defer {
                DispatchQueue.main.async { // Ensure thread safety for dictionary access
                    self?.activeDownloads[url] = nil
                }
            }

            if let error = error {
                print("➡️ RealFileDownloader: Download failed for \(url.lastPathComponent). Error: \(error.localizedDescription)")
                completion(.failure(DownloadError.downloadFailed(reason: error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("➡️ RealFileDownloader: Download failed for \(url.lastPathComponent). Invalid status code: \(statusCode)")
                completion(.failure(DownloadError.downloadFailed(reason: "Invalid server response (Status: \(statusCode))")))
                return
            }

            guard let data = data else {
                print("➡️ RealFileDownloader: Download failed for \(url.lastPathComponent). No data received.")
                completion(.failure(DownloadError.downloadFailed(reason: "No data received from server")))
                return
            }

            print("➡️ RealFileDownloader: Successfully downloaded \(url.lastPathComponent) (\(data.count) bytes).")
            completion(.success(data))
        }

        DispatchQueue.main.async { // Ensure thread safety for dictionary access
             self.activeDownloads[url] = task
        }
        task.resume()
    }

    deinit {
        print("➡️ RealFileDownloader: Deinitialized. Cancelling any active tasks.")
        // Cancel any ongoing downloads when the real downloader is deallocated
         activeDownloads.values.forEach { $0.cancel() }
    }
}


// MARK: - 3. Proxy Implementations

// --- 3a. Virtual Proxy ---

/// Delays the creation of the Real Subject until it's actually needed (lazy initialization).
class VirtualFileDownloaderProxy: FileDownloader {
    private var realDownloader: RealFileDownloader? // Lazily instantiated

    init() {
        print("🅿️ VirtualProxy: Initialized. Real downloader NOT created yet.")
    }

    // Lazy creation of the Real Subject
    private func getRealDownloader() -> RealFileDownloader {
        if realDownloader == nil {
            print("🅿️ VirtualProxy: Access requested. Creating RealFileDownloader instance now...")
            realDownloader = RealFileDownloader()
        }
        return realDownloader!
    }

    func downloadFile(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        print("🅿️ VirtualProxy: Intercepted download request for \(url.lastPathComponent).")
        // Accessing the real downloader triggers its creation if needed
        getRealDownloader().downloadFile(url: url, completion: completion)
    }

     deinit {
         print("🅿️ VirtualProxy: Deinitialized.")
     }
}

// --- 3b. Protection Proxy ---

/// Controls access to the Real Subject based on certain criteria (e.g., user roles).
class ProtectionFileDownloaderProxy: FileDownloader {
    // The Protection Proxy wraps another FileDownloader (could be RealSubject or another Proxy)
    private let wrappedDownloader: FileDownloader
    private let userRole: UserRole // Example access control parameter

    enum UserRole {
        case guest
        case premiumUser
        case administrator
    }

    // Example: Define which URLs require which roles
    private func requiresAdminAccess(_ url: URL) -> Bool {
        return url.absoluteString.contains("admin_files")
    }

    private func requiresPremiumAccess(_ url: URL) -> Bool {
         return url.absoluteString.contains("premium_content")
    }

    init(wrapping downloader: FileDownloader, userRole: UserRole) {
        self.wrappedDownloader = downloader
        self.userRole = userRole
        print("🛡️ ProtectionProxy: Initialized for user role '\(userRole)'. Wrapping \(type(of: downloader)).")
    }

    private func checkAccess(for url: URL) -> Bool {
        print("🛡️ ProtectionProxy: Checking access for \(url.lastPathComponent) (User Role: \(userRole))...")
        if requiresAdminAccess(url) {
            let hasAccess = (userRole == .administrator)
            print("🛡️ ProtectionProxy: Admin access required. Access \(hasAccess ? "GRANTED" : "DENIED").")
            return hasAccess
        } else if requiresPremiumAccess(url) {
            let hasAccess = (userRole == .premiumUser || userRole == .administrator)
             print("🛡️ ProtectionProxy: Premium access required. Access \(hasAccess ? "GRANTED" : "DENIED").")
             return hasAccess
        } else {
             // Assume public access if not specifically restricted
             print("🛡️ ProtectionProxy: Public access assumed. Access GRANTED.")
             return true
        }
    }

    func downloadFile(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        print("🛡️ ProtectionProxy: Intercepted download request for \(url.lastPathComponent).")
        if checkAccess(for: url) {
            print("🛡️ ProtectionProxy: Access permitted. Forwarding request...")
            wrappedDownloader.downloadFile(url: url, completion: completion)
        } else {
            print("🛡️ ProtectionProxy: Access DENIED for \(url.lastPathComponent).")
            completion(.failure(DownloadError.accessDenied))
        }
    }

     deinit {
         print("🛡️ ProtectionProxy: Deinitialized.")
     }
}

// --- 3c. Smart Proxy (Caching Example) ---

/// Adds extra logic like caching results without modifying the Real Subject.
class CachingFileDownloaderProxy: FileDownloader {
    // Wraps another FileDownloader
    private let wrappedDownloader: FileDownloader
    private var cache: [URL: Data] = [:] // Simple in-memory cache
    private let cacheQueue = DispatchQueue(label: "com.example.cacheQueue", attributes: .concurrent)

    init(wrapping downloader: FileDownloader) {
        self.wrappedDownloader = downloader
        print("💾 CachingProxy: Initialized. Wrapping \(type(of: downloader)).")
    }

    private func getFromCache(url: URL) -> Data? {
        var cachedData: Data?
        // Use .sync barrier for safe read after potential writes
        cacheQueue.sync {
            cachedData = self.cache[url]
        }
         if cachedData != nil {
             print("💾 CachingProxy: Cache HIT for \(url.lastPathComponent).")
         } else {
             print("💾 CachingProxy: Cache MISS for \(url.lastPathComponent).")
         }
        return cachedData
    }

    private func saveToCache(url: URL, data: Data) {
         // Use .async barrier for safe write
        cacheQueue.async(flags: .barrier) {
            self.cache[url] = data
             print("💾 CachingProxy: Saved \(data.count) bytes to cache for \(url.lastPathComponent).")
        }
    }

    func downloadFile(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        print("💾 CachingProxy: Intercepted download request for \(url.lastPathComponent).")

        // 1. Check Cache
        if let cachedData = getFromCache(url: url) {
            print("💾 CachingProxy: Returning data from cache for \(url.lastPathComponent).")
            // Return cached data immediately on the main thread for consistency
            DispatchQueue.main.async {
                completion(.success(cachedData))
            }
            return
        }

        // 2. Cache Miss: Forward request to the wrapped downloader
        print("💾 CachingProxy: Forwarding request to wrapped downloader...")
        wrappedDownloader.downloadFile(url: url) { [weak self] result in
            switch result {
            case .success(let data):
                // 3. On Success: Cache the result
                print("💾 CachingProxy: Received successful download. Attempting to cache...")
                self?.saveToCache(url: url, data: data)
                // Forward the success result
                 DispatchQueue.main.async {
                     completion(.success(data))
                 }
            case .failure(let error):
                // 4. On Failure: Forward the error
                print("💾 CachingProxy: Received failure from wrapped downloader.")
                 DispatchQueue.main.async {
                     completion(.failure(error))
                 }
            }
        }
    }

     deinit {
         print("💾 CachingProxy: Deinitialized.")
     }

}

// MARK: - 4. Client Usage Examples
//
//print("\n--- Example 1: Using Virtual Proxy (Lazy Loading) ---")
//
//// Client interacts via the protocol, unaware of lazy loading details
//var lazyDownloader: FileDownloader = VirtualFileDownloaderProxy()
//let dummyURL1 = URL(string: "https://example.com/file1.txt")!
//
//print("Client: lazyDownloader created. Requesting download...")
//// Only now will the RealFileDownloader potentially be created inside the proxy
//lazyDownloader.downloadFile(url: dummyURL1) { result in
//    switch result {
//    case .success(let data):
//        print("Client (Virtual): Download succeeded! Data size: \(data.count)")
//    case .failure(let error):
//        print("Client (Virtual): Download failed! Error: \(error.localizedDescription)")
//    }
//}
//// Keep the script running for async operations
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 3)) // Simulate waiting for download
//
//
//print("\n--- Example 2: Using Protection Proxy ---")
//let baseDownloader = RealFileDownloader() // Or could be the VirtualProxy
//let guestURL = URL(string: "https://example.com/public/guest_file.zip")!
//let premiumURL = URL(string: "https://example.com/premium_content/movie.mp4")!
//let adminURL = URL(string: "https://example.com/admin_files/config.json")!
//
//// Scenario A: Guest User
//print("\nClient: Simulating GUEST user...")
//var guestDownloader: FileDownloader = ProtectionFileDownloaderProxy(wrapping: baseDownloader, userRole: .guest)
//
//print("Client (Guest): Attempting to download guest file...")
//guestDownloader.downloadFile(url: guestURL) { result in print("Client (Guest - Guest File): Result: \(result)") }
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
//
//print("\nClient (Guest): Attempting to download premium file...")
//guestDownloader.downloadFile(url: premiumURL) { result in print("Client (Guest - Premium File): Result: \(result)") }
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
//
//print("\nClient (Guest): Attempting to download admin file...")
//guestDownloader.downloadFile(url: adminURL) { result in print("Client (Guest - Admin File): Result: \(result)") }
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
//
//// Scenario B: Premium User
//print("\nClient: Simulating PREMIUM user...")
//var premiumDownloader: FileDownloader = ProtectionFileDownloaderProxy(wrapping: baseDownloader, userRole: .premiumUser)
//
//print("Client (Premium): Attempting to download premium file...")
//premiumDownloader.downloadFile(url: premiumURL) { result in print("Client (Premium - Premium File): Result: \(result)") }
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 3)) // Simulate download
//
//print("\nClient (Premium): Attempting to download admin file...")
//premiumDownloader.downloadFile(url: adminURL) { result in print("Client (Premium - Admin File): Result: \(result)") }
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
//
//print("\n--- Example 3: Using Caching Proxy ---")
//let dummyURL2 = URL(string: "https://example.com/file2.jpg")!
//var cachingDownloader: FileDownloader = CachingFileDownloaderProxy(wrapping: baseDownloader) // Wrap the real downloader
//
//print("\nClient (Caching): First download attempt for file2.jpg...")
//cachingDownloader.downloadFile(url: dummyURL2) { result in
//     print("Client (Caching - 1st attempt): Result: \(result)")
//}
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 3)) // Simulate download & caching
//
//print("\nClient (Caching): Second download attempt for file2.jpg...")
//cachingDownloader.downloadFile(url: dummyURL2) { result in
//     print("Client (Caching - 2nd attempt): Result: \(result)") // Should hit cache
//}
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Should be fast
//
//
//print("\n--- Example 4: Chaining Proxies ---")
//// Real -> Virtual -> Caching -> Protection
//// Order matters! Protection check should likely happen first.
//// Let's do: Protection -> Caching -> Virtual -> Real (if needed)
//
//let baseVirtualDownloader = VirtualFileDownloaderProxy() // Start with lazy loading
//let cachingLayer = CachingFileDownloaderProxy(wrapping: baseVirtualDownloader)
//let finalDownloader: FileDownloader = ProtectionFileDownloaderProxy(wrapping: cachingLayer, userRole: .administrator) // Admin user
//
//let complexURL = URL(string: "https://example.com/admin_files/complex_report.pdf")!
//
//print("\nClient (Chained): First download attempt (Admin User)...")
//finalDownloader.downloadFile(url: complexURL) { result in
//    print("Client (Chained - 1st attempt): Result: \(result)")
//    // Expected flow: Protection (OK) -> Caching (Miss) -> Virtual (Creates Real) -> Real (Downloads) -> Virtual (Returns) -> Caching (Caches) -> Protection (Returns)
//}
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 4)) // Allow time for full flow
//
//print("\nClient (Chained): Second download attempt (Admin User)...")
//finalDownloader.downloadFile(url: complexURL) { result in
//    print("Client (Chained - 2nd attempt): Result: \(result)")
//     // Expected flow: Protection (OK) -> Caching (Hit) -> Protection (Returns)
//}
//RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Should be fast due to cache
//
//print("\n--- End of Demonstrations ---")
