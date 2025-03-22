//
//  TransferRiskView.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//
import SwiftUI
import Combine
import ZipArchive
import QuickLook

// MARK: - Data Models

enum DownloadState: Codable {
    case notStarted
    case inProgress(Double)
    case completed
    case failed(String) // Store error description

    private enum CodingKeys: String, CodingKey {
        case notStarted, inProgress, completed, failed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notStarted:
            try container.encode(true, forKey: .notStarted)
        case .inProgress(let progress):
            try container.encode(progress, forKey: .inProgress)
        case .completed:
            try container.encode(true, forKey: .completed)
        case .failed(let errorDescription):
            try container.encode(errorDescription, forKey: .failed)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _ = try? container.decode(Bool.self, forKey: .notStarted) {
            self = .notStarted
        } else if let progress = try? container.decode(Double.self, forKey: .inProgress) {
            self = .inProgress(progress)
        } else if let _ = try? container.decode(Bool.self, forKey: .completed) {
            self = .completed
        } else if let errorDescription = try? container.decode(String.self, forKey: .failed) {
            self = .failed(errorDescription)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid DownloadState"))
        }
    }
}

struct CIRTData: Identifiable, Codable {
    let id: UUID
    let currentState: String?
    let s3Uri: String?
    let requestId: String?
    let stateEntryTimestamp: String?
    var downloadState: DownloadState
    var downloadedFilePath: URL?

    enum CodingKeys: String, CodingKey {
        case id, currentState, s3Uri, requestId, stateEntryTimestamp, downloadState, downloadedFilePath
    }

    init(from state: CirtRequestState) {
        self.id = UUID()
        self.currentState = state.currentState
        self.s3Uri = state.s3Uri
        self.requestId = state.requestId
        self.stateEntryTimestamp = state.stateEntryTimestamp
        self.downloadState = .notStarted
        self.downloadedFilePath = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        currentState = try container.decodeIfPresent(String.self, forKey: .currentState)
        s3Uri = try container.decodeIfPresent(String.self, forKey: .s3Uri)
        requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
        stateEntryTimestamp = try container.decodeIfPresent(String.self, forKey: .stateEntryTimestamp)
        downloadState = try container.decode(DownloadState.self, forKey: .downloadState)
        downloadedFilePath = try container.decodeIfPresent(URL.self, forKey: .downloadedFilePath)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(currentState, forKey: .currentState)
        try container.encodeIfPresent(s3Uri, forKey: .s3Uri)
        try container.encodeIfPresent(requestId, forKey: .requestId)
        try container.encodeIfPresent(stateEntryTimestamp, forKey: .stateEntryTimestamp)
        try container.encode(downloadState, forKey: .downloadState)
        try container.encodeIfPresent(downloadedFilePath, forKey: .downloadedFilePath)
    }
}

struct CirtRequestState: Decodable {
    let currentState: String?
    let s3Uri: String?
    let requestId: String?
    let stateEntryTimestamp: String?

    enum CodingKeys: String, CodingKey {
        case currentState
        case s3Uri = "s3Uri"
        case requestId = "request-id"
        case stateEntryTimestamp = "state-entry-timestamp"
    }
}

// MARK: - API Endpoints

enum CIRTApiEndpoint {
    case programToDate
    case currentReportingPeriod

    var path: String {
        switch self {
        case .programToDate:
            return "/v1/credit-insurance-risk-transfer/program-to-date"
        case .currentReportingPeriod:
            return "/v1/credit-insurance-risk-transfer/current-reporting-period"
        }
    }
}

// MARK: - API Errors

enum CIRTApiError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case unknown(Error)
    case fileManagementFailed(String)
    case unzippingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                return "Invalid API URL."
        case .requestFailed(let message): return "API request failed: \(message)"
        case .decodingFailed:             return "Failed to decode the response."
        case .noData:                     return "No data was returned."
        case .authenticationFailed:       return "Authentication failed. Please check your credentials."
        case .unknown(let error):          return "An unknown error occurred: \(error.localizedDescription)"
        case .fileManagementFailed(let message): return "File management error: \(message)"
        case .unzippingFailed(let message):   return "Unzipping failed: \(message)"
        }
    }
}

