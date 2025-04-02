//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}


//
//  YouTubeSampleApp.swift
//  YouTubeSampleiOS
//
//   Created by Cong Le on [Date]
//  Based on Google's Objective-C macOS Sample
//

import SwiftUI
import GoogleAPIClientForREST // Make sure this is correctly imported
import AppAuth // For OIDAuthState
import GTMAppAuth // For GTMAuthSession, GTMKeychainStore
import GTMSessionFetcherCore // For GTMSessionFetcher logging

// --- Application Entry Point ---

@main
struct YouTubeSampleApp: App {
    // Instantiate the ViewModel that holds the application state and logic.
    // Use @StateObject to ensure it persists for the lifetime of the App.
    @StateObject var viewModel = YouTubeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel) // Provide the ViewModel to the ContentView environment
                .onOpenURL { url in
                    // Handle the OAuth redirect URL
                    viewModel.handleRedirectURL(url)
                }
        }
    }
}

// --- ViewModel (ObservableObject) ---
// This class holds the state and logic, replacing YouTubeSampleWindowController.

class YouTubeViewModel: ObservableObject {

    // --- Authentication State ---
    @Published var authSession: GTMAuthSession?
    @Published var userEmail: String?
    @Published var isAuthenticated: Bool = false
    @Published var authError: Error?

    // Client ID Sheet State (For Sample App Only)
    @Published var clientID: String = "" // Load from storage or preset for real apps
    @Published var clientSecret: String = "" // Load from storage or preset for real apps
    @Published var isClientIDSheetPresented: Bool = false
    @Published var showClientIDWarning: Bool = false // Indicates if client ID is missing

    // --- YouTube Service & Data ---
    @Published var myPlaylistsInfo: GTLRYouTube_ChannelContentDetails_RelatedPlaylists?
    @Published var channelListFetchError: Error?
    private var channelListTicket: GTLRServiceTicket?

    @Published var selectedPlaylistType: PlaylistType = .uploads
    @Published var playlistItems: [GTLRYouTube_PlaylistItem] = []
    @Published var playlistFetchError: Error?
    private var playlistItemListTicket: GTLRServiceTicket?
    @Published var isFetchingPlaylists: Bool = false

    @Published var selectedPlaylistItem: GTLRYouTube_PlaylistItem? // For detail view or thumbnail

    @Published var videoCategories: [GTLRYouTube_VideoCategory] = []
    @Published var selectedVideoCategoryID: String?
    @Published var isFetchingCategories: Bool = false

    // --- Upload State ---
    @Published var uploadFileURL: URL?
    @Published var uploadTitle: String = ""
    @Published var uploadDescription: String = ""
    @Published var uploadTagsString: String = "" // Comma-separated
    @Published var uploadPrivacy: String = "private" // Default privacy
    let privacyOptions = ["private", "unlisted", "public"]

    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0.0
    @Published var isUploadPaused: Bool = false
    @Published var uploadError: Error?
    private var uploadFileTicket: GTLRServiceTicket?
    private var uploadLocationURL: URL? // For resuming uploads
    @Published var canRestartUpload: Bool = false

    // --- UI State & Configuration ---
    @Published var isShowingFilePicker: Bool = false
    @Published var resultLog: String = "" // To display detailed results or errors

    // --- Service and Helpers ---
    private var keychainStore: GTMKeychainStore
    private var redirectHTTPHandler: OIDRedirectHTTPHandler? // Or use AppAuth method directly

    // Static configuration
    // Replace with your actual client ID and secret management for production
    static let kGTMAppAuthKeychainItemName = "YouTubeSampleiOS: YouTube. GTMAppAuth"
    static let kSuccessURLString = "com.google.YouTubeSampleiOS:/oauth2redirect" // Custom URL Scheme

    // YouTube Service Singleton Access
    private(set) var youTubeService: GTLRYouTubeService = {
        let service = GTLRYouTubeService()
        service.shouldFetchNextPages = true
        service.retryEnabled = true
        // Configure authorizer later
        return service
    }()

    init() {
        keychainStore = GTMKeychainStore(itemName: YouTubeViewModel.kGTMAppAuthKeychainItemName)
        loadAuthSession()
        updateAuthState()

        // For sample app purposes, check if client ID is set
        // A real app would have these embedded or securely fetched
         if clientID.isEmpty {
             showClientIDWarning = true
             // Optionally present the sheet automatically if needed
             // isClientIDSheetPresented = true
         }
    }

    // MARK: - Authentication

    private func loadAuthSession() {
        do {
            authSession = try keychainStore.retrieveAuthSession()
            youTubeService.authorizer = authSession
        } catch {
            print("Failed to load AuthSession: \(error)")
            authSession = nil // Ensure it's nil if loading failed
            youTubeService.authorizer = nil
        }
    }

    private func saveAuthSession() {
        guard let session = authSession else { return }
        do {
            try keychainStore.save(session)
        } catch {
            print("Failed to save AuthSession: \(error)")
            // Might want to surface this error to the user
        }
    }

