//
//  WhereIsMyStatusView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Combine // Needed for ObservableObject

// MARK: - Constants
enum Constants {
    // WARNING: Storing client secrets directly in code is insecure for production apps.
    // Consider using a secure backend, environment variables, or a configuration file.
    static let clientID = "YOUR_CLIENT_ID"
    static let clientSecret = "YOUR_CLIENT_SECRET"
    static let authURL = "https://api-int.uscis.gov/oauth/accesstoken"
    static let baseURL = "https://api-int.uscis.gov/case-status"

    static func caseStatusURL(receiptNumber: String) -> String {
        return "\(baseURL)/\(receiptNumber)"
    }
}

// MARK: - Error Handling
enum APIError: LocalizedError, Identifiable {
    case invalidURL
    case networkError(Error)
    case unauthorized // 401
    case notFound // 404
    case unprocessableEntity(message: String) // 422
    case tooManyRequests // 429
    case decodingError(Error)
    case serverError(statusCode: Int)
    case unknown

    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized (401): Access token might be incorrect or expired."
        case .notFound:
            return "Not Found (404): The requested receipt number was not found."
        case .unprocessableEntity(let message):
            return "Unprocessable Entity (422): \(message). Check receipt number format."
        case .tooManyRequests:
            return "Too Many Requests (429): API rate limit exceeded."
        case .decodingError(let error):
            // Provide more detail for debugging if possible
             if let decodingError = error as? DecodingError {
                return "Decoding Error: \(decodingError.localizedDescription) - \(decodingError.failureReason ?? "Reason unknown")"
            }
            return "Decoding Error: Could not parse server response. \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server Error: Received status code \(statusCode)."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// For decoding 422 error messages specifically
struct APIErrorResponse: Decodable {
    let errors: [APIErrorDetail]?
    let message: String? // Sometimes the message is top-level
}

struct APIErrorDetail: Decodable {
    let code: String?
    let message: String
}

// MARK: - Mock Scenario Enum
enum MockErrorScenario: String, CaseIterable, Identifiable, Hashable {
    case none = "No Error (Success)"
    case unauthorized401 = "401 Unauthorized"
    case notFound404 = "404 Not Found"
    case unprocessableEntity422 = "422 Unprocessable Entity"
    case tooManyRequests429 = "429 Too Many Requests"
    case simulatedDecodingError = "Simulated Decoding Error"

    var id: Self { self }

     // Helper to map enum case to APIError for simulation
    func correspondingAPIError(customMessage: String = "Simulated error message.") -> APIError? {
        switch self {
        case .none:
            return nil
        case .unauthorized401:
            return .unauthorized
        case .notFound404:
            return .notFound
        case .unprocessableEntity422:
            return .unprocessableEntity(message: "The application receipt number is not formatted correctly (Mock).")
        case .tooManyRequests429:
            return .tooManyRequests
        case .simulatedDecodingError:
            // Simulate a low-level decoding issue
            return .decodingError(NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode mock data."]))
        }
    }
}


// MARK: - Data Models
struct CaseStatus: Decodable, Identifiable {
    // Add Identifiable conformance for use in lists or alerts if needed
    var id: String { caseStatus.receiptNumber }
    let caseStatus: CaseStatusDetail
    let message: String? // Make message optional as it might not always be present

    // Adjust coding keys if JSON keys differ from struct properties (snake_case vs camelCase)
    enum CodingKeys: String, CodingKey {
        case caseStatus = "case_status"
        case message
    }
}

struct CaseStatusDetail: Decodable {
    let receiptNumber: String
    let formType: String
    let submittedDate: String
    let modifiedDate: String
    let currentCaseStatusTextEn: String
    let currentCaseStatusDescEn: String
    let currentCaseStatusTextEs: String
    let currentCaseStatusDescEs: String
    let histCaseStatus: [HistoricalStatus]? // Decode as an array if it's a JSON array