// MARK: - Authentication (Replace with secure storage in production)

struct CIRTAuthCredentials {
    static let clientID = "clientIDKeyHere"
    static let clientSecret = "clientSecretKeyHere"
}

struct CIRTTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Download Delegate

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    var onProgress: ((Double) -> Void)?
    var onCompletion: ((URL?, Error?) -> Void)?

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            onProgress?(progress)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Needed for didFinishDownloadingTo to get called
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        onCompletion?(location, nil)
    }
}

// MARK: - Data Service

final class CIRTDataService: ObservableObject {
    @Published var cirtData: [CIRTData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"  // Verify this is correct for your API
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private let fileManager = FileManager.default // Use it directly

    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        let delegate = DownloadDelegate()
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }()
    
    // MARK: - App-Specific Directory
        private func appSpecificDirectory() throws -> URL {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
             // Creates our app directory
            let appDirectory = documentsDirectory.appendingPathComponent("CIRTData", isDirectory: true)
            print("App directory: \(appDirectory)")
            
            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            return appDirectory
        }

    // MARK: - Token Management

   private func getAccessToken(completion: @escaping (Result<String, CIRTApiError>) -> Void) {
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(CIRTAuthCredentials.clientID):\(CIRTAuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw CIRTApiError.requestFailed("Invalid response: \(responseString)")
                }
                return data
            }
            .decode(type: CIRTTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? CIRTApiError) ?? CIRTApiError.unknown(error)
                    self?.handleError(apiError)
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API Data Fetching

    func fetchData(for endpoint: CIRTApiEndpoint) {
        isLoading = true
        errorMessage = nil

        getAccessToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }

    private func makeDataRequest(endpoint: CIRTApiEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw CIRTApiError.requestFailed("HTTP Status Code error.  Response: \(responseString)")
                }
                return data
            }
            .decode(type: CirtRequestState.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error as? CIRTApiError ?? .unknown(error))
                }
            } receiveValue: { [weak self] cirtRequestState in
                guard let self = self else { return }
                let newData = CIRTData(from: cirtRequestState)
                if !self.cirtData.contains(where: { $0.s3Uri == newData.s3Uri }) {
                    self.cirtData.append(newData)
                }
            }
            .store(in: &cancellables)
    }


    func downloadData(for item: CIRTData) {
        guard let s3URLString = item.s3Uri, let s3URL = URL(string: s3URLString) else { return }
        if downloadTasks[item.id] != nil { return }

        if let index = cirtData.firstIndex(where: { $0.id == item.id }) {
            cirtData[index].downloadState = .inProgress(0.0)
        }

        let downloadTask = urlSession.downloadTask(with: s3URL)
        downloadTasks[item.id] = downloadTask

        if let delegate = urlSession.delegate as? DownloadDelegate {
            delegate.onProgress = { [weak self] progress in
                DispatchQueue.main.async {
                    self?.setDownloadProgress(for: item, progress: progress)
                }
            }
            delegate.onCompletion = { [weak self] localURL, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    self.downloadTasks[item.id] = nil

                    if let localURL = localURL, error == nil {
                        if let index = self.cirtData.firstIndex(where: { $0.id == item.id }) {
                            self.processDownloadedFile(at: localURL, for: item, index: index)
                        }
                    } else if let error = error {
                        if let index = self.cirtData.firstIndex(where: { $0.id == item.id }) {
                            self.cirtData[index].downloadState = .failed(error.localizedDescription)
                        }
                    }
                }
            }
        }
        downloadTask.resume()
    }
    

    func setDownloadProgress(for item: CIRTData, progress: Double) {
        guard let index = cirtData.firstIndex(where: { $0.id == item.id }) else { return }
        cirtData[index].downloadState = .inProgress(progress)
    }

    func cancelDataRequest(for item: CIRTData) {
        if let task = downloadTasks[item.id] {
            task.cancel()
            downloadTasks.removeValue(forKey: item.id)
        }

        if let index = cirtData.firstIndex(where: { $0.id == item.id }) {
            cirtData[index].downloadState = .notStarted
        }
    }
    

    private func processDownloadedFile(at localURL: URL, for item: CIRTData, index: Int) {
        do {
            let appDirectory = try appSpecificDirectory() // Use the app-specific directory
            let fileName = item.s3Uri?.components(separatedBy: "/").last ?? "downloadedFile.zip"
            let destinationURL = appDirectory.appendingPathComponent("\(item.id)_\(fileName)")
            print("Destination URL: \(destinationURL)")
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }

            try fileManager.moveItem(at: localURL, to: destinationURL)
            cirtData[index].downloadedFilePath = destinationURL // Store file path

            // Unzip *within* the app's directory:
            let unzipSuccessful = SSZipArchive.unzipFile(atPath: destinationURL.path,
                                                         toDestination: appDirectory.path)

            if unzipSuccessful {

                cirtData[index].downloadState = .completed
            } else {
                cirtData[index].downloadState = .failed(CIRTApiError.unzippingFailed("Failed to unzip file.").localizedDescription)
            }

        } catch {
            cirtData[index].downloadState = .failed(CIRTApiError.fileManagementFailed(error.localizedDescription).localizedDescription)
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: CIRTApiError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")
    }

    func clearLocalData() {
        cirtData.removeAll()
    }
}

