//
//  USCISCaseStatusView.swift
//  MyApp
//
//  Created by Cong Le on 2/9/25.
//
import SwiftUI

// Define an enum for API errors to handle different error cases specifically
enum APIError: LocalizedError {
    case unauthorized
    case notFound
    case unprocessableEntity(message: String) // 422 might have a specific message
    case tooManyRequests
    case unknownError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized: Your access token may be incorrect or expired, or your keys are not enabled for sandbox."
        case .notFound:
            return "Not Found: Please check if the Receipt Number is valid and ensure you are using a staging receipt number for the sandbox environment."
        case .unprocessableEntity(let message):
            return "Unprocessable Entity: \(message). Please ensure the Receipt Number format is correct (13 characters, 3-character prefix followed by 10 digits)."
        case .tooManyRequests:
            return "Too Many Requests: You have exceeded the TPS or daily quota limit for the sandbox. Please reduce your request rate."
        case .unknownError(let statusCode):
            return "Unknown Error: An unexpected error occurred with status code \(statusCode)."
        }
    }
}


struct USCISCaseStatusView: View {
    @State private var caseStatus: CaseStatus? = nil
    @State private var accessToken: String? = nil
    @State private var apiError: APIError? = nil // Use APIError enum to store error type
    @State private var receiptNumber: String = "EAC9999103402" // Default receipt number for testing

    let clientID = "YOUR_CLIENT_ID" // Replace with your actual Client ID
    let clientSecret = "YOUR_CLIENT_SECRET" // Replace with your actual Client Secret
   
    var body: some View {
        VStack {
            Text("USCIS Case Status Checker")
                .font(.largeTitle)
                .padding()

            TextField("Enter Receipt Number", text: $receiptNumber)
                .padding()
                .border(Color.gray)
                .padding(.horizontal)

            Button("Get Case Status") {
                apiError = nil // Clear any previous errors
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
                Text("Error: \(error.localizedDescription)") // Display error from enum
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
            apiError = .unknownError(statusCode: 0) // URL creation error
            return
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: 0) // Network level error
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: 0) // Bad Response
                }
                return
            }

            // Handle HTTP status codes to map to specific APIError cases
            switch httpResponse.statusCode {
            case 200: // Success
                do {
                    let decoder = JSONDecoder()
                    let statusResponse = try decoder.decode(CaseStatus.self, from: data)
                    DispatchQueue.main.async {
                        caseStatus = statusResponse
                        apiError = nil // Clear error on success
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiError = .unknownError(statusCode: httpResponse.statusCode) // Decoding error
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
                    // Try to decode error message for 422 (Unprocessable Entity) if the API provides structured error response
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorsArray = jsonResponse["errors"] as? [[String: Any]],
                       let firstError = errorsArray.first,
                       let message = firstError["message"] as? String {
                        DispatchQueue.main.async {
                            apiError = .unprocessableEntity(message: message) // Use parsed message
                        }
                    } else {
                        DispatchQueue.main.async {
                            apiError = .unprocessableEntity(message: "Invalid Receipt Number Format") // Default 422 message if parsing fails
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        apiError = .unprocessableEntity(message: "Invalid Receipt Number Format") // Default 422 message on parsing error
                    }
                }
            case 429:
                DispatchQueue.main.async {
                    apiError = .tooManyRequests
                }
            default:
                DispatchQueue.main.async {
                    apiError = .unknownError(statusCode: httpResponse.statusCode) // Generic unknown error
                }
            }
        }.resume()
    }
}


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
    let hist_case_status: String? // or [HistCaseStatus]? if it can be an array
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        USCISCaseStatusView()
    }
}