    private func removeAuthSession() {
        do {
            try keychainStore.removeAuthSession()
            authSession = nil
            youTubeService.authorizer = nil
        } catch {
            print("Failed to remove AuthSession: \(error)")
            // Might want to surface this error to the user
        }
    }

    private func updateAuthState() {
        if let session = authSession, session.canAuthorize() {
            isAuthenticated = true
            userEmail = session.userEmail
            authError = nil
        } else {
            isAuthenticated = false
            userEmail = nil
            // Keep any existing authError until a new attempt clears it
        }
        // Reset dependent states on auth change
        if !isAuthenticated {
            resetPlaylistState()
            resetUploadState(clearResumeURL: true)
        }
    }

    func signIn() {
        guard !clientID.isEmpty else {
            print("Client ID is missing.")
            authError = NSError(domain: "YouTubeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Client ID is required."])
            showClientIDWarning = true // Trigger UI warning
            isClientIDSheetPresented = true // Show the sheet to enter ID
            return
        }

        showClientIDWarning = false // Clear warning if ID seems present

        guard let successURL = URL(string: YouTubeViewModel.kSuccessURLString) else {
            print("Invalid success URL")
            authError = NSError(domain: "YouTubeViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "Internal configuration error (Success URL)."])
            return
        }
        guard let presentingViewController = UIApplication.shared.firstKeyWindow?.rootViewController else {
             print("Cannot find presenting view controller")
             authError = NSError(domain: "YouTubeViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not find view controller to present login."])
             return
        }

        // Build Authentication Request using AppAuth directly
        guard let configuration = GTMAuthSession.configurationForGoogle() else {
            print("Failed to get Google OAuth configuration")
            authError = NSError(domain: "YouTubeViewModel", code: -4, userInfo: [NSLocalizedDescriptionKey: "Could not get Google OAuth configuration."])
            return
        }

        let scopes = [kGTLRAuthScopeYouTube, OIDScopeEmail]
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret.isEmpty ? nil : clientSecret, // Secret might be nil for iOS native apps
                                              scopes: scopes,
                                              redirectURL: successURL, // Use the custom scheme URL
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        print("Initiating authorization request with scopes: \(scopes.joined(separator: " "))")

        // Perform authentication request
         // Storing the flow in a property is essential for handling the redirect.
         // We'll handle the URL in onOpenURL or SceneDelegate.
         let currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [weak self] authState, error in
             guard let self = self else { return }

