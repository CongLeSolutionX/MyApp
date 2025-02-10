//
//  USCISCaseStatusView.swift
//  MyApp
//
//  Created by Cong Le on 2/9/25.
//
import SwiftUI

// APIError enum remains the same as in the previous response

enum APIError: LocalizedError {
    case unauthorized
    case notFound
    case unprocessableEntity(message: String)
    case tooManyRequests
    case unknownError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized: Mock Error - Access token incorrect or expired."
        case .notFound:
            return "Not Found: Mock Error - Receipt Number not found."
        case .unprocessableEntity(let message):
            return "Unprocessable Entity: Mock Error - \(message). Invalid Receipt Number Format."
        case .tooManyRequests:
            return "Too Many Requests: Mock Error - TPS or daily quota exceeded."
        case .unknownError(let statusCode):
            return "Unknown Error: Mock Error - Unexpected error with status code \(statusCode)."
        }
    }
}


struct USCISCaseStatusView: View {
    @State private var caseStatus: CaseStatus? = nil
    @State private var accessToken: String? = nil
    @State private var apiError: APIError? = nil
    @State private var receiptNumber: String = "EAC9999103402"

    @State private var mockErrorScenario: MockErrorScenario = .none // State to select mock error scenario


    // Enum to represent mock error scenarios for testing
    enum MockErrorScenario: String, CaseIterable, Identifiable {
        case none = "No Error (Live API)"
        case unauthorized401 = "401 Unauthorized"
        case notFound404 = "404 Not Found"
        case unprocessableEntity422 = "422 Unprocessable Entity"
        case tooManyRequests429 = "429 Too Many Requests"

        var id: Self { self }
    }


