////
////  USCISCaseStatusView.swift
////  MyApp
////
////  Created by Cong Le on 2/9/25.
////
//import SwiftUI
//
//// Global Enums and Structs
//
//// APIError enum
//enum APIError: LocalizedError {
//    case unauthorized
//    case notFound
//    case unprocessableEntity(message: String)
//    case tooManyRequests
//    case unknownError(statusCode: Int)
//
//    var errorDescription: String? {
//        switch self {
//        case .unauthorized:
//            return "Unauthorized: Access token incorrect or expired."
//        case .notFound:
//            return "Not Found: Receipt Number not found."
//        case .unprocessableEntity(let message):
//            return "Unprocessable Entity: \(message). Invalid Receipt Number Format."
//        case .tooManyRequests:
//            return "Too Many Requests: TPS or daily quota exceeded."
//        case .unknownError(let statusCode):
//            return "Unknown Error: Unexpected error with status code \(statusCode)."
//        }
//    }
//}
//
//// Enum to represent mock error scenarios for testing
//enum MockErrorScenario: String, CaseIterable, Identifiable {
//    case none = "No Error (Success)"
//    case unauthorized401 = "401 Unauthorized"
//    case notFound404 = "404 Not Found"
//    case unprocessableEntity422 = "422 Unprocessable Entity"
//    case tooManyRequests429 = "429 Too Many Requests"
//
//    var id: Self { self }
//}
//
//// Data Models
//struct CaseStatus: Decodable {
//    let case_status: CaseStatusDetail
//    let message: String
//}
//
//struct CaseStatusDetail: Decodable {
//    let receiptNumber: String
//    let formType: String
//    let submittedDate: String
//    let modifiedDate: String
//    let current_case_status_text_en: String
//    let current_case_status_desc_en: String
//    let current_case_status_text_es: String
//    let current_case_status_desc_es: String
//    let hist_case_status: String?
//}
//
//// Shared Data Fetcher
//class USCISCaseStatusFetcher {
//    static let shared = USCISCaseStatusFetcher()
//
//    private init() {}
//
//    let clientID = "YOUR_CLIENT_ID" // Replace with your actual Client ID
//    let clientSecret = "YOUR_CLIENT_SECRET" // Replace with your actual Client Secret
//
//    // Fetch case status with options for live API or mock data
//    func fetchCaseStatus(receiptNumber: String, mockErrorScenario: MockErrorScenario? = nil, completion: @escaping (Result<CaseStatus, APIError>) -> Void) {
//
//        if let mockScenario = mockErrorScenario, mockScenario != .none {
//            simulateMockResponse(mockScenario: mockScenario, completion: completion)
//            return
//        }
//
//        // For mockErrorScenario == .none, proceed to fetch live data
//        getAccessToken { [weak self] tokenResult in
//            switch tokenResult {
//            case .success(let accessToken):
//                self?.performFetch(accessToken: accessToken, receiptNumber: receiptNumber, completion: completion)
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
//        guard let authURL = URL(string: "https://api-int.uscis.gov/oauth/accesstoken") else {
//            completion(.failure(.unknownError(statusCode: 0)))
//            return
//        }
//
//        let postString = "grant_type=client_credentials&client_id=\(clientID)&client_secret=\(clientSecret)"
//        var request = URLRequest(url: authURL)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpBody = postString.data(using: .utf8)
//
//        URLSession.shared.dataTask(with: request) { data, response, _ in
//            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
//                completion(.failure(.unknownError(statusCode: 0)))
//                return
//            }
//
//            do {
//                if httpResponse.statusCode == 200 {
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    if let accessToken = jsonResponse?["access_token"] as? String {
//                        completion(.success(accessToken))
//                    } else {
//                        completion(.failure(.unknownError(statusCode: httpResponse.statusCode)))
//                    }
//                } else {
//                    completion(.failure(.unknownError(statusCode: httpResponse.statusCode)))
//                }
//            } catch {
//                completion(.failure(.unknownError(statusCode: 0)))
//            }
//        }.resume()
//    }
//
//    private func performFetch(accessToken: String, receiptNumber: String, completion: @escaping (Result<CaseStatus, APIError>) -> Void) {
//        guard let apiURL = URL(string: "https://api-int.uscis.gov/case-status/\(receiptNumber)") else {
//            completion(.failure(.unknownError(statusCode: 0)))
//            return
//        }
//
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { data, response, _ in
//            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
//                completion(.failure(.unknownError(statusCode: 0)))
//                return
//            }
//
//            switch httpResponse.statusCode {
//            case 200:
//                do {
//                    let decoder = JSONDecoder()
//                    let statusResponse = try decoder.decode(CaseStatus.self, from: data)
//                    completion(.success(statusResponse))
//                } catch {
//                    completion(.failure(.unknownError(statusCode: httpResponse.statusCode)))
//                }
//            case 401:
//                completion(.failure(.unauthorized))
//            case 404:
//                completion(.failure(.notFound))
//            case 422:
//                do {
//                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let errorsArray = jsonResponse["errors"] as? [[String: Any]],
//                       let firstError = errorsArray.first,
//                       let message = firstError["message"] as? String {
//                        completion(.failure(.unprocessableEntity(message: message)))
//                    } else {
//                        completion(.failure(.unprocessableEntity(message: "Invalid Receipt Number Format")))
//                    }
//                } catch {
//                    completion(.failure(.unprocessableEntity(message: "Invalid Receipt Number Format")))
//                }
//            case 429:
//                completion(.failure(.tooManyRequests))
//            default:
//                completion(.failure(.unknownError(statusCode: httpResponse.statusCode)))
//            }
//
//        }.resume()
//    }
//
//    private func simulateMockResponse(mockScenario: MockErrorScenario, completion: @escaping (Result<CaseStatus, APIError>) -> Void) {
//        // Simulate error responses or success based on mockScenario
//        switch mockScenario {
//        case .unauthorized401:
//            completion(.failure(.unauthorized))
//        case .notFound404:
//            completion(.failure(.notFound))
//        case .unprocessableEntity422:
//            let errorMessage = "The application receipt number is not formatted correctly."
//            completion(.failure(.unprocessableEntity(message: errorMessage)))
//        case .tooManyRequests429:
//            completion(.failure(.tooManyRequests))
//        case .none:
//            simulateSuccessResponse(completion: completion)
//        }
//    }
//
//    private func simulateSuccessResponse(completion: @escaping (Result<CaseStatus, APIError>) -> Void) {
//        // Example success response data - customize as needed
//        let mockSuccessData = """
//        {
//          "case_status": {
//            "receiptNumber": "EAC9999103403",
//            "formType": "I-130",
//            "submittedDate": "09-05-2023 14:28:46",
//            "modifiedDate": "09-05-2023 14:28:46",
//            "current_case_status_text_en": "Case Was Approved (Mock Success)",
//            "current_case_status_desc_en": "This is a mock success response for testing purposes.",
//            "current_case_status_text_es": "Caso Fue Aprobado (Mock Success)",
//            "current_case_status_desc_es": "Esta es una respuesta simulada de éxito para fines de prueba.",
//            "hist_case_status": []
//          },
//          "message": "Mock Success: Case status retrieved successfully."
//        }
//        """.data(using: .utf8)!
//
//        do {
//            let decoder = JSONDecoder()
//            let statusResponse = try decoder.decode(CaseStatus.self, from: mockSuccessData)
//            completion(.success(statusResponse))
//        } catch {
//            completion(.failure(.unknownError(statusCode: 200)))
//        }
//    }
//}
//
//// Reusable Views
//
//// View to display Case Status information
//struct CaseStatusDisplayView: View {
//    let status: CaseStatus
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Case Status: \(status.case_status.current_case_status_text_en)")
//                .font(.headline)
//            Text("Description: \(status.case_status.current_case_status_desc_en)")
//                .font(.body)
//            Text("Form Type: \(status.case_status.formType)")
//                .font(.caption)
//            Text("Receipt Number: \(status.case_status.receiptNumber)")
//                .font(.caption)
//        }
//        .padding()
//    }
//}
//
//// View to display Errors
//struct ErrorView: View {
//    let error: APIError
//
//    var body: some View {
//        Text("Error: \(error.localizedDescription)")
//            .foregroundColor(.red)
//            .padding()
//    }
//}
//
//// Glitch Text Effect Components
//
//// Assuming you have the full implementations of GlitchText, GlitchFrame, LinearKeyframe, etc.
//// For the purpose of this example, simplified versions are provided.
//
//struct GlitchText: View {
//    let text: String
//    let trigger: Bool
//    let shadowColor: Color
//    let keyframes: [LinearKeyframe]
//    @State private var animationIndex: Int = 0
//
//    init(text: String, trigger: Bool, shadow: Color = .red, @GlitchKeyframeBuilder keyframes: () -> [LinearKeyframe]) {
//        self.text = text
//        self.trigger = trigger
//        self.shadowColor = shadow
//        self.keyframes = keyframes()
//    }
//
//    var body: some View {
//        Text(text)
//            .foregroundColor(trigger ? .white : .primary)
//            .shadow(color: shadowColor.opacity(trigger ? keyframes[animationIndex].frame.shadowOpacity : 0), radius: 0, x: trigger ? keyframes[animationIndex].frame.center : 0, y: 0)
//            .offset(x: trigger ? keyframes[animationIndex].frame.top : 0, y: trigger ? keyframes[animationIndex].frame.bottom : 0)
//            .onAppear {
//                if trigger {
//                    animateGlitch()
//                }
//            }
//    }
//
//    func animateGlitch() {
//        guard !keyframes.isEmpty else { return }
//        animationIndex = 0
//        withAnimation(.linear(duration: keyframes[animationIndex].duration)) {
//            animationIndex = 0
//        }
//        for index in 1..<keyframes.count {
//            let delay = keyframes[0..<index].map { $0.duration }.reduce(0, +)
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                withAnimation(.linear(duration: keyframes[index].duration)) {
//                    animationIndex = index
//                }
//            }
//        }
//    }
//}
//
//struct GlitchFrame {
//    let top: CGFloat
//    let center: CGFloat
//    let bottom: CGFloat
//    let shadowOpacity: Double
//
//    init(top: CGFloat = 0, center: CGFloat = 0, bottom: CGFloat = 0, shadowOpacity: Double = 0) {
//        self.top = top
//        self.center = center
//        self.bottom = bottom
//        self.shadowOpacity = shadowOpacity
//    }
//}
//
//struct LinearKeyframe {
//    let frame: GlitchFrame
//    let duration: Double
//}
//
//@resultBuilder
//struct GlitchKeyframeBuilder {
//    static func buildBlock(_ keyframes: LinearKeyframe...) -> [LinearKeyframe] {
//        return keyframes
//    }
//}
//
//// GlitchTextView function
//@ViewBuilder
//func GlitchTextView(_ text: String, trigger: Bool) -> some View {
//    ZStack {
//        GlitchText(text: text, trigger: trigger, shadow: .red) {
//            LinearKeyframe(
//                frame: GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(),
//                duration: 0.1
//            )
//        }
//
//        GlitchText(text: text, trigger: trigger, shadow: .green) {
//            LinearKeyframe(
//                frame: GlitchFrame(top: 0, center: 5, bottom: 0, shadowOpacity: 0.2),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.3),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: 5, center: 5, bottom: -5, shadowOpacity: 0.5),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: 0, center: 5, bottom: -5, shadowOpacity: 0.6),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(top: 0, center: -5, bottom: 0, shadowOpacity: 0.3),
//                duration: 0.1
//            )
//            LinearKeyframe(
//                frame: GlitchFrame(),
//                duration: 0.1
//            )
//        }
//    }
//}
//
//// Views
//
//// Live API View
//struct LiveAPIView: View {
//    @State private var caseStatus: CaseStatus? = nil
//    @State private var apiError: APIError? = nil
//    @State private var receiptNumber: String = "EAC9999103402" // Default receipt number for testing
//    @State private var triggerGlitch: Bool = false // State variable to trigger glitch effect
//
//    var body: some View {
//        VStack {
//            Text("Where is my case status?").font(.largeTitle)
//            Image("My-meme-original").resizable().frame(width: 400, height: 300)
//            // Conditionally display title
//            if triggerGlitch {
//                GlitchTextView("USCIS Case Status - Live API", trigger: triggerGlitch)
//                    .font(.title2)
//                    .padding()
//            } else {
//                Text("USCIS Case Status - Live API")
//                    .font(.title2)
//                    .padding()
//            }
//
//            TextField("Enter Receipt Number", text: $receiptNumber)
//                .padding()
//                .border(Color.gray)
//                .padding(.horizontal)
//
//            Button("Get Case Status") {
//                apiError = nil
//                triggerGlitch = true
//                // Reset trigger after glitch effect duration
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                    triggerGlitch = false
//                }
//                fetchCaseStatus()
//            }
//            .padding()
//
//            if let status = caseStatus {
//                CaseStatusDisplayView(status: status) // Reusable view to display case status
//            } else if let error = apiError {
//                ErrorView(error: error) // Reusable error view
//            } else {
//                Text("Enter receipt number and fetch case status from live API.")
//                    .padding()
//            }
//        }
//        .padding()
//    }
//
//    func fetchCaseStatus() {
//        USCISCaseStatusFetcher.shared.fetchCaseStatus(receiptNumber: receiptNumber) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let status):
//                    self.caseStatus = status
//                    self.apiError = nil
//                case .failure(let error):
//                    self.apiError = error
//                    self.caseStatus = nil
//                }
//            }
//        }
//    }
//}
//
//// Mock Tests View
//struct MockTestView: View {
//    @State private var caseStatus: CaseStatus? = nil
//    @State private var apiError: APIError? = nil
//    @State private var receiptNumber: String = "EAC9999103402"
//    @State private var mockErrorScenario: MockErrorScenario = .none
//    @State private var triggerGlitch: Bool = false // State variable to trigger glitch effect
//
//    var body: some View {
//        VStack {
//            Text("Where is my case status?").font(.largeTitle)
//            Image("My-meme-original").resizable().frame(width: 400, height: 300)
//            // Conditionally display title
//            if triggerGlitch {
//                GlitchTextView("USCIS Case Status - Mock Tests", trigger: triggerGlitch)
//                    .font(.title2)
//                    .padding()
//            } else {
//                Text("USCIS Case Status - Mock Tests")
//                    .font(.title2)
//                    .padding()
//            }
//
//            Picker("Mock Error Scenario", selection: $mockErrorScenario) {
//                ForEach(MockErrorScenario.allCases) { scenario in
//                    Text(scenario.rawValue).tag(scenario)
//                }
//            }
//            .padding(.horizontal)
//
//            TextField("Enter Receipt Number", text: $receiptNumber)
//                .padding()
//                .border(Color.gray)
//                .padding(.horizontal)
//
//            Button("Run Mock Test") {
//                apiError = nil
//                triggerGlitch = true
//                // Reset trigger after glitch effect duration
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                    triggerGlitch = false
//                }
//                fetchCaseStatus()
//            }
//            .padding()
//
//            if let status = caseStatus {
//                CaseStatusDisplayView(status: status) // Reusable view to display case status
//            } else if let error = apiError {
//                ErrorView(error: error) // Reusable error view
//            } else {
//                Text("Select a mock error scenario and run test.")
//                    .padding()
//            }
//        }
//        .padding()
//    }
//
//    func fetchCaseStatus() {
//        USCISCaseStatusFetcher.shared.fetchCaseStatus(receiptNumber: receiptNumber, mockErrorScenario: mockErrorScenario) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let status):
//                    self.caseStatus = status
//                    self.apiError = nil
//                case .failure(let error):
//                    self.apiError = error
//                    self.caseStatus = nil
//                }
//            }
//        }
//    }
//}
//
//// Main ContentView with TabView
//struct ContentView: View {
//    var body: some View {
//        TabView {
//            LiveAPIView()
//                .tabItem {
//                    Label("Live API", systemImage: "cloud.fill")
//                }
//
//            MockTestView()
//                .tabItem {
//                    Label("Mock Tests", systemImage: "hammer.fill")
//                }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