             if let authState = authState {
                 print("Authorization successful.")
                 self.authSession = GTMAuthSession(authState: authState)
                 self.youTubeService.authorizer = self.authSession
                 self.authError = nil
                 self.saveAuthSession()
                 self.updateAuthState()
                 // Perform post-signin actions if needed, e.g., fetch initial data
                 self.fetchDataIfNeeded()
             } else {
                 print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
                 self.authError = error
                 self.authSession = nil
                 self.youTubeService.authorizer = nil
                 self.updateAuthState()
             }
         }
         // Keep the flow variable alive to handle the redirect correctly.
         // In a real app, manage this flow object's lifecycle carefully.
         // For this example, we rely on AppAuth handling it internally via the callback.
         // (Note: OIDRedirectHTTPHandler isn't typically used for iOS native apps with custom schemes)
    }

    func signOut() {
        removeAuthSession()
        updateAuthState()
        // Clear any fetched data that depends on authentication
        resetPlaylistState()
        resetUploadState(clearResumeURL: true)
    }

    // Handle the redirect URL from the App delegate or Scene delegate
     func handleRedirectURL(_ url: URL) {
         // This assumes you've stored the 'currentAuthorizationFlow' from AppAuth
         // If using OIDAuthState.authState(byPresenting:presenting:callback:)
         // it should handle the redirect automatically if the flow session is still active.
         // Check if the AppAuth library needs explicit handling here.
         // Typically for iOS, if the request/callback pattern is used, it might handle this.
         // Let's log it for now.
         print("Received redirect URL: \(url)")

         // Example of manual handling if needed (consult AppAuth docs):
         // if let flow = self.storedAuthorizationFlow, flow.resumeExternalUserAgentFlow(with: url) {
         //     self.storedAuthorizationFlow = nil // Clear the stored flow
         // }
     }

    // MARK: - Data Fetching (Playlists, Categories)

    private func resetPlaylistState() {
        myPlaylistsInfo = nil
        playlistItems = []
        channelListFetchError = nil
        playlistFetchError = nil
        selectedPlaylistItem = nil
        cancelPlaylistFetch() // Cancel any ongoing fetches
    }

    func fetchDataIfNeeded() {
        // Called after sign-in or on initial load if authenticated
        if isAuthenticated {
            fetchMyChannelList() // This will trigger playlist and category fetches
        }
    }

    func fetchMyChannelList() {
        guard isAuthenticated, !isFetchingPlaylists else { return }

        isFetchingPlaylists = true
        channelListFetchError = nil
        myPlaylistsInfo = nil // Clear previous results

        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: ["contentDetails"])
        query.mine = true
        query.maxResults = 1 // We only need the first channel for "mine"

        print("Fetching channel list...")

        channelListTicket = youTubeService.executeQuery(query) { [weak self] (ticket, response, error) in
            guard let self = self else { return }

            self.channelListTicket = nil // Clear the ticket

            if let error = error {
                print("Channel list fetch failed: \(error)")
                self.channelListFetchError = error
                self.playlistFetchError = nil // Clear playlist specific error
                self.isFetchingPlaylists = false
                self.updateResultLogWithError("Failed to fetch channel list", error: error)
                return
            }

            if let channelList = response as? GTLRYouTube_ChannelListResponse,
               let channel = channelList.items?.first {
                print("Channel list fetched successfully.")
                self.myPlaylistsInfo = channel.contentDetails?.relatedPlaylists
                // Now fetch the selected playlist based on the popup
                self.fetchSelectedPlaylist()
                // Also fetch categories, happens in parallel
                self.fetchVideoCategories()
            } else {
                print("Channel list response was empty or invalid.")
                self.channelListFetchError = NSError(domain: "YouTubeViewModel", code: -5, userInfo: [NSLocalizedDescriptionKey: "No channel found for user."])
                self.isFetchingPlaylists = false
            }
            // Note: isFetchingPlaylists remains true until fetchSelectedPlaylist completes
        }
    }

    func fetchSelectedPlaylist() {
        guard isAuthenticated, let playlists = myPlaylistsInfo else {
            if myPlaylistsInfo == nil && channelListTicket == nil && channelListFetchError == nil {
                 // If we don't have playlist info and aren't fetching it, start the chain
                 fetchMyChannelList()
            } else if !isAuthenticated {
                print("Cannot fetch playlist: Not authenticated.")
            } else if isFetchingPlaylists {
                print("Cannot fetch playlist: Already fetching.")
            }
            return
        }

        // Determine Playlist ID
        var playlistID: String?
        switch selectedPlaylistType {
        case .uploads: playlistID = playlists.uploads
        case .likes: playlistID = playlists.likes
            // Add other cases if needed (e.g., favorites)
        }

        guard let finalPlaylistID = playlistID, !finalPlaylistID.isEmpty else {
            print("No playlist ID found for type: \(selectedPlaylistType)")
            playlistFetchError = NSError(domain: "YouTubeViewModel", code: -6, userInfo: [NSLocalizedDescriptionKey: "Playlist ID not found for '\(selectedPlaylistType.display)'."])
            isFetchingPlaylists = false // Fetch chain ends here if no ID
            playlistItems = [] // Clear existing items
            updateResultLog()
            return
        }

        // Start fetching the specific playlist items
        isFetchingPlaylists = true // Ensure it's marked as fetching
        playlistFetchError = nil
        self.playlistItems = [] // Clear previous items immediately

        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: ["snippet", "contentDetails"])
        query.playlistId = finalPlaylistID
        query.maxResults = 50 // Fetch a page of results

        print("Fetching playlist items for ID: \(finalPlaylistID)...")

        playlistItemListTicket = youTubeService.executeQuery(query) { [weak self] (ticket, response, error) in
            guard let self = self else { return }

            self.playlistItemListTicket = nil // Clear ticket
            self.isFetchingPlaylists = false // Fetching is complete

            if let error = error {
                print("Playlist item fetch failed: \(error)")
                self.playlistFetchError = error
                self.playlistItems = []
                self.updateResultLogWithError("Failed to fetch playlist items", error: error)
            } else if let itemList = response as? GTLRYouTube_PlaylistItemListResponse {
                print("Playlist items fetched successfully (\(itemList.items?.count ?? 0) items).")
                self.playlistItems = itemList.items ?? []
                self.playlistFetchError = nil
                self.updateResultLog() // Update log with current selection
            } else {
                print("Playlist item response was empty or invalid.")
                self.playlistFetchError = NSError(domain: "YouTubeViewModel", code: -7, userInfo: [NSLocalizedDescriptionKey: "Received invalid response for playlist items."])
                self.playlistItems = []
                self.updateResultLog()
            }
        }
    }

    func fetchVideoCategories() {
        guard isAuthenticated, !isFetchingCategories else { return }

        isFetchingCategories = true
        // Use current device locale to get relevant categories
        let regionCode = Locale.current.regionCode ?? "US"

        let query = GTLRYouTubeQuery_VideoCategoriesList.query(withPart: ["snippet", "id"])
        query.regionCode = regionCode

        print("Fetching video categories for region: \(regionCode)...")

        youTubeService.executeQuery(query) { [weak self] (ticket, response, error) in
            guard let self = self else { return }
            self.isFetchingCategories = false

            if let error = error {
                print("Video category fetch failed: \(error)")
                // Handle error - maybe show a default list or disable category selection?
            } else if let categoryList = response as? GTLRYouTube_VideoCategoryListResponse {
                 print("Video categories fetched successfully (\(categoryList.items?.count ?? 0) categories).")
                self.videoCategories = categoryList.items ?? []
                // Set a default selection if needed
                self.selectedVideoCategoryID = self.videoCategories.first?.identifier
            } else {
                print("Video category response was empty or invalid.")
            }
        }
    }

    func cancelPlaylistFetch() {
        channelListTicket?.cancelTicket()
        channelListTicket = nil
        playlistItemListTicket?.cancelTicket()
        playlistItemListTicket = nil
        isFetchingPlaylists = false // Ensure state is reset
        // Don't clear errors here, let the UI show the last error if needed
    }

    // MARK: - Upload Logic

    private func resetUploadState(clearResumeURL: Bool = false) {
        isUploading = false
        isUploadPaused = false
        uploadProgress = 0.0
        uploadError = nil
        cancelUpload() // Cancel any ongoing upload

        if clearResumeURL {
            uploadLocationURL = nil
            canRestartUpload = false
        } else {
             // Keep resume URL if requested (e.g., after stop/error)
             canRestartUpload = uploadLocationURL != nil
        }
    }

    func prepareUpload(fileURL: URL) {
         self.uploadFileURL = fileURL
         self.uploadTitle = fileURL.lastPathComponent // Pre-fill title
         self.uploadDescription = "" // Clear description
         self.uploadTagsString = "" // Clear tags
         self.uploadError = nil // Clear previous errors
         resetUploadState(clearResumeURL: true) // Reset progress, tickets etc.
         updateResultLog() // Clear result log related to upload
    }

    func startUpload() {
        guard isAuthenticated else {
            uploadError = NSError(domain: "YouTubeViewModel", code: -10, userInfo: [NSLocalizedDescriptionKey: "Please sign in to upload."])
            return
        }
        guard let fileURL = uploadFileURL else {
            uploadError = NSError(domain: "YouTubeViewModel", code: -11, userInfo: [NSLocalizedDescriptionKey: "Please choose a video file to upload."])
            return
        }
        guard !uploadTitle.isEmpty else {
             uploadError = NSError(domain: "YouTubeViewModel", code: -12, userInfo: [NSLocalizedDescriptionKey: "Please enter a title for the video."])
             return
        }

        print("Starting upload for file: \(fileURL.path)")
        // Create the Video object with metadata
        let status = GTLRYouTube_VideoStatus()
        status.privacyStatus = uploadPrivacy

        let snippet = GTLRYouTube_VideoSnippet()
        snippet.title = uploadTitle
        if !uploadDescription.isEmpty {
            snippet.descriptionProperty = uploadDescription
        }
        if !uploadTagsString.isEmpty {
            snippet.tags = uploadTagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        }
        if let categoryId = selectedVideoCategoryID {
            snippet.categoryId = categoryId
        }

        let video = GTLRYouTube_Video()
        video.status = status
        video.snippet = snippet

        uploadVideo(videoObject: video, resumeURL: nil)
    }

    func restartUpload() {
        guard isAuthenticated, let resumeURL = uploadLocationURL else {
             uploadError = NSError(domain: "YouTubeViewModel", code: -13, userInfo: [NSLocalizedDescriptionKey: "No previous upload to restart or not signed in."])
             return
        }

        print("Restarting upload from URL: \(resumeURL)")
        uploadError = nil // Clear previous error before restarting
         // Create an empty video object when resuming, metadata is already set
        let video = GTLRYouTube_Video()
        uploadVideo(videoObject: video, resumeURL: resumeURL)
    }

    private func uploadVideo(videoObject: GTLRYouTube_Video, resumeURL: URL?) {
        guard let fileURL = uploadFileURL else {
            print("Error: Upload file URL is missing.")
            // This case should be caught earlier, but good to double-check
            return
        }

        // Check reachability (though GTLR might handle this too)
        do {
            if try fileURL.checkResourceIsReachable() {
                // File exists, proceed
                 print("File check successful: \(fileURL.path)")
            } else {
                uploadError = NSError(domain: "YouTubeViewModel", code: -14, userInfo: [NSLocalizedDescriptionKey: "Upload file not found or not accessible at path: \(fileURL.path)"])
                 print("Error: File not reachable at \(fileURL.path)")
                return
            }
        } catch {
            uploadError = NSError(domain: "YouTubeViewModel", code: -15, userInfo: [NSLocalizedDescriptionKey: "Error checking file accessibility: \(error.localizedDescription)"])
            print("Error checking file reachability: \(error)")
            return
        }

        let mimeType = mimeTypeForPath(path: fileURL.path)
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)
        uploadParameters.uploadLocationURL = resumeURL // Set resume URL if provided

        let query = GTLRYouTubeQuery_VideosInsert.query(withObject: videoObject,
                                                        part: ["snippet", "status"],
                                                        uploadParameters: uploadParameters)

        isUploading = true
        isUploadPaused = false
        uploadProgress = 0.0
        uploadError = nil
        canRestartUpload = false // Cannot restart while actively uploading/starting

        query.executionParameters.uploadProgressBlock = { [weak self] (ticket, bytesRead, dataLength) in
            guard let self = self else { return }
            DispatchQueue.main.async { // Ensure UI updates on main thread
                self.uploadProgress = Double(bytesRead) / Double(dataLength)
                 // print("Upload Progress: \(self.uploadProgress)")
            }
        }

        print("Executing upload query...")

        uploadFileTicket = youTubeService.executeQuery(query) { [weak self] (ticket, uploadedVideo, error) in
            guard let self = self else { return }

            // --- Upload Completion Handling ---
            DispatchQueue.main.async { // Ensure UI updates on main thread
                self.uploadFileTicket = nil // Clear ticket
                self.isUploading = false
                self.isUploadPaused = false

                if let error = error {
                    print("Upload failed: \(error)")
                    // Check if the error is potentially resumable
                    // GTMSessionFetcher errors might have userInfo for resume data/URL
                    let fetcherError = error as NSError
                    if let resumeData = fetcherError.userInfo[kGTMSessionFetcherUploadLocationURLKey] as? URL {
                        self.uploadLocationURL = resumeData
                        self.canRestartUpload = true
                        print("Stored resume URL: \(resumeData)")
                    } else {
                        self.uploadLocationURL = nil // Clear resume URL if error wasn't resumable
                        self.canRestartUpload = false
                         print("Upload error doesn't seem resumable.")
                    }
                    self.uploadError = error
                    self.updateResultLogWithError("Upload Failed", error: error)

                } else if let video = uploadedVideo as? GTLRYouTube_Video {
                    print("Upload successful: \(video.snippet?.title ?? "No Title")")
                    self.uploadError = nil
                    self.uploadProgress = 1.0 // Mark as complete
                    self.uploadLocationURL = nil // Success, clear resume URL
                    self.canRestartUpload = false
                    self.updateResultLogWithSuccess("Uploaded \"\(video.snippet?.title ?? "")\" successfully.")

                    // Optionally refresh the 'uploads' playlist if it's selected
                    if self.selectedPlaylistType == .uploads {
                        self.fetchSelectedPlaylist()
                    }
                     // Clear upload fields after success? Optional.
                    // self.uploadFileURL = nil
                    // self.uploadTitle = "" ... etc

                } else {
                    print("Upload completed with invalid response.")
                    self.uploadError = NSError(domain: "YouTubeViewModel", code: -16, userInfo: [NSLocalizedDescriptionKey: "Upload completed but received an invalid response."])
                    self.uploadLocationURL = nil // No usable video object
                    self.canRestartUpload = false
                    self.updateResultLog()
                }
            } // end DispatchQueue.main.async
        } // end executeQuery completion handler
    }

    func pauseUpload() {
        guard let ticket = uploadFileTicket, isUploading, !isUploadPaused else { return }
        print("Pausing upload...")
        ticket.pauseUpload()
        isUploadPaused = true
    }

    func resumeUpload() {
        guard let ticket = uploadFileTicket, isUploading, isUploadPaused else { return }
        print("Resuming upload...")
        ticket.resumeUpload()
        isUploadPaused = false
    }

    func stopUpload() {
        guard let ticket = uploadFileTicket, isUploading else { return }
        print("Stopping upload...")

        // Attempt to get the resume URL *before* cancelling
        self.uploadLocationURL = (ticket.uploadFetcher as? GTMSessionUploadFetcher)?.uploadLocationURL
        self.canRestartUpload = self.uploadLocationURL != nil

        ticket.cancelTicket()
        uploadFileTicket = nil // Clear the ticket AFTER cancelling
        isUploading = false
        isUploadPaused = false
        uploadProgress = 0.0 // Reset progress visually
        updateResultLog() // Clear result log

         if canRestartUpload {
            print("Upload stopped. Resume URL captured: \(self.uploadLocationURL!)")
         } else {
            print("Upload stopped. No resume URL available.")
         }
    }

    func cancelUpload() {
        // Similar to stop, but typically used when abandoning the upload state entirely
        if let ticket = uploadFileTicket {
            ticket.cancelTicket()
            uploadFileTicket = nil
        }
         isUploading = false
         isUploadPaused = false
         uploadProgress = 0.0
         // uploadLocationURL might be kept or cleared depending on context
         // canRestartUpload = uploadLocationURL != nil
    }

    // MARK: - UI Updates & Helpers

    func selectPlaylistItem(_ item: GTLRYouTube_PlaylistItem?) {
         selectedPlaylistItem = item
         updateResultLog() // Update log based on new selection
    }

    private func updateResultLog() {
        if let error = playlistFetchError ?? channelListFetchError ?? authError ?? uploadError {
            updateResultLogWithError("Error", error: error)
        } else if let item = selectedPlaylistItem {
            resultLog = item.description // GTLR objects have a description property
        } else {
            resultLog = "Select an item to see details."
        }
    }

    private func updateResultLogWithError(_ context: String, error: Error) {
        var log = "\(context): \(error.localizedDescription)\n"
        let nsError = error as NSError
        log += "Domain: \(nsError.domain), Code: \(nsError.code)\n"

        // Append underlying error if available
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            log += "Underlying Error: \(underlying.localizedDescription)\n"
             log += "Underlying Domain: \(underlying.domain), Code: \(underlying.code)\n"
        }
        // Append server data if available from GTMSessionFetcher
        if let data = nsError.userInfo[kGTMSessionFetcherStatusDataKey] as? Data,
           let dataStr = String(data: data, encoding: .utf8) {
                log += "Server Data: \(dataStr)\n"
        }
        resultLog = log
    }

    private func updateResultLogWithSuccess(_ message: String) {
        resultLog = "Success: \(message)"
    }

    // Utility to get MIME type
    private func mimeTypeForPath(path: String) -> String {
        // Simple map based on common video extensions
        // For more robust solution, use UTType framework
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension.lowercased()

        switch pathExtension {
        case "mov": return "video/quicktime"
        case "mp4": return "video/mp4"
        case "avi": return "video/x-msvideo"
        case "wmv": return "video/x-ms-wmv"
        case "mkv": return "video/x-matroska" // May not be supported by YouTube upload
        case "flv": return "video/x-flv" // May not be supported by YouTube upload
        default: return "application/octet-stream" // Default binary type
        }
        // More robust using UTType (requires import UniformTypeIdentifiers):
        /*
         import UniformTypeIdentifiers
         if let type = UTType(filenameExtension: pathExtension) {
             return type.preferredMIMEType ?? "application/octet-stream"
         } else {
             return "application/octet-stream"
         }
         */
    }

    // Placeholder for turning logging on/off
      func setLoggingEnabled(_ enabled: Bool) {
          GTMSessionFetcher.setLoggingEnabled(enabled)
          // GTMSessionFetcher.setLoggingDirectory(path) // If desired
          print("Fetcher Logging \(enabled ? "Enabled" : "Disabled")")
      }

    // Reset Client ID/Secret (for sample app UI)
    func saveClientIDInfo() {
        // In a real app, this data wouldn't be user-editable this way.
        // This just updates the ViewModel's state for the sample's UI flow.
        if clientID.isEmpty {
            showClientIDWarning = true
        } else {
            showClientIDWarning = false
        }
        // Persist if needed for the sample, e.g., to UserDefaults (not secure)
        // UserDefaults.standard.set(clientID, forKey: "DebugClientID")
        // UserDefaults.standard.set(clientSecret, forKey: "DebugClientSecret")
    }
}