    enum CodingKeys: String, CodingKey {
        case receiptNumber, formType, submittedDate, modifiedDate
        case currentCaseStatusTextEn = "current_case_status_text_en"
        case currentCaseStatusDescEn = "current_case_status_desc_en"
        case currentCaseStatusTextEs = "current_case_status_text_es"
        case currentCaseStatusDescEs = "current_case_status_desc_es"
        case histCaseStatus = "hist_case_status"
    }
}

// Example if hist_case_status is an array of objects
struct HistoricalStatus: Decodable, Identifiable {
     let id = UUID() // Simple identifiable conformance
     let date: String?
     let status: String?
     // Add other fields as needed
     enum CodingKeys: String, CodingKey {
         case date // Assuming JSON keys match
         case status
     }
 }


// MARK: - Data Fetcher (Async/Await)
protocol CaseStatusFetching {
    func fetchCaseStatus(receiptNumber: String, mockErrorScenario: MockErrorScenario?) async throws -> CaseStatus
}

class USCISCaseStatusFetcher: CaseStatusFetching {
    // Could make this non-singleton if needed, managed by ViewModel lifecycle
    static let shared = USCISCaseStatusFetcher()
    private var currentAccessToken: String?
    private var tokenExpiryTime: Date?

    private init() {}

    // MARK: - Public Fetch Method
    func fetchCaseStatus(receiptNumber: String, mockErrorScenario: MockErrorScenario? = nil) async throws -> CaseStatus {
        // Handle Mocking First
        if let mockScenario = mockErrorScenario, mockScenario != .none {
            return try await simulateMockResponse(mockScenario: mockScenario, receiptNumber: receiptNumber)
        }

        // Proceed with Live API Call
        let accessToken = try await getValidAccessToken()
        return try await performFetch(accessToken: accessToken, receiptNumber: receiptNumber)
    }

    // MARK: - Token Management
    private func getValidAccessToken() async throws -> String {
        if let token = currentAccessToken, let expiry = tokenExpiryTime, expiry > Date() {
            // print("Using cached access token.")
            return token
        }
        // print("Fetching new access token.")
        return try await fetchNewAccessToken()
    }

    private func fetchNewAccessToken() async throws -> String {
        guard let authURL = URL(string: Constants.authURL) else {
            throw APIError.invalidURL
        }

        let postString = "grant_type=client_credentials&client_id=\(Constants.clientID)&client_secret=\(Constants.clientSecret)"
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            guard httpResponse.statusCode == 200 else {
                // You might want to decode error response body here too
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }

            // Decode token response
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let accessToken = jsonResponse["access_token"] as? String,
                  let expiresIn = jsonResponse["expires_in"] as? TimeInterval else {
                throw APIError.decodingError(NSError(domain: "TokenDecoding", code: 1, userInfo: nil)) // Better error
            }

            self.currentAccessToken = accessToken
            self.tokenExpiryTime = Date().addingTimeInterval(expiresIn - 60) // Add a 60s buffer
            // print("Obtained new access token.")
            return accessToken

        } catch let error as APIError {
            throw error // Re-throw known API errors
        } catch {
            throw APIError.networkError(error) // Wrap other errors
        }
    }


    // MARK: - Core Data Fetching
    private func performFetch(accessToken: String, receiptNumber: String) async throws -> CaseStatus {
        guard let apiURL = URL(string: Constants.caseStatusURL(receiptNumber: receiptNumber)) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            let decoder = JSONDecoder()

            switch httpResponse.statusCode {
                case 200:
                    do {
                        let statusResponse = try decoder.decode(CaseStatus.self, from: data)
                        return statusResponse
                    } catch {
                        // Log the raw data for debugging decoding issues if needed
                         // print("Decoding failed. Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
                        throw APIError.decodingError(error)
                    }
                case 401:
                    // Token likely expired, clear it so next request fetches a new one
                    self.currentAccessToken = nil
                    self.tokenExpiryTime = nil
                    throw APIError.unauthorized
                case 404:
                    throw APIError.notFound
                case 422:
                    // Attempt to decode the specific error message
                    do {
                        let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                        let message = errorResponse.errors?.first?.message ?? errorResponse.message ?? "Invalid input (Receipt Number format?)"
                        throw APIError.unprocessableEntity(message: message)
                    } catch {
                        // Fallback if error response decoding fails
                        throw APIError.unprocessableEntity(message: "Invalid request format (unable to parse error details).")
                    }
                case 429:
                    throw APIError.tooManyRequests
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error // Re-throw known API errors
        } catch {
            throw APIError.networkError(error) // Wrap other network/URLSession errors
        }
    }


