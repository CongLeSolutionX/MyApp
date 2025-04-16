//
//  SpotifyEmbedView_V7.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import WebKit
import AuthenticationServices
import Combine
import CommonCrypto

// MARK: - Constants & Config

fileprivate let clientID = "YOUR_CLIENT_ID"
fileprivate let redirectURI = URL(string: "myapp://callback")! // Change to your registered redirect URI
fileprivate let scopes = ["user-read-email", "user-read-private"] // Adjust scopes as needed

// MARK: - Spotify PKCE Helper

fileprivate func randomString(length: Int = 128) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
    return String((0..<length).compactMap { _ in letters.randomElement() })
}

fileprivate func sha256(_ input: String) -> Data {
    guard let inputData = input.data(using: .utf8) else { return Data() }
    #if canImport(CommonCrypto)
    
    var hash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
    _ = hash.withUnsafeMutableBytes { hashBytes in
        inputData.withUnsafeBytes { dataBytes in
            CC_SHA256(dataBytes.baseAddress, CC_LONG(inputData.count), hashBytes.bindMemory(to: UInt8.self).baseAddress)
        }
    }
    return hash
    #else
    return Data() // fallback if CommonCrypto unavailable
    #endif
}

fileprivate func base64URLEncode(_ data: Data) -> String {
    var base64 = data.base64EncodedString()
    base64 = base64.replacingOccurrences(of: "+", with: "-")
    base64 = base64.replacingOccurrences(of: "/", with: "_")
    base64 = base64.replacingOccurrences(of: "=", with: "")
    return base64
}

// MARK: - SpotifyAuthManager: OAuth with PKCE, token handling

final class SpotifyAuthManager: ObservableObject {
    @Published private(set) var accessToken: String?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var userName: String?

    private var refreshToken: String?
    private var expirationDate: Date?

    private var codeVerifier: String?

    private var authSession: ASWebAuthenticationSession?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load previous tokens if saved (simple UserDefaults for demo)
        accessToken = UserDefaults.standard.string(forKey: "spotifyAccessToken")
        refreshToken = UserDefaults.standard.string(forKey: "spotifyRefreshToken")
        expirationDate = UserDefaults.standard.object(forKey: "spotifyExpirationDate") as? Date
        updateAuthStatus()

        // Listen for token expiration and refresh automatically (not implemented here for brevity)
    }

    private func updateAuthStatus() {
        if let expiration = expirationDate, expiration > Date() && accessToken != nil {
            isAuthenticated = true
            fetchUserProfile()
        } else {
            isAuthenticated = false
        }
    }

    func signIn() {
        // Generate code verifier and challenge for PKCE
        codeVerifier = randomString(length: 128)
        guard let codeVerifier = codeVerifier else { return }
        let codeChallenge = base64URLEncode(sha256(codeVerifier))

        // Construct authorization URL
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "show_dialog", value: "true")
        ]

        guard let authURL = components.url else { return }

        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: redirectURI.scheme) { [weak self] callbackURL, error in
            guard error == nil, let callbackURL = callbackURL else {
                print("Authorization failed or cancelled")
                return
            }
            self?.handleAuthorizationCallback(url: callbackURL)
        }
        authSession?.presentationContextProvider = self
        authSession?.start()
    }

    private func handleAuthorizationCallback(url: URL) {
        // Parse url parameters & request access token
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
            let codeVerifier = codeVerifier
        else {
            print("Failed to get authorization code")
            return
        }

        fetchAccessToken(code: code, codeVerifier: codeVerifier)
    }

    private func fetchAccessToken(code: String, codeVerifier: String) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "code_verifier", value: codeVerifier)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResp = response as? HTTPURLResponse,
                      200..<300 ~= httpResp.statusCode else {
                          let str = String(data: data, encoding: .utf8) ?? "n/a"
                          throw URLError(.badServerResponse, userInfo: ["response": str])
                      }
                return data
            }
            .decode(type: SpotifyTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let err):
                    print("Access token fetching error: \(err.localizedDescription)")
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.saveTokens(response: tokenResponse)
                self?.updateAuthStatus()
            }
            .store(in: &cancellables)
    }

    private func saveTokens(response: SpotifyTokenResponse) {
        accessToken = response.access_token
        refreshToken = response.refresh_token
        expirationDate = Date().addingTimeInterval(TimeInterval(response.expires_in))

        // Save to UserDefaults for demo persistence
        UserDefaults.standard.setValue(accessToken, forKey: "spotifyAccessToken")
        UserDefaults.standard.setValue(refreshToken, forKey: "spotifyRefreshToken")
        UserDefaults.standard.setValue(expirationDate, forKey: "spotifyExpirationDate")
    }

    func signOut() {
        accessToken = nil
        refreshToken = nil
        expirationDate = nil
        userName = nil
        isAuthenticated = false
        // Clear tokens stored
        UserDefaults.standard.removeObject(forKey: "spotifyAccessToken")
        UserDefaults.standard.removeObject(forKey: "spotifyRefreshToken")
        UserDefaults.standard.removeObject(forKey: "spotifyExpirationDate")
    }

    func refreshAccessTokenIfNeeded(completion: @escaping () -> Void) {
        // Implement refresh token logic here if desired
        // For this demo, skipping refresh implementation
        completion()
    }

    private func fetchUserProfile() {
        guard let token = accessToken else { return }
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResp = response as? HTTPURLResponse,
                      200..<300 ~= httpResp.statusCode else {
                          throw URLError(.badServerResponse)
                      }
                return data
            }
            .decode(type: SpotifyUserProfile.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let err) = completion {
                    print("Fetch user profile error: \(err.localizedDescription)")
                }
            } receiveValue: { [weak self] profile in
                self?.userName = profile.display_name
            }
            .store(in: &cancellables)
    }
}

extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
    func isEqual(_ object: Any?) -> Bool {
        return true
    }
    
    var hash: Int {
        return 0
    }
    
    var superclass: AnyClass? {
        return nil
    }
    
    func `self`() -> Self {
        return self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return Unmanaged.passUnretained(self)
    }
    
    func isProxy() -> Bool {
        return true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
    
    var description: String {
        return ""
    }
    
    // Use the key window as the presentation anchor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Updated to find the key window more reliably
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return keyWindow ?? ASPresentationAnchor()
    }
    
}

// MARK: - Spotify API Response Models

fileprivate struct SpotifyTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
    let refresh_token: String?
}

fileprivate struct SpotifyUserProfile: Decodable {
    let display_name: String
}

// MARK: - SpotifyAPIClient: Handle fetching Track or Episode details

final class SpotifyAPIClient {
    let authManager: SpotifyAuthManager

    init(authManager: SpotifyAuthManager) {
        self.authManager = authManager
    }

    enum SpotifyItemType: String {
        case track, episode
    }

    struct SpotifyTrack: Decodable {
        let id: String
        let name: String
        let album: SpotifyAlbum
        let artists: [SpotifyArtist]
        let duration_ms: Int
        let release_date: String?
        let external_urls: [String: String]
        let description: String? // Sometimes nil for tracks

        // We will parse description only for episodes, so optional here
    }

    struct SpotifyEpisode: Decodable {
        let id: String
        let name: String
        let description: String?
        let release_date: String
        let duration_ms: Int
        let external_urls: [String: String]
    }

    struct SpotifyAlbum: Decodable {
        let name: String
        let images: [SpotifyImage]
    }

    struct SpotifyArtist: Decodable {
        let name: String
    }

    struct SpotifyImage: Decodable {
        let url: String
        let height: Int?
        let width: Int?
    }