//MARK: - Helper Enums and Extensions

enum PlaylistType: String, CaseIterable, Identifiable {
    case uploads = "Uploads"
    case likes = "Likes"
    // Add other playlist types like Favorites if needed

    var id: String { self.rawValue }
    var display: String { self.rawValue }
}

// Helper to get the top view controller for AppAuth presentation
extension UIApplication {
    var firstKeyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible ones
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            // Keep only the first `UIWindowScene`
            .first?.windows
            // Keep only the key window
            .first(where: \.isKeyWindow)
    }
}

// --- SwiftUI Views ---

struct ContentView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel

    var body: some View {
        NavigationView {
            List {
                Section("Authentication") {
                    AuthStatusView()
                    if viewModel.showClientIDWarning {
                         Text("Client ID is required for Sign In.")
                             .foregroundColor(.red)
                             .font(.caption)
                    }
                    Button(viewModel.isAuthenticated ? "Sign Out" : "Sign In") {
                        if viewModel.isAuthenticated {
                            viewModel.signOut()
                        } else {
                            viewModel.signIn()
                        }
                    }
                    Button("Edit Client ID/Secret (Sample Only)") {
                        viewModel.isClientIDSheetPresented = true
                    }
                }

                // Only show other sections if authenticated
                 if viewModel.isAuthenticated {
                     Section("Playlist") {
                         PlaylistSelectionView()
                         PlaylistItemsListView()
                     }

                    Section("Selected Item Details") {
                         ResultTextView(title: "Item Details / Log")
                    }

                    Section("Upload Video") {
                         UploadView()
                    }
                     Section("Debug") {
                         Toggle("Enable Fetcher Logging", isOn: Binding(
                             get: { GTMSessionFetcher.isLoggingEnabled() },
                             set: { viewModel.setLoggingEnabled($0) }
                         ))
                     }

                 } else {
                    // Optionally show a message when signed out
                     Text("Sign in to access YouTube features.")
                         .foregroundColor(.secondary)
                 }
            }
            .navigationTitle("YouTube Sample")
            .listStyle(GroupedListStyle())
            // Sheet for Client ID/Secret (Sample App Debug Feature)
            .sheet(isPresented: $viewModel.isClientIDSheetPresented) {
                ClientIDSheetView()
            }
        }
       .navigationViewStyle(StackNavigationViewStyle()) // Better for iOS layouts
       .onAppear {
           // Fetch initial data if already authenticated when the view appears
           viewModel.fetchDataIfNeeded()
       }
    }
}