    // MARK: - Mocking Logic
    private func simulateMockResponse(mockScenario: MockErrorScenario, receiptNumber: String) async throws -> CaseStatus {
         // Simulate network delay
         try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        if let correspondingError = mockScenario.correspondingAPIError() {
            throw correspondingError // Throw the simulated error
        } else {
            // This handles MockErrorScenario.none (Success)
            return simulateSuccessResponse(receiptNumber: receiptNumber)
        }
    }

    func simulateSuccessResponse(receiptNumber: String) -> CaseStatus {
        // Example success response data
        return CaseStatus(
            caseStatus: CaseStatusDetail(
                receiptNumber: receiptNumber, // Use provided receipt number
                formType: "I-MOCK",
                submittedDate: "01-01-2024 10:00:00",
                modifiedDate: "01-02-2024 11:30:00",
                currentCaseStatusTextEn: "Case Was Mockingly Approved",
                currentCaseStatusDescEn: "This is a simulated success response. Your case looks great in this mock universe!",
                currentCaseStatusTextEs: "Caso Fue Aprobado (Simulado)",
                currentCaseStatusDescEs: "Esta es una respuesta simulada de éxito.",
                histCaseStatus: [ // Example historical data
                    HistoricalStatus(date: "01-01-2024", status: "Received"),
                    HistoricalStatus(date: "01-02-2024", status: "Approved")
                ]
            ),
            message: "Mock Success: Status retrieved fictitiously."
        )
    }
}


// MARK: - ViewModel (MVVM)
@MainActor // Ensure UI updates happen on the main thread
class CaseStatusViewModel: ObservableObject {

    @Published var receiptNumber: String = "" // Start empty or with a default
    @Published var caseStatus: CaseStatus? = nil
    @Published var apiError: APIError? = nil {
        didSet {
            // Trigger alert presentation when error is set
            shouldShowErrorAlert = apiError != nil
        }
    }
    @Published var shouldShowErrorAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedMockScenario: MockErrorScenario = .none // For Mock view

    // Dependency Injection: Inject the fetcher
    private let fetcher: CaseStatusFetching // Use the protocol

    init(fetcher: CaseStatusFetching = USCISCaseStatusFetcher.shared) { // Default to shared instance
        self.fetcher = fetcher
    }

    func fetchStatus(mode: OperationMode) async {
        guard !receiptNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            apiError = .unprocessableEntity(message: "Receipt number cannot be empty.")
            return
        }

        isLoading = true
        caseStatus = nil // Clear previous results
        apiError = nil

        // Determine mock scenario based on mode
        let scenarioForFetch = (mode == .mock) ? selectedMockScenario : nil

        do {
            let status = try await fetcher.fetchCaseStatus(receiptNumber: receiptNumber, mockErrorScenario: scenarioForFetch)
            self.caseStatus = status
        } catch let error as APIError {
            self.apiError = error
        } catch {
            // Catch any other unexpected errors
            self.apiError = .unknown
        }

        isLoading = false
    }

    // Helper to clear state
    func clearResult() {
        caseStatus = nil
        apiError = nil
        isLoading = false // Ensure loading stops if cleared during load
    }
}

// Enum to differentiate view modes
enum OperationMode {
    case live, mock
}

// MARK: - Reusable Views