    func fetchItemDetails(id: String, type: SpotifyItemType) async throws -> TrackDetails {
        guard let token = authManager.accessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        let urlString = "https://api.spotify.com/v1/\(type.rawValue)s/\(id)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResp = response as? HTTPURLResponse,
              200..<300 ~= httpResp.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        switch type {
        case .track:
            let result = try JSONDecoder().decode(SpotifyTrack.self, from: data)
            return TrackDetails(
                id: "spotify:track:\(result.id)",
                title: result.name,
                artistName: result.artists.first?.name ?? "Unknown Artist",
                albumTitle: result.album.name,
                artworkURL: URL(string: result.album.images.first?.url ?? ""),
                durationMs: result.duration_ms,
                releaseDate: Self.dateFormatter.date(from: result.release_date ?? ""),
                description: nil,
                isEpisode: false
            )
        case .episode:
            let result = try JSONDecoder().decode(SpotifyEpisode.self, from: data)
            return TrackDetails(
                id: "spotify:episode:\(result.id)",
                title: result.name,
                artistName: "Unknown Podcast",
                albumTitle: nil,
                artworkURL: nil, // Episodes do not have artwork in this simplified call; extra calls needed for show info
                durationMs: result.duration_ms,
                releaseDate: Self.dateFormatter.date(from: result.release_date),
                description: result.description,
                isEpisode: true
            )
        }
    }

    private static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

// MARK: - TrackDetails struct: unified for UI

struct TrackDetails: Identifiable, Equatable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: URL?
    let durationMs: Int
    let releaseDate: Date?
    let description: String?
    let isEpisode: Bool