struct AuthStatusView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel

    var body: some View {
        HStack {
            Text("Status:")
            if viewModel.isAuthenticated {
                Text("Signed In (\(viewModel.userEmail ?? "Unknown"))")
                    .foregroundColor(.green)
            } else {
                Text("Signed Out")
                    .foregroundColor(.red)
            }
        }
        if let error = viewModel.authError {
            Text("Auth Error: \(error.localizedDescription)")
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}

struct PlaylistSelectionView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Picker("Playlist Type", selection: $viewModel.selectedPlaylistType) {
                ForEach(PlaylistType.allCases) { type in
                    Text(type.display).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(viewModel.isFetchingPlaylists)
            .onChange(of: viewModel.selectedPlaylistType) { _ in
                 viewModel.fetchSelectedPlaylist() // Fetch when selection changes
            }

            HStack {
                Button("Refresh Playlist") {
                    viewModel.fetchSelectedPlaylist()
                }
                .disabled(viewModel.isFetchingPlaylists)

                Spacer()

                 if viewModel.isFetchingPlaylists {
                     ProgressView() // Shows an indeterminate progress indicator
                         .scaleEffect(0.7)
                         .frame(width: 20, height: 20)
                     Button("Cancel Fetch") {
                          viewModel.cancelPlaylistFetch()
                     }
                 }
            }
             if let error = viewModel.channelListFetchError ?? viewModel.playlistFetchError {
                 Text("Playlist Error: \(error.localizedDescription)")
                     .foregroundColor(.red)
                     .font(.caption)
             }
        }
    }
}

