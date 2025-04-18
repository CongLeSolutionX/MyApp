////
////  ChatView_V9.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//
//// MARK: - IMPORTANT: API Key Security
//let placeholderOpenAIKey = "YOUR_OPENAI_API_KEY" // <-- NEVER Hardcode in production! Use secure storage.
//
//// MARK: - Data Models (Enhanced Message)
//
//// Enum to represent different types of content in a message bubble
//enum MessageContentType: Equatable {
//    case text(String)
//    case imagePlaceholder(prompt: String) // Represents the request/loading state
//    case generatedImage(url: URL, prompt: String)
//    case error(String)
//}
//
//struct Message: Identifiable {
//    let id = UUID()
//    var contentType: MessageContentType // Use enum for content
//    let isUser: Bool
//    let timestamp: Date = Date()
//    var sourceModel: AIModel? = nil // Optional: Keep for text model source tracking
//
//    // Enum to differentiate AI Text models (keep from previous example if needed)
//    enum AIModel: String, CaseIterable {
//        case localCoreML = "CoreML (Local)"
//        case chatGPT_3_5 = "ChatGPT 3.5"
//        case chatGPT_4 = "ChatGPT 4 (Advanced)"
//
//        var systemImageName: String {
//            switch self {
//            case .localCoreML: return "cpu"
//            case .chatGPT_3_5: return "cloud"
//            case .chatGPT_4: return "sparkles"
//            }
//        }
//    }
//}
//
//// MARK: - OpenAI API Data Structures
//
//struct ImageGenerationRequest: Codable {
//    var model: String = "dall-e-3" // Or dall-e-2
//    let prompt: String
//    var n: Int = 1 // Generate 1 image
//    var size: String = "1024x1024" // DALL-E 3 supports 1024x1024, 1792x1024, or 1024x1792
//    var response_format: String = "url" // Get URL back
//    // Add quality or style if needed:
//    var quality: String = "standard" // "standard" or "hd"
//    var style: String = "vivid" // "vivid" or "natural"
//}
//
//struct ImageGenerationResponse: Codable {
//    let created: Int
//    let data: [ImageData]
//}
//
//struct ImageData: Codable {
//    let url: URL // Make sure it decodes directly to URL
//    // If using b64_json, the field would be:
//     let b64_json: String
//     let revised_prompt: String? // DALL-E 3 might revise the prompt
//}
//
//// Basic OpenAI Error Structure (adjust based on actual API errors)
//struct OpenAIErrorResponse: Codable, Error {
//    let error: OpenAIErrorDetail
//}
//
//struct OpenAIErrorDetail: Codable {
//    let message: String
//    let type: String?
//    let param: String?
//    let code: String?
//}
//
//// MARK: - OpenAI Service
//
//class OpenAIService {
//    
//    private let apiKey: String
//    private let session: URLSession
//    
//    init(apiKey: String) {
//        self.apiKey = apiKey
//        self.session = URLSession(configuration: .default)
//    }
//    
//    func generateImage(prompt: String) async -> Result<URL, Error> {
//        
//        // --- Security Check ---
//        guard apiKey != "YOUR_OPENAI_API_KEY" && !apiKey.isEmpty else {
//            print("ERROR: API Key not set. Please replace placeholder.")
//            return .failure(NSError(domain: "ConfigurationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API Key is not configured."]))
//        }
//        // --- End Security Check ---
//        
//        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
//            return .failure(NSError(domain: "URLCreationError", code: 0, userInfo: nil))
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let requestBody = ImageGenerationRequest(prompt: prompt)
//        
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//        } catch {
//            return .failure(error)
//        }
//        
//        do {
//            let (data, response) = try await session.data(for: request)
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                return .failure(NSError(domain: "NetworkError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."]))
//            }
//            
//            // Check for HTTP errors first
//            guard (200...299).contains(httpResponse.statusCode) else {
//                // Try to decode OpenAI specific error
//                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
//                    return .failure(errorResponse)
//                } else {
//                    // Generic HTTP error
//                    let description = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
//                    return .failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(description)"]))
//                }
//            }
//            
//            // Decode successful response
//            let decoder = JSONDecoder()
//            let generationResponse = try decoder.decode(ImageGenerationResponse.self, from: data)
//            
//            guard let imageUrl = generationResponse.data.first?.url else {
//                return .failure(NSError(domain: "DataError", code: -3, userInfo: [NSLocalizedDescriptionKey: "No image URL found in response."]))
//            }
//            
//            return .success(imageUrl)
//            
//        } catch {
//            return .failure(error) // Covers network errors, decoding errors etc.
//        }
//    }
//}
//
//// MARK: - Enhanced Chat View with Image Generation
//
//struct ChatView: View { // Renamed from EnhancedChatView for consistency with request
//    @State private var messages: [Message] = [
//        Message(contentType: .text("Hello! Use /imagine <prompt> to generate an image."), isUser: false, sourceModel: .chatGPT_3_5),
//    ]
//    @State private var newMessageText: String = ""
//    @State private var isGeneratingImage: Bool = false // Specific loading state for images
//    @State private var imageGenerationError: String? = nil
//    
//    // Initialize the service - **Handle API Key securely!**
//    private let openAIService = OpenAIService(apiKey: placeholderOpenAIKey) // Replace placeholder!
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Divider() // Top Separator
//            
//            // --- Message Display Area ---
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach($messages) { $message in // Use Binding ForEach for potential updates
//                            MessageBubble(message: $message) // Pass binding
//                                .id(message.id)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                }
//                // Scroll logic sensitive to message count
//                .onChange(of: messages.count) {
//                    scrollToBottom(proxy: scrollViewProxy)
//                }
//            }
//            
//            // --- Error Display Area (for Image Errors) ---
//            if let error = imageGenerationError {
//                ErrorDisplayView(errorMessage: error) {
//                    imageGenerationError = nil // Action to dismiss error
//                }
//                .transition(.move(edge: .bottom).combined(with: .opacity)) // Add transition
//            }
//            
//            // --- Input Area ---
//            HStack {
//                TextField("Type message or /imagine <prompt>...", text: $newMessageText, axis: .vertical)
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color(white: 0.15))
//                    .cornerRadius(18)
//                    .lineLimit(1...5)
//                    .disabled(isGeneratingImage) // Disable input while generating image
//                
//                Button {
//                    processUserInput()
//                } label: {
//                    if isGeneratingImage {
//                        ProgressView() // Show spinner while generating
//                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
//                            .frame(width: 30, height: 30)
//                    } else {
//                        Image(systemName: "arrow.up.circle.fill")
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(newMessageText.isEmpty ? .gray : .yellow)
//                    }
//                }
//                .disabled(newMessageText.isEmpty || isGeneratingImage)
//            }
//            .padding()
//            .background(Color(white: 0.1)) // Input area background
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .navigationTitle("AI Chat & Image") // Updated title
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    // --- Helper Functions ---
//    
//    func scrollToBottom(proxy: ScrollViewProxy) {
//        guard let lastId = messages.last?.id else { return }
//        withAnimation {
//            proxy.scrollTo(lastId, anchor: .bottom)
//        }
//    }
//    
//    func processUserInput() {
//        let trimmedInput = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedInput.isEmpty else { return }
//        
//        imageGenerationError = nil // Clear previous errors
//        
//        // 1. Check for Image Generation Command
//        if trimmedInput.lowercased().starts(with: "/imagine ") {
//            let prompt = String(trimmedInput.dropFirst("/imagine ".count)).trimmingCharacters(in: .whitespaces)
//            guard !prompt.isEmpty else {
//                imageGenerationError = "Please provide a prompt after /imagine."
//                return
//            }
//            
//            // Add user's command message (as text)
//            addUserMessage(text: trimmedInput)
//            
//            // Initiate image generation
//            triggerImageGeneration(prompt: prompt)
//            
//        } else {
//            // 2. Handle as a regular text message
//            addUserMessage(text: trimmedInput)
//            // TODO: Add logic to send text to a text generation AI if needed
//            addBotMessage(contentType: .text("Simulated text response to: '\(trimmedInput)'"))
//        }
//        
//        newMessageText = "" // Clear input field
//    }
//    
//    func addUserMessage(text: String) {
//        let userMessage = Message(contentType: .text(text), isUser: true)
//        messages.append(userMessage)
//    }
//    
//    func addBotMessage(contentType: MessageContentType, idToReplace: UUID? = nil) {
//        let botMessage = Message(contentType: contentType, isUser: false)
//        
//        if let id = idToReplace, let index = messages.firstIndex(where: { $0.id == id }) {
//            // Replace the placeholder message
//            messages[index] = botMessage
//        } else {
//            // Append a new message
//            messages.append(botMessage)
//        }
//    }
//    
//    func triggerImageGeneration(prompt: String) {
//        // 1. Add placeholder message
//        let placeholderId = UUID()
//        let placeholderMessage = Message(contentType: .imagePlaceholder(prompt: prompt), isUser: false) // Custom init with ID needed or handle replacement differently
//        messages.append(placeholderMessage) // Temporary append, will replace later
//        
//        // 2. Set loading state
//        isGeneratingImage = true
//        
//        // 3. Start async task for API call
//        Task {
//            let result = await openAIService.generateImage(prompt: prompt)
//            
//            // 4. Update UI on main thread
//            await MainActor.run {
//                isGeneratingImage = false
//                imageGenerationError = nil // Assume success initially
//                
//                // Find the index of the placeholder to update it
//                guard let placeholderIndex = messages.firstIndex(where: {
//                    if case .imagePlaceholder(let p) = $0.contentType, p == prompt, !$0.isUser { return true } // Match based on prompt & type
//                    return false
//                }) else {
//                    print("Error: Could not find placeholder message to update.")
//                    // Optionally add a new error message if placeholder vanished
//                    imageGenerationError = "Internal error: Could not update image placeholder."
//                    return
//                 }
//                
//                let messageIdToUpdate = messages[placeholderIndex].id
//
//                switch result {
//                case .success(let imageUrl):
//                    // Create the final image message
//                    let imageMessage = Message(contentType: .generatedImage(url: imageUrl, prompt: prompt), isUser: false)
//                     messages[placeholderIndex] = imageMessage // Replace placeholder
//                    
//                case .failure(let error):
//                    var errorMessage = "Failed to generate image."
//                    if let openAIError = error as? OpenAIErrorResponse {
//                        errorMessage += " Reason: \(openAIError.error.message)"
//                     } else if let nsError = error as NSError?, nsError.domain == "ConfigurationError" {
//                         errorMessage = nsError.localizedDescription // Show config error directly
//                    } else {
//                        errorMessage += " Error: \(error.localizedDescription)"
//                    }
//                    
//                    // Update placeholder to show error state (or replace with separate error message)
//                    let errorMessageContent = Message(contentType: .error(errorMessage + "\nPrompt: \(prompt)"), isUser: false)
//                    messages[placeholderIndex] = errorMessageContent
//                    
//                    // Also optionally show error in the dedicated error area
//                     imageGenerationError = errorMessage
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Helper UI Components
//
//// Enhanced Message Bubble to handle images and placeholders
//struct MessageBubble: View {
//    @Binding var message: Message // Use binding to allow potential future updates
//    
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if message.isUser { Spacer() }
//            
//           VStack(alignment: message.isUser ? .trailing : .leading) {
//                // Conditionally render content based on contentType
//                switch message.contentType {
//                case .text(let text):
//                    Text(text)
//                        .padding(12)
//                        .background(message.isUser ? Color.yellow.opacity(0.9) : Color(white: 0.25))
//                        .foregroundColor(message.isUser ? .black : .white)
//                        .cornerRadius(15)
//                    
//                case .imagePlaceholder(let prompt):
//                    ImagePlaceholderView(prompt: prompt)
//                    
//                case .generatedImage(let url, let prompt):
//                    GeneratedImageView(url: url, prompt: prompt)
//                    
//                case .error(let errorText):
//                   ErrorBubbleView(errorText: errorText)
//                }
//                
//               // Optional: Display timestamp below bubble
//                Text(message.timestamp, style: .time)
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//                    .padding(.top, 2)
//                
//           }
//           .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading) // Limit bubble width
//
//            if !message.isUser { Spacer() }
//        }
//    }
//}
//
//// View for Image Placeholder state
//struct ImagePlaceholderView: View {
//    let prompt: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            HStack {
//                ProgressView() // Use spinner for loading
//                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                Text("Generating image...")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            Text("\"\(prompt)\"") // Show the prompt being generated
//                .font(.caption2)
//                .italic()
//                .foregroundColor(.gray.opacity(0.8))
//        }
//        .padding(12)
//        .background(Color(white: 0.2)) // Distinct background for placeholder
//        .cornerRadius(15)
//        .overlay(
//            RoundedRectangle(cornerRadius: 15)
//                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [4])) // Dashed border
//        )
//    }
//}
//
//// View for Displaying the Generated Image
//struct GeneratedImageView: View {
//    let url: URL
//    let prompt: String
//    
//    // Calculate approximate aspect ratio for DALL-E 3 sizes
//    private var aspectRatio: CGFloat {
//        // Basic approximation - assumes 1024x1024, 1792x1024, 1024x1792
//        // In a real app, you might get dimensions from API if available or use fixed common ratios
//        // This is a placeholder logic
//        return 1.0 // Default square
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//           // Use AsyncImage to load the image from the URL
//           AsyncImage(url: url) { phase in
//               switch phase {
//               case .empty:
//                   ProgressView() // Show spinner while loading image itself
//                       .progressViewStyle(CircularProgressViewStyle())
//                       .frame(maxWidth: .infinity, minHeight: 150) // Give it some size
//                       .aspectRatio(aspectRatio, contentMode: .fit)
//                       .background(Color.gray.opacity(0.2)) // Background while loading
//                       .cornerRadius(10)
//
//               case .success(let image):
//                   image
//                       .resizable()
//                       .aspectRatio(contentMode: .fit) // Fit the container
//                       .cornerRadius(10) // Rounded corners for the image
//
//               case .failure:
//                   VStack {
//                       Image(systemName: "photo")
//                           .foregroundColor(.gray)
//                       Text("Failed to load image")
//                           .font(.caption)
//                           .foregroundColor(.red)
//                   }
//                   .frame(maxWidth: .infinity, minHeight: 150)
//                   .aspectRatio(aspectRatio, contentMode: .fit)
//                   .background(Color.gray.opacity(0.1))
//                   .cornerRadius(10)
//                   .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
//
//               @unknown default:
//                   EmptyView()
//               }
//           }
//
//            // Display the original prompt below the image
//            Text("\"\(prompt)\"")
//                 .font(.caption)
//                 .foregroundColor(.gray)
//                 .padding(.top, 4)
//         }
//         .padding(12)
//         .background(Color(white: 0.25)) // Standard AI bubble background
//         .cornerRadius(15)
//    }
//}
//
//// Bubble specifically for errors
//struct ErrorBubbleView: View {
//    let errorText: String
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "exclamationmark.octagon.fill")
//                .foregroundColor(.red)
//            Text(errorText)
//                .font(.caption)
//                .foregroundColor(.red.opacity(0.9))
//        }
//        .padding(12)
//        .background(Color.red.opacity(0.15)) // Distinct error background
//        .cornerRadius(15)
//        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.red, lineWidth: 1))
//    }
//}
//
//// Re-use ErrorDisplayView from previous example (if available) or define here
//struct ErrorDisplayView: View {
//    let errorMessage: String
//    let dismissAction: () -> Void
//
//    var body: some View {
//        HStack {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .foregroundColor(.red)
//            Text(errorMessage)
//                .font(.caption)
//                .lineLimit(2)
//                .foregroundColor(.red.opacity(0.8))
//            Spacer()
//            Button {
//                dismissAction()
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(10)
//        .background(Color.red.opacity(0.15))
//        .cornerRadius(8)
//        .padding(.horizontal)
//        .padding(.bottom, 5)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    NavigationView { // Add Navigation View for context
//        ChatView()
//    }
//    .preferredColorScheme(.dark)
//    .tint(.yellow) // Apply tint globally if needed
//}