    var body: some View {
        VStack {
            Text("USCIS Case Status Checker")
                .font(.largeTitle)
                .padding()

            Picker("Mock Error Scenario", selection: $mockErrorScenario) { // Picker to choose mock scenario
                ForEach(MockErrorScenario.allCases) { scenario in
                    Text(scenario.rawValue).tag(scenario)
                }
            }
            .padding(.horizontal)


            TextField("Enter Receipt Number", text: $receiptNumber)
                .padding()
                .border(Color.gray)
                .padding(.horizontal)

            Button("Get Case Status") {
                apiError = nil
                getAccessTokenAndFetchCaseStatus()
            }
            .padding()

            if let status = caseStatus {
                VStack(alignment: .leading) {
                    Text("Case Status: \(status.case_status.current_case_status_text_en)")
                        .font(.headline)
                    Text("Description: \(status.case_status.current_case_status_desc_en)")
                        .font(.body)
                    Text("Form Type: \(status.case_status.formType)")
                        .font(.caption)
                    Text("Receipt Number: \(status.case_status.receiptNumber)")
                        .font(.caption)
                }
                .padding()
            } else if let error = apiError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Enter receipt number and fetch case status.")
                    .padding()
            }
        }
        .padding()
    }

    func getAccessTokenAndFetchCaseStatus() {
        getAccessToken { token, error in
            if let token = token {
                accessToken = token
                fetchCaseStatus(accessToken: token, receiptNumber: receiptNumber)
            } else if let error = error {
                apiError = .unknownError(statusCode: 0) // Indicate token fetch failed with unknown code
            }
        }
    }


    func getAccessToken(completion: @escaping (String?, Error?) -> Void) {
        // For simplicity, in this mock setup, we always succeed in getting a token.
        // In a real app, you might want to mock token retrieval errors as well for full testing.
        completion("mock_access_token", nil) // Mock access token for local testing
    }


    func fetchCaseStatus(accessToken: String, receiptNumber: String) {

        if mockErrorScenario != .none { // Check if we are in a mock error scenario
            // Simulate error response based on mockErrorScenario
            switch mockErrorScenario {
            case .unauthorized401:
                simulateErrorResponse(statusCode: 401, error: .unauthorized)
                return
            case .notFound404:
                simulateErrorResponse(statusCode: 404, error: .notFound)
                return
            case .unprocessableEntity422:
                // Simulate 422 error with a message, you can customize the message
                let errorMessage = "The application receipt number is not formatted correctly."
                simulateErrorResponse(statusCode: 422, error: .unprocessableEntity(message: errorMessage), jsonResponse: ["errors": [["message": errorMessage]]]) // Simulate JSON error response
                return
            case .tooManyRequests429:
                simulateErrorResponse(statusCode: 429, error: .tooManyRequests)
                return
            case .none:
                break // Fall through to normal API call if no mock error is selected
            }
        }


        guard let apiURL = URL(string: "https://api-int.uscis.gov/case-status/\(receiptNumber)") else {
            apiError = .unknownError(statusCode: 0)
            return
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: 0)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: 0)
                }
                return
            }


            switch httpResponse.statusCode {
            case 200: // Success - remains the same
                do {
                    let decoder = JSONDecoder()
                    let statusResponse = try decoder.decode(CaseStatus.self, from: data)
                    DispatchQueue.main.async {
                        caseStatus = statusResponse
                        apiError = nil
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiError = .unknownError(statusCode: httpResponse.statusCode)
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    apiError = .unauthorized
                }
            case 404:
                DispatchQueue.main.async {
                    apiError = .notFound
                }
            case 422:
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorsArray = jsonResponse["errors"] as? [[String: Any]],
                       let firstError = errorsArray.first,
                       let message = firstError["message"] as? String {
                        DispatchQueue.main.async {
                            apiError = .unprocessableEntity(message: message)
                        }
                    } else {
                        DispatchQueue.main.async {
                            apiError = .unprocessableEntity(message: "Invalid Receipt Number Format")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiError = .unprocessableEntity(message: "Invalid Receipt Number Format")
                    }
                }
            case 429:
                DispatchQueue.main.async {
                    apiError = .tooManyRequests
                }
            default:
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: httpResponse.statusCode)
                }
            }
        }.resume()
    }


    // Helper function to simulate API error responses
    func simulateErrorResponse(statusCode: Int, error: APIError, jsonResponse: [String: Any]? = nil) {
        DispatchQueue.main.async {
            apiError = error // Set the APIError state to the passed error
        }
    }
}


// CaseStatus and CaseStatusDetail structs remain the same

struct CaseStatus: Decodable {
    let case_status: CaseStatusDetail
    let message: String
}

struct CaseStatusDetail: Decodable {
    let receiptNumber: String
    let formType: String
    let submittedDate: String
    let modifiedDate: String
    let current_case_status_text_en: String
    let current_case_status_desc_en: String
    let current_case_status_text_es: String
    let current_case_status_desc_es: String
    let hist_case_status: String?
}

struct LiveAPIView: View {
    @State private var caseStatus: CaseStatus? = nil
    @State private var accessToken: String? = nil
    @State private var apiError: APIError? = nil
    @State private var receiptNumber: String = "EAC9999103402" // Default receipt number for testing

    let clientID = "YOUR_CLIENT_ID" // Replace with your actual Client ID
    let clientSecret = "YOUR_CLIENT_SECRET" // Replace with your actual Client Secret

    var body: some View {
        VStack {
            Text("USCIS Case Status - Live API")
                .font(.title2)
                .padding()

            TextField("Enter Receipt Number", text: $receiptNumber)
                .padding()
                .border(Color.gray)
                .padding(.horizontal)

            Button("Get Case Status") {
                apiError = nil
                getAccessTokenAndFetchCaseStatus()
            }
            .padding()

            if let status = caseStatus {
                CaseStatusDisplayView(status: status) // Reusable view to display case status
            } else if let error = apiError {
                ErrorView(error: error) // Reusable error view
            } else {
                Text("Enter receipt number and fetch case status from live API.")
                    .padding()
            }
        }
        .padding()
    }