struct PlaylistItemsListView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel

    var body: some View {
       // Using a simple ForEach within the List Section in ContentView
       // Adapt if a separate scrollable list is needed here.
        if viewModel.playlistItems.isEmpty && !viewModel.isFetchingPlaylists {
            Text("No items in selected playlist or fetch failed.")
                .foregroundColor(.secondary)
        } else {
            ForEach(viewModel.playlistItems, id: \.identifier) { item in
                 PlaylistItemRow(item: item)
                    .onTapGesture {
                         viewModel.selectPlaylistItem(item)
                    }
            }
        }
    }
}

struct PlaylistItemRow: View {
    @EnvironmentObject var viewModel: YouTubeViewModel // Needed for thumbnail logic
    let item: GTLRYouTube_PlaylistItem

    var body: some View {
        HStack {
             // AsyncImage to load thumbnails
             AsyncImage(url: URL(string: item.snippet?.thumbnails?.defaultProperty?.url ?? "")) { phase in
                 if let image = phase.image {
                     image.resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 60, height: 45) // Adjust size as needed
                          .clipped()
                 } else if phase.error != nil {
                     Image(systemName: "photo") // Placeholder on error
                         .frame(width: 60, height: 45)
                         .background(Color.gray.opacity(0.3))
                 } else {
                     ProgressView() // Placeholder while loading
                         .frame(width: 60, height: 45)
                 }
             }

            Text(item.snippet?.title ?? "No Title")
            Spacer()
            // Indicate selection if desired
             if viewModel.selectedPlaylistItem?.identifier == item.identifier {
                 Image(systemName: "checkmark.circle.fill")
                     .foregroundColor(.blue)
             }
        }
    }
}