// MARK: - SwiftUI Views

struct CIRTContentView: View {
    @StateObject private var dataService = CIRTDataService()
    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    Button("Fetch Program-to-Date Data") {
                        dataService.fetchData(for: .programToDate)
                    }
                    .buttonStyle(.bordered)

                    Button("Fetch Current Reporting Period Data") {
                        dataService.fetchData(for: .currentReportingPeriod)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }

                Section(header: Text("CIRT Data")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.cirtData) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                if let currentState = item.currentState {
                                    Text("Current State: \(currentState)")
                                }
                                if let s3Uri = item.s3Uri {
                                    Text("S3 URI: \(s3Uri)")
                                        .font(.caption)
                                }
                                if let requestId = item.requestId {
                                    Text("Request ID: \(requestId)")
                                }
                                if let timestamp = item.stateEntryTimestamp {
                                    Text("Timestamp: \(timestamp)")
                                }

                                switch item.downloadState {
                                case .notStarted:
                                    Button("Download Data") {
                                        dataService.downloadData(for: item)
                                    }
                                    .buttonStyle(.bordered)
                                case .inProgress(let progress):
                                    ProgressView("Downloading...", value: progress)
                                case .completed:
                                    if let filePath = item.downloadedFilePath {
                                        Text("Download Complete: \(filePath.lastPathComponent)")
                                            .foregroundColor(.green)
                                        Button("Process Data") {
                                            selectedFileURL = filePath
                                            showingFilePicker = true
                                        }
                                    }
                                case .failed(let errorString):
                                    Text("Download Failed: \(errorString)")
                                        .foregroundColor(.red)
                                    Button("Retry") {
                                        dataService.downloadData(for: item)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("CIRT Data")
           .sheet(isPresented: $showingFilePicker) {
                if let url = selectedFileURL {
                    DocumentViewerView(url: url)
                }
            }
        }
    }
}


struct DocumentViewerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: DocumentViewerView

        init(parent: DocumentViewerView) {
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            parent.url as QLPreviewItem
        }
    }
}

// MARK: - Preview
struct CIRTContentView_Previews: PreviewProvider {
    static var previews: some View {
        CIRTContentView()
    }
}