    func getAccessTokenAndFetchCaseStatus() {
        getAccessToken { token, error in
            if let token = token {
                accessToken = token
                fetchCaseStatus(accessToken: token, receiptNumber: receiptNumber)
            } else if let error = error {
                apiError = .unknownError(statusCode: 0)
            }
        }
    }

    func getAccessToken(completion: @escaping (String?, Error?) -> Void) {
        guard let authURL = URL(string: "https://api-int.uscis.gov/oauth/accesstoken") else {
            completion(nil, URLError(.badURL))
            return
        }

        let postString = "grant_type=client_credentials&client_id=\(clientID)&client_secret=\(clientSecret)"
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            // ... (Access token retrieval code - same as in previous response) ...
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(nil, URLError(.badServerResponse))
                return
            }


            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let accessToken = jsonResponse?["access_token"] as? String {
                    completion(accessToken, nil)
                } else if let errorDescription = jsonResponse?["error_description"] as? String{
                    completion(nil, NSError(domain: "AccessTokenError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve access token. Server message: \(errorDescription)"]))
                }
                 else {
                    completion(nil, NSError(domain: "AccessTokenError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve access token"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    func fetchCaseStatus(accessToken: String, receiptNumber: String) {
        guard let apiURL = URL(string: "https://api-int.uscis.gov/case-status/\(receiptNumber)") else {
            apiError = .unknownError(statusCode: 0)
            return
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // ... (Case status fetching and error handling code - same as in previous response's `fetchCaseStatus` for live API calls) ...
            if let error = error {
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: 0)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: 0)
                }
                return
            }

            switch httpResponse.statusCode {
            case 200: // Success
                do {
                    let decoder = JSONDecoder()
                    let statusResponse = try decoder.decode(CaseStatus.self, from: data)
                    DispatchQueue.main.async {
                        caseStatus = statusResponse
                        apiError = nil
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiError = .unknownError(statusCode: httpResponse.statusCode)
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    apiError = .unauthorized
                }
            case 404:
                DispatchQueue.main.async {
                    apiError = .notFound
                }
            case 422:
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorsArray = jsonResponse["errors"] as? [[String: Any]],
                       let firstError = errorsArray.first,
                       let message = firstError["message"] as? String {
                        DispatchQueue.main.async {
                            apiError = .unprocessableEntity(message: message)
                        }
                    } else {
                        DispatchQueue.main.async {
                            apiError = .unprocessableEntity(message: "Invalid Receipt Number Format")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiError = .unprocessableEntity(message: "Invalid Receipt Number Format")
                    }
                }
            case 429:
                DispatchQueue.main.async {
                    apiError = .tooManyRequests
                }
            default:
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: httpResponse.statusCode)
                }
            }
        }.resume()
    }
}


struct MockTestView: View {
    @State private var caseStatus: CaseStatus? = nil
    @State private var apiError: APIError? = nil
    @State private var receiptNumber: String = "EAC9999103402"
    @State private var mockErrorScenario: MockErrorScenario = .none

    enum MockErrorScenario: String, CaseIterable, Identifiable {
        case none = "No Error (Success)"
        case unauthorized401 = "401 Unauthorized"
        case notFound404 = "404 Not Found"
        case unprocessableEntity422 = "422 Unprocessable Entity"
        case tooManyRequests429 = "429 Too Many Requests"

        var id: Self { self }
    }

    var body: some View {
        VStack {
            Text("USCIS Case Status - Mock Tests")
                .font(.title2)
                .padding()

            Picker("Mock Error Scenario", selection: $mockErrorScenario) {
                ForEach(MockErrorScenario.allCases) { scenario in
                    Text(scenario.rawValue).tag(scenario)
                }
            }
            .padding(.horizontal)

            TextField("Enter Receipt Number", text: $receiptNumber)
                .padding()
                .border(Color.gray)
                .padding(.horizontal)

            Button("Run Mock Test") {
                apiError = nil
                fetchCaseStatus(accessToken: "mock_token", receiptNumber: receiptNumber) // Mock access token
            }
            .padding()

            if let status = caseStatus {
                CaseStatusDisplayView(status: status) // Reusable view to display case status
            } else if let error = apiError {
                ErrorView(error: error) // Reusable error view
            } else {
                Text("Select a mock error scenario and run test.")
                    .padding()
            }
        }
        .padding()
    }