// --- Card View Modifier ---
struct CardViewModifier: ViewModifier {
    var backgroundColor: Color = Color(.systemBackground) // Adapts to light/dark mode
    var cornerRadius: CGFloat = 15
    var shadowRadius: CGFloat = 5

    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.15), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    func cardStyle(backgroundColor: Color = Color(.systemBackground), cornerRadius: CGFloat = 15, shadowRadius: CGFloat = 5) -> some View {
        self.modifier(CardViewModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// --- Case Status Display Card ---
struct CaseStatusDisplayCard: View {
    let status: CaseStatusDetail // Takes the detail part

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill") // Example icon
                    .foregroundColor(.green)
                    .font(.title)
                 Text(status.currentCaseStatusTextEn)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                 Spacer() // Pushes content left
            }

            Text(status.currentCaseStatusDescEn)
                .font(.body)
                .foregroundColor(.secondary)

            Divider().padding(.vertical, 4)

            HStack {
                InfoItem(label: "Receipt #", value: status.receiptNumber)
                Spacer()
                InfoItem(label: "Form Type", value: status.formType)
            }

            HStack {
                InfoItem(label: "Submitted", value: formatDateString(status.submittedDate))
                Spacer()
                InfoItem(label: "Last Updated", value: formatDateString(status.modifiedDate))
            }

             // Optionally display history if needed
            if let history = status.histCaseStatus, !history.isEmpty {
                DisclosureGroup("History") {
                    VStack(alignment: .leading) {
                        ForEach(history) { item in
                            HStack {
                                Text(formatDateString(item.date ?? "N/A"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(item.status ?? "N/A")
                                    .font(.caption)
                                Spacer()
                            }.padding(.bottom, 2)
                        }
                    }
                }.font(.caption)
            }
        }
        .cardStyle()
    }

    // Basic date formatter helper
     private func formatDateString(_ dateString: String) -> String {
        // Input format: "MM-dd-yyyy HH:mm:ss"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Important!

        // Output format
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .short

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString // Return original if parsing fails
        }
    }
}

// --- Helper for label/value pairs ---
struct InfoItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.footnote)
                .fontWeight(.medium)
        }
    }
}


// MARK: - Glitch Text Components (Keep as is - Assumed functional)
struct GlitchText: View {
    let text: String
    let trigger: Bool
    let shadowColor: Color
    let keyframes: [LinearKeyframe]
    @State private var animationIndex: Int = 0
    // For smoother animation reset
    @State private var internalTrigger: Bool = false

    init(text: String, trigger: Bool, shadow: Color = .red, @GlitchKeyframeBuilder keyframes: () -> [LinearKeyframe]) {
        self.text = text
        self.trigger = trigger
        self.shadowColor = shadow
        self.keyframes = keyframes()
    }

    var body: some View {
         // Use a GeometryReader for potentially better offset calculations if needed
         // but simple Text should work for this effect
         Text(text)
            .foregroundColor(internalTrigger ? .white.opacity(0.8) : .primary) // Slightly transparent when glitching
            .shadow(
                color: shadowColor.opacity(internalTrigger ? keyframes[safe: animationIndex]?.frame.shadowOpacity ?? 0 : 0),
                radius: 0, // Keep radius 0 for sharp shadow effect
                x: internalTrigger ? keyframes[safe: animationIndex]?.frame.center ?? 0 : 0,
                y: 0
            )
             .offset(
                x: internalTrigger ? keyframes[safe: animationIndex]?.frame.top ?? 0 : 0,
                y: internalTrigger ? keyframes[safe: animationIndex]?.frame.bottom ?? 0 : 0
             )
            .onChange(of: trigger) {
                 if trigger {
                    animateGlitch()
                 } else {
                    // Optional: Could add a small fading out animation here if desired
                     internalTrigger = false // Immediately stop effect
                 }
             }
             // Animation happens when internalTrigger and animationIndex change
            .animation(.linear(duration: keyframes[safe: animationIndex]?.duration ?? 0.0), value: animationIndex)
             .animation(.easeInOut(duration: 0.1), value: internalTrigger) // Smooth on/off
    }


    func animateGlitch() {
        guard !keyframes.isEmpty else { return }
        internalTrigger = true // Start the visual effect state
        var cumulativeDelay: Double = 0

        for index in keyframes.indices {
            let keyframe = keyframes[index]
             DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay) {
                 // Check if the trigger is still active before updating index
                guard self.trigger else {
                    // If trigger turned off during animation, reset immediately
                    internalTrigger = false
                    return
                }
                 self.animationIndex = index
            }
            cumulativeDelay += keyframe.duration
        }

