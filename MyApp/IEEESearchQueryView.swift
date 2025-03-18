//
//  IEEESearchQueryView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct IEEEExploreAPIView: View {
    @State private var apiResponse: String = ""
    @State private var errorMessage: String? = nil
    @State private var apiKey: String = "YOUR_API_KEY_HERE" // ** 보안 경고 **: 실제 API 키를 여기에 직접 코딩하지 마십시오. 더 안전한 방법 (예: 환경 변수, Keychain)을 사용하세요.

    var body: some View {
        VStack {
            TextField("Enter your IEEE API Key", text: $apiKey)
                .padding()
                .border(.gray)

            Button("Fetch Articles") {
                Task {
                    await fetchData()
                }
            }
            .padding()

            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    Text(apiResponse)
                        .padding()
                        .textSelection(.enabled) // 텍스트 선택 가능하게 설정
                }
            }
        }
        .padding()
    }

    func fetchData() async {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            errorMessage = "Please enter your IEEE API Key."
            apiResponse = ""
            return
        }

        errorMessage = nil // Clear previous errors
        apiResponse = "Fetching data..." // 로딩 상태 표시

        guard let baseURL = URL(string: "https://ieeexploreapi.ieee.org/api/v1/search/articles") else {
            errorMessage = "Invalid base URL"
            apiResponse = ""
            return
        }

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!

        // API 키 파라미터 추가
        let apiKeyQueryItem = URLQueryItem(name: "apikey", value: apiKey)
        urlComponents.queryItems?.append(apiKeyQueryItem)

        // 추가적인 파라미터는 필요에 따라 아래에 추가할 수 있습니다.
        // 예시: querytext 파라미터 추가
        // let queryTextQueryItem = URLQueryItem(name: "querytext", value: "artificial intelligence")
        // urlComponents.queryItems?.append(queryTextQueryItem)

        guard let finalURL = urlComponents.url else {
            errorMessage = "Failed to construct final URL"
            apiResponse = ""
            return
        }

        print("Request URL: \(finalURL)") // 요청 URL 로그

        do {
            let (data, response) = try await URLSession.shared.data(from: finalURL)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                errorMessage = "HTTP Error: \(statusCode)"
                apiResponse = ""
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                apiResponse = jsonString
            } else {
                apiResponse = "Failed to decode response as UTF-8 string."
            }

        } catch {
            errorMessage = "Error fetching data: \(error.localizedDescription)"
            apiResponse = ""
        }
    }
}

struct IEEEExploreAPIView_Previews: PreviewProvider {
    static var previews: some View {
        IEEEExploreAPIView()
    }
}