    func fetchCaseStatus(accessToken: String, receiptNumber: String) { // Access token not actually used in mock mode

        if mockErrorScenario != .none {
            switch mockErrorScenario {
            case .unauthorized401:
                simulateErrorResponse(statusCode: 401, error: .unauthorized)
                return
            case .notFound404:
                simulateErrorResponse(statusCode: 404, error: .notFound)
                return
            case .unprocessableEntity422:
                let errorMessage = "The application receipt number is not formatted correctly."
                simulateErrorResponse(statusCode: 422, error: .unprocessableEntity(message: errorMessage), jsonResponse: ["errors": [["message": errorMessage]]])
                return
            case .tooManyRequests429:
                simulateErrorResponse(statusCode: 429, error: .tooManyRequests)
                return
            case .none:
                // Simulate Success Case for Mock Tests
                simulateSuccessResponse()
                return // Exit to prevent further (real API) calls in this scenario.
            }
        }
        // No real API call in MockTestView, the simulateErrorResponse/simulateSuccessResponse handles everything.
    }


    func simulateErrorResponse(statusCode: Int, error: APIError, jsonResponse: [String: Any]? = nil) {
        DispatchQueue.main.async {
            apiError = error
            caseStatus = nil // Clear any previous status on error
        }
    }

    func simulateSuccessResponse() {
        // Example success response data - customize as needed
        let mockSuccessData = """
        {
          "case_status": {
            "receiptNumber": "EAC9999103403",
            "formType": "I-130",
            "submittedDate": "09-05-2023 14:28:46",
            "modifiedDate": "09-05-2023 14:28:46",
            "current_case_status_text_en": "Case Was Approved (Mock Success)",
            "current_case_status_desc_en": "This is a mock success response for testing purposes.",
            "current_case_status_text_es": "Caso Fue Aprobado (Mock Success)",
            "current_case_status_desc_es": "Esta es una respuesta simulada de éxito para fines de prueba.",
            "hist_case_status": []
          },
          "message": "Mock Success: Case status retrieved successfully."
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            let statusResponse = try decoder.decode(CaseStatus.self, from: mockSuccessData)
            DispatchQueue.main.async {
                caseStatus = statusResponse
                apiError = nil // Clear any errors on success
            }
        } catch {
            DispatchQueue.main.async {
                apiError = .unknownError(statusCode: 200) // Shouldn't happen, but handle just in case
            }
        }
    }
}

// Reusable View for displaying Case Status information
struct CaseStatusDisplayView: View {
    let status: CaseStatus

    var body: some View {
        VStack(alignment: .leading) {
            Text("Case Status: \(status.case_status.current_case_status_text_en)")
                .font(.headline)
            Text("Description: \(status.case_status.current_case_status_desc_en)")
                .font(.body)
            Text("Form Type: \(status.case_status.formType)")
                .font(.caption)
            Text("Receipt Number: \(status.case_status.receiptNumber)")
                .font(.caption)
        }
        .padding()
    }
}

// Reusable View for displaying Errors
struct ErrorView: View {
    let error: APIError

    var body: some View {
        Text("Error: \(error.localizedDescription)")
            .foregroundColor(.red)
            .padding()
    }
}


struct ContentView: View { // Main ContentView to hold TabView
    var body: some View {
        TabView {
            LiveAPIView()
                .tabItem {
                    Label("Live API", systemImage: "cloud.fill")
                }

            MockTestView()
                .tabItem {
                    Label("Mock Tests", systemImage: "hammer.fill")
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