        // After the full animation duration, turn off the internal trigger
        // unless the external trigger is still on (e.g., continuous glitch)
         DispatchQueue.main.asyncAfter(deadline: .now() + cumulativeDelay) {
             if self.trigger == false { // Only turn off if external trigger is off
                 internalTrigger = false
             }
             // If trigger is still true, you might want to loop or stop here
             // Current logic stops the visual effect after one cycle
             // To loop: call animateGlitch() again conditionally
         }
    }
}

// Helper for safe array access
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct GlitchFrame {
    let top: CGFloat
    let center: CGFloat
    let bottom: CGFloat
    let shadowOpacity: Double

    init(top: CGFloat = 0, center: CGFloat = 0, bottom: CGFloat = 0, shadowOpacity: Double = 0) {
        self.top = top
        self.center = center
        self.bottom = bottom
        self.shadowOpacity = shadowOpacity
    }
}

struct LinearKeyframe: Identifiable { // Add Identifiable for easier loops if needed
     let id = UUID()
    let frame: GlitchFrame
    let duration: Double
}

@resultBuilder
struct GlitchKeyframeBuilder {
    static func buildBlock(_ keyframes: LinearKeyframe...) -> [LinearKeyframe] {
        return keyframes
    }
}

// -- Composition Function remains useful --
@ViewBuilder
func GlitchTextView(_ text: String, trigger: Bool) -> some View {
    ZStack {
        // Red Shadow Layer
         GlitchText(text: text, trigger: trigger, shadow: .red) {
            LinearKeyframe(frame: GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2), duration: 0.06)
            LinearKeyframe(frame: GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6), duration: 0.06)
            LinearKeyframe(frame: GlitchFrame(top: 1, center: 2, bottom: 4, shadowOpacity: 0.1), duration: 0.04) // Subtle mid-glitch
            LinearKeyframe(frame: GlitchFrame(top: -3, center: -3, bottom: 3, shadowOpacity: 0.8), duration: 0.08)
            LinearKeyframe(frame: GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4), duration: 0.05)
            LinearKeyframe(frame: GlitchFrame(top: 2, center: 0, bottom: 3, shadowOpacity: 0.1), duration: 0.07)
             LinearKeyframe(frame: GlitchFrame(), duration: 0.04) // End frame
        }

        // Green Shadow Layer (slightly different timing/offset)
         GlitchText(text: text, trigger: trigger, shadow: .green) {
            LinearKeyframe(frame: GlitchFrame(top: 0, center: 3, bottom: 0, shadowOpacity: 0.2), duration: 0.05)
            LinearKeyframe(frame: GlitchFrame(top: 4, center: 4, bottom: 4, shadowOpacity: 0.3), duration: 0.07)
            LinearKeyframe(frame: GlitchFrame(top: 3, center: 3, bottom: -3, shadowOpacity: 0.5), duration: 0.06)
             LinearKeyframe(frame: GlitchFrame(top: -2, center: 1, bottom: -1, shadowOpacity: 0.2), duration: 0.05) // Subtle mid-glitch
            LinearKeyframe(frame: GlitchFrame(top: 0, center: 4, bottom: -4, shadowOpacity: 0.6), duration: 0.08)
            LinearKeyframe(frame: GlitchFrame(top: 0, center: -3, bottom: 0, shadowOpacity: 0.3), duration: 0.06)
             LinearKeyframe(frame: GlitchFrame(), duration: 0.04) // End frame
        }

         // Base Text (visible when not glitching)
         Text(text)
             .opacity(trigger ? 0 : 1) // Hide when glitching
             .animation(.easeInOut(duration: 0.1), value: trigger)


    }
    // Apply font/padding to the ZStack container
     .font(.title2) // Example: Apply desired font here
}


// MARK: - Main Views (Using ViewModel and Cards)

struct CaseStatusCheckerView: View {
    // Use @StateObject if the view creates the VM, @ObservedObject if passed in
    @ObservedObject var viewModel: CaseStatusViewModel
    let mode: OperationMode // To configure UI elements