struct ResultTextView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel
    let title: String

    var body: some View {
         VStack(alignment: .leading) {
             Text(title)
                 .font(.headline)
             // Use a ScrollView for potentially long text
             ScrollView {
                 Text(viewModel.resultLog)
                     .font(.system(.caption, design: .monospaced))
                     .frame(maxWidth: .infinity, alignment: .leading) // Allow text to wrap
                     .padding(5)
             }
             .frame(minHeight: 100, maxHeight: 200) // Set height constraints
             .background(Color.gray.opacity(0.1))
             .cornerRadius(5)
             .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
         }
    }
}

struct UploadView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel

    var body: some View {
         VStack(alignment: .leading, spacing: 10) {
            // File Selection
            HStack {
                Text("File:")
                Text(viewModel.uploadFileURL?.lastPathComponent ?? "No file selected")
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button("Choose") {
                    viewModel.isShowingFilePicker = true
                }
                .disabled(viewModel.isUploading)
            }

            // Metadata Fields
             TextField("Title", text: $viewModel.uploadTitle)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .disabled(viewModel.isUploading)
             TextField("Description", text: $viewModel.uploadDescription)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .disabled(viewModel.isUploading)
             TextField("Tags (comma-separated)", text: $viewModel.uploadTagsString)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .disabled(viewModel.isUploading)

             // Category Picker
             if !viewModel.videoCategories.isEmpty {
                 Picker("Category", selection: $viewModel.selectedVideoCategoryID) {
                     ForEach(viewModel.videoCategories, id: \.identifier) { category in
                         Text(category.snippet?.title ?? "Unknown").tag(category.identifier as String?) // Tag must be optional to match selection
                     }
                 }
                 .disabled(viewModel.isUploading || viewModel.isFetchingCategories)
             } else if viewModel.isFetchingCategories {
                 HStack { Text("Category:"); ProgressView() }
             } else {
                 Text("Category: (Could not load categories)")
                     .foregroundColor(.secondary)
             }

             // Privacy Picker
             Picker("Privacy", selection: $viewModel.uploadPrivacy) {
                 ForEach(viewModel.privacyOptions, id: \.self) { option in
                     Text(option.capitalized).tag(option)
                 }
             }
              .disabled(viewModel.isUploading)
            // Note: Segmented style might be too wide here, default is fine

            // Upload Progress & Controls
             if viewModel.isUploading || viewModel.uploadProgress > 0 {
                 ProgressView(value: viewModel.uploadProgress)
                     .progressViewStyle(LinearProgressViewStyle())
             }

             HStack {
                 Button("Upload") {
                     viewModel.startUpload()
                 }
                 .disabled(viewModel.isUploading || viewModel.uploadFileURL == nil || viewModel.uploadTitle.isEmpty)

                 if viewModel.isUploading {
                     Button(viewModel.isUploadPaused ? "Resume" : "Pause") {
                         if viewModel.isUploadPaused {
                             viewModel.resumeUpload()
                         } else {
                             viewModel.pauseUpload()
                         }
                     }
                     Button("Stop") {
                         viewModel.stopUpload()
                     }
                     .foregroundColor(.red)
                 } else if viewModel.canRestartUpload {
                     Button("Restart Upload") {
                         viewModel.restartUpload()
                     }
                     .foregroundColor(.orange)
                 }
             }
             .padding(.top, 5)

             // Upload Error Display
             if let error = viewModel.uploadError {
                 Text("Upload Error: \(error.localizedDescription)")
                     .foregroundColor(.red)
                     .font(.caption)
             }
         }
         .fileImporter(
             isPresented: $viewModel.isShowingFilePicker,
             allowedContentTypes: [.movie, .video], // Use UTType for modern approach
             allowsMultipleSelection: false
         ) { result in
             switch result {
             case .success(let urls):
                 if let url = urls.first {
                     // IMPORTANT: You need to secure access to the file URL
                     // Request access before using it, especially outside the picker's scope.
                     if url.startAccessingSecurityScopedResource() {
                         viewModel.prepareUpload(fileURL: url)
                         // Remember to call url.stopAccessingSecurityScopedResource() when done
                         // This should be managed carefully, perhaps when the upload completes or fails,
                         // or when the ViewModel deinitializes.
                     } else {
                          viewModel.uploadError = NSError(domain: "UploadView", code: -20, userInfo: [NSLocalizedDescriptionKey: "Could not get access to the selected file."])
                     }
                 }
             case .failure(let error):
                 viewModel.uploadError = error
             }
         }
    }
}

