//
//  USCISCaseStatusView.swift
//  MyApp
//
//  Created by Cong Le on 2/9/25.
//

import SwiftUI

struct USCISCaseStatusView: View {
    @State private var caseStatus: CaseStatus? = nil
    @State private var accessToken: String? = nil
    @State private var errorMessage: String? = nil
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
                errorMessage = nil // Clear any previous errors
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
            } else if let error = errorMessage {
                Text("Error: \(error)")
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
                errorMessage = "Failed to get access token: \(error.localizedDescription)"
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

            guard let data = data else {
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
            errorMessage = "Invalid API URL"
            return
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "API Request Failed: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received from API"
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let statusResponse = try decoder.decode(CaseStatus.self, from: data)
                DispatchQueue.main.async {
                    caseStatus = statusResponse
                    errorMessage = nil // Clear error on success
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error decoding API response: \(error.localizedDescription)"
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