    var body: some View {
        ScrollView { // Use ScrollView for potentially long content
            VStack(spacing: 20) {
                // --- Header ---
                Text("Where is my case status?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                 Image("My-meme-original") // Ensure this image is in your Assets
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(10)
                    .padding(.bottom)

                 // Use GlitchTextView conditional on loading state
                 if viewModel.isLoading {
                     GlitchTextView(titleText, trigger: viewModel.isLoading)
                         .padding(.horizontal)
                         .transition(.opacity) // Smooth appearance/disappearance
                 } else {
                    Text(titleText)
                         .font(.title2)
                         .padding(.horizontal)
                         .transition(.opacity)
                 }


                // --- Input Section ---
                VStack {
                    if mode == .mock {
                        Picker("Mock Scenario", selection: $viewModel.selectedMockScenario) {
                            ForEach(MockErrorScenario.allCases) { scenario in
                                Text(scenario.rawValue).tag(scenario)
                            }
                        }
                        .pickerStyle(.menu) // Or .segmented if preferred
                        .padding(.bottom, 5)
                    }

                    TextField("Enter Receipt Number", text: $viewModel.receiptNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.allCharacters) // USCIS receipts are usually uppercase
                        .disableAutocorrection(true)
                        .keyboardType(.asciiCapable) // Limit keyboard if possible
                        .disabled(viewModel.isLoading) // Disable during loading

                    Button(action: {
                        // Dismiss keyboard
                         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        Task {
                            await viewModel.fetchStatus(mode: mode)
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                                Text(mode == .live ? "Checking Live..." : "Running Mock...")
                            } else {
                                Image(systemName: mode == .live ? "magnifyingglass" : "hammer.fill")
                                Text(mode == .live ? "Check Live Status" : "Run Mock Test")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading || viewModel.receiptNumber.isEmpty)
                    .padding(.top, 10)

                }
                .cardStyle(backgroundColor: Color(.secondarySystemBackground)) // Subtle background
                .padding(.horizontal)


                // --- Result Display Area ---
                Group { // Group helps with conditional logic clarity
                    if !viewModel.isLoading { // Only show results when not loading
                        if let status = viewModel.caseStatus {
                            CaseStatusDisplayCard(status: status.caseStatus) // Pass the detail
                                 .transition(.scale.combined(with: .opacity)) // Nice transition
                        } else if viewModel.apiError == nil { // Show placeholder only if no status AND no error
                            Text("Enter a receipt number and tap '\(mode == .live ? "Check Live Status" : "Run Mock Test")'.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .padding(.top, 30)
                                 .transition(.opacity)
                        }
                     } else {
                         // Optionally show a dedicated larger progress view here instead of just button text
                         ProgressView()
                            .scaleEffect(1.5)
                            .padding(.top, 50)
                            .transition(.opacity)
                     }
                 }
                .padding(.horizontal) // Apply padding to the result area
                .animation(.easeInOut, value: viewModel.isLoading)
                .animation(.easeInOut, value: viewModel.caseStatus?.id) // Animate when status changes
                .animation(.easeInOut, value: viewModel.apiError?.id) // Animate when error changes

                Spacer() // Pushes content to the top
            }
            .padding(.vertical) // Add padding around the main VStack
        }
        .navigationTitle(titleText) // Set navigation title if embedded in NavigationView
         .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.shouldShowErrorAlert, presenting: viewModel.apiError) { error in
             // Define alert buttons if needed
             Button("OK") {
                 // Optional: Action on dismiss
                 viewModel.clearResult() // Example: clear error after showing alert
             }
         } message: { error in
             Text(error.localizedDescription) // Show localized description from APIError
         }
         // Clear results if navigating away (optional, depends on desired behavior)
         .onDisappear {
            // viewModel.clearResult()
         }
    }


    // Helper for consistent titles
    private var titleText: String {
        mode == .live ? "USCIS Case Status - Live" : "USCIS Case Status - Mock"
    }
}

// MARK: - Root View (ContentView)
struct WhereIsMyStatusContentView: View {
    // Create separate ViewModel instances for each tab's state
    @StateObject private var liveViewModel = CaseStatusViewModel()
    @StateObject private var mockViewModel = CaseStatusViewModel()

    var body: some View {
        TabView {
            // Embed each view in a NavigationView for titles/potential navigation
             NavigationView {
                 CaseStatusCheckerView(viewModel: liveViewModel, mode: .live)
                     // .navigationTitle("Live API Check") // Title set within the view now
             }
            .tabItem {
                Label("Live API", systemImage: "cloud.and.bolt.fill") // Updated icon
            }
            .tag(OperationMode.live)

             NavigationView {
                 CaseStatusCheckerView(viewModel: mockViewModel, mode: .mock)
                    // .navigationTitle("Mock Tests") // Title set within the view now
             }
            .tabItem {
                Label("Mock Tests", systemImage: "hammer.circle.fill") // Updated icon
            }
            .tag(OperationMode.mock)
        }
    }
}

#Preview("Where Is My Status Content View") {
    WhereIsMyStatusContentView()
}
//
//// MARK: - Preview Provider
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // --- Preview with Default State ---
//        ContentView()
//            .previewDisplayName("Default")
//
//         // --- Preview Live View with Mocked Success Data ---
//        let successFetcher = MockCaseStatusFetcher(mockResult: .success(USCISCaseStatusFetcher.shared.simulateSuccessResponse(receiptNumber: "PRE1234567890")))
//        let successVM = CaseStatusViewModel(fetcher: successFetcher)
//        successVM.receiptNumber = "PRE1234567890" // Pre-fill for preview
//         // Manually set status for preview display
//         Task { @MainActor in successVM.caseStatus = USCISCaseStatusFetcher.shared.simulateSuccessResponse(receiptNumber: "PRE1234567890") }
//
//         NavigationView {
//            CaseStatusCheckerView(viewModel: successVM, mode: .live)
//         }
//         .previewDisplayName("Live - Success State")
//
//
//         // --- Preview Mock View with Forced Error ---
//        let errorFetcher = MockCaseStatusFetcher(mockResult: .failure(.tooManyRequests))
//        let errorVM = CaseStatusViewModel(fetcher: errorFetcher)
//        errorVM.receiptNumber = "ERR9876543210"
//        errorVM.selectedMockScenario = .tooManyRequests429 // Match the fetcher's error
//         // Manually set error for preview display
//        Task { @MainActor in errorVM.apiError = .tooManyRequests }
//
//          NavigationView {
//             CaseStatusCheckerView(viewModel: errorVM, mode: .mock)
//          }
//         .previewDisplayName("Mock - Error State")
//
//         // --- Preview Live View in Loading State ---
//         let loadingVM = CaseStatusViewModel(fetcher: MockCaseStatusFetcher(mockResult: .success(USCISCaseStatusFetcher.shared.simulateSuccessResponse(receiptNumber: "LOD111")), delay: 5.0)) // Long delay
////         Task { @MainActor in loadingVM.isLoading = true } // Manually set loading
//          NavigationView {
//             CaseStatusCheckerView(viewModel: loadingVM, mode: .live)
//                 .onAppear {
//                     Task { @MainActor in loadingVM.isLoading = true } // Set loading on appear for preview
//                 }
//          }
//         .previewDisplayName("Live - Loading State")
//    }
//}
//
//// --- Mock Fetcher for Previews ---
//class MockCaseStatusFetcher: CaseStatusFetching {
//    let mockResult: Result<CaseStatus, APIError>
//     let delay: TimeInterval? // Optional delay in seconds
//
//    init(mockResult: Result<CaseStatus, APIError>, delay: TimeInterval? = nil) {
//        self.mockResult = mockResult
//        self.delay = delay
//    }
//
//    func fetchCaseStatus(receiptNumber: String, mockErrorScenario: MockErrorScenario?) async throws -> CaseStatus {
//        if let delay = delay {
//            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
//        }
//
//        switch mockResult {
//        case .success(let status):
//            // Return a copy maybe, or the direct mock status
//            return status
//        case .failure(let error):
//            throw error
//        }
//    }
//}