// --- Sheet for Client ID (Sample App Debug Only) ---

struct ClientIDSheetView: View {
    @EnvironmentObject var viewModel: YouTubeViewModel
    @Environment(\.presentationMode) var presentationMode

    // Local state for editing within the sheet
    @State private var editingClientID: String = ""
    @State private var editingClientSecret: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Google API Client Credentials")) {
                    Text("For this sample app, enter your client ID obtained from the Google Cloud Console. Client Secret is usually optional for iOS native apps.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Client ID", text: $editingClientID)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)

                    // Commented out secret - usually not needed/used for native iOS clients
                    // TextField("Client Secret (Optional)", text: $editingClientSecret)
                    //     .disableAutocorrection(true)
                    //     .autocapitalization(.none)

                    Link("Get Credentials from API Console", destination: URL(string: "https://console.developers.google.com/")!)
                }
            }
            .navigationTitle("Client Credentials")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Save the entered values back to the main ViewModel
                        viewModel.clientID = editingClientID
                        viewModel.clientSecret = editingClientSecret // Might always be ""
                        viewModel.saveClientIDInfo() // Update ViewModel state/warnings
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                // Load current values from view model when sheet appears
                editingClientID = viewModel.clientID
                editingClientSecret = viewModel.clientSecret
            }
        }
    }
}

// --- Previews (Optional) ---

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(YouTubeViewModel()) // Provide a dummy ViewModel for preview
    }
}