    var formattedDuration: String {
        let totalSeconds = durationMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedReleaseDate: String {
        guard let date = releaseDate else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var webLink: URL? {
        // Convert Spotify URI format spotify:type:id to https://open.spotify.com/type/id
        let parts = id.split(separator: ":")
        guard parts.count == 3 else { return nil }
        return URL(string: "https://open.spotify.com/\(parts[1])/\(parts[2])")
    }
}

// MARK: - SpotifyEmbedWebView (same as previous, simplified for brevity)

struct SpotifyEmbedWebView: UIViewRepresentable {
    let spotifyUri: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        let html = generateHTML(uri: spotifyUri)
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Reload if uri changes
        let script = "document.getElementById('spotify-embed').src = 'https://open.spotify.com/embed/\(spotifyType(from: spotifyUri))/\(spotifyID(from: spotifyUri))';"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    private func spotifyType(from uri: String) -> String {
        let components = uri.split(separator: ":")
        guard components.count >= 3 else { return "track" }
        return String(components[1])
    }

    private func spotifyID(from uri: String) -> String {
        let components = uri.split(separator: ":")
        guard components.count >= 3 else { return "" }
        return String(components[2])
    }

    private func generateHTML(uri: String) -> String {
        let type = spotifyType(from: uri)
        let id = spotifyID(from: uri)
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body, html {
            margin:0; padding:0; background: transparent; overflow: hidden;
            height: 100%; width:100%;
          }
          iframe {
            border:none;
            width:100%; height:100%;
          }
        </style>
        </head>
        <body>
          <iframe id="spotify-embed" src="https://open.spotify.com/embed/\(type)/\(id)" allow="autoplay" allowtransparency="true" allowfullscreen="true" sandbox="allow-scripts allow-same-origin allow-popups"></iframe>
        </body>
        </html>
        """
    }
}

// MARK: - SpotifyEmbedCardView

struct SpotifyEmbedCardView: View {
    let trackData: TrackDetails
    @State private var showingFullDetails = false

    var body: some View {
        VStack(spacing: 8) {
            SpotifyEmbedWebView(spotifyUri: trackData.id)
                .frame(height: 80)
                .cornerRadius(6)
                .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(trackData.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(trackData.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            HStack(spacing: 10) {
                Button {
                    showingFullDetails = true
                } label: {
                    Label("Details", systemImage: "info.circle")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                if let url = trackData.webLink {
                    ShareLink(item: url) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .labelStyle(.iconOnly)
                }

                Spacer()
            }
        }
        .padding()
        .background(Material.bar)
        .cornerRadius(12)
        .sheet(isPresented: $showingFullDetails) {
            NavigationView {
                TrackDetailsView(track: trackData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showingFullDetails = false }
                        }
                    }
            }
        }
    }
}

#Preview("Spotify Embed Card View") {
    SpotifyEmbedCardView(trackData: TrackDetails(id: "asdad", title: "asdad", artistName: "asdasd", albumTitle: "asdasd", artworkURL: nil, durationMs: 1000, releaseDate: nil, description: nil, isEpisode: false))
}

// MARK: - TrackDetailsView: Display detailed info

struct TrackDetailsView: View {
    let track: TrackDetails

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let artwork = track.artworkURL {
                    AsyncImage(url: artwork) { phase in
                        switch phase {
                        case .empty: ProgressView().frame(height: 240)
                        case .success(let img):
                            img.resizable().aspectRatio(contentMode: .fit).cornerRadius(12).shadow(radius: 5)
                        case .failure:
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 240)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: track.isEpisode ? "mic.fill" : "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(track.title).font(.title).bold()
                    Text(track.artistName).font(.title3).foregroundColor(.secondary)

                    if let album = track.albumTitle {
                        Text(track.isEpisode ? "Podcast: \(album)" : "Album: \(album)")
                            .font(.headline)
                            .foregroundColor(track.isEpisode ? .purple : .accentColor)
                    }
                    HStack {
                        Label(track.formattedDuration, systemImage: "clock")
                        Spacer()
                        Label(track.formattedReleaseDate, systemImage: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    if let desc = track.description, !desc.isEmpty {
                        Divider()
                        Text(track.isEpisode ? "Episode Notes" : "About")
                            .font(.title3)
                            .bold()
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle(track.isEpisode ? "Episode Details" : "Track Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Track Details View") {
    TrackDetailsView(track: TrackDetails(id: "asdad", title: "asdad", artistName: "asdasd", albumTitle: "asdasd", artworkURL: nil, durationMs: 1000, releaseDate: nil, description: nil, isEpisode: false))
}

// MARK: - Main ContentView

struct SpotifyEmbedView: View {
    @StateObject private var auth = SpotifyAuthManager()
    @State private var fetchedTrack: TrackDetails? = nil
    @State private var fetchingError: String? = nil
    @State private var isLoading: Bool = false

    var spotifyAPIClient: SpotifyAPIClient { SpotifyAPIClient(authManager: auth) }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if auth.isAuthenticated {
                    Text("Welcome, \(auth.userName ?? "User")!")
                        .font(.headline)

                    if let track = fetchedTrack {
                        SpotifyEmbedCardView(trackData: track)
                            .padding(.horizontal)
                    } else {
                        Text("Click a button below to fetch a Spotify Track or Episode from API")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if let err = fetchingError {
                        Text("Error: \(err)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                    }

                    HStack(spacing: 20) {
                        Button("Fetch Track") {
                            Task {
                                await fetchSpotify(id: "11dFghVXANMlKmJXsNCbNl", type: .track)
                            }
                        }
                        Button("Fetch Episode") {
                            Task {
                                await fetchSpotify(id: "7makk4oTQel546B0PZlDM5", type: .episode)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    Button("Sign Out") {
                        auth.signOut()
                        fetchedTrack = nil
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .padding(.top)

                } else {
                    Spacer()
                    Text("Please Sign In to Spotify to continue")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding()
                    Button("Sign In with Spotify") {
                        auth.signIn()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Spotify API Integration Demo")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: Binding(
                get: { fetchingError != nil },
                set: { newValue in if !newValue { fetchingError = nil }}
            )) {
                Button("Okay", role: .cancel) { fetchingError = nil }
            } message: {
                Text(fetchingError ?? "Unknown error")
            }
        }
    }

    private func fetchSpotify(id: String, type: SpotifyAPIClient.SpotifyItemType) async {
        guard auth.isAuthenticated else {
            fetchingError = "Authenticate first"
            return
        }
        isLoading = true
        fetchingError = nil
        do {
            let track = try await spotifyAPIClient.fetchItemDetails(id: id, type: type)
            await MainActor.run {
                fetchedTrack = track
            }
        } catch {
            await MainActor.run {
                fetchingError = error.localizedDescription
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }
}
#Preview("ContentView") {
    SpotifyEmbedView()
}

// MARK: - App Entry Point: Demo only
//
//@main
//struct SpotifyAPIIntegrationDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
