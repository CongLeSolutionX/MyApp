//
//  AIAssistantView.swift
//  MyApp
//
//  Created by Cong Le on 3/21/25.
//

import SwiftUI
import Foundation

// MARK: - Data Models

// An Event model to represent a calendar event.
struct Event: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
}

// A Reminder model to represent a simple reminder.
struct Reminder: Codable, Identifiable {
    let id: UUID
    var task: String
    var date: Date
}

// MARK: - Local Storage Manager

// This class handles local storage using UserDefaults.
class LocalStorage: ObservableObject {
    @Published var events: [Event] = []
    @Published var reminders: [Reminder] = []
    
    private let eventsKey = "eventsKey"
    private let remindersKey = "remindersKey"
    
    init() {
        loadData()
    }
    
    func saveData() {
        let encoder = JSONEncoder()
        if let encodedEvents = try? encoder.encode(events) {
            UserDefaults.standard.set(encodedEvents, forKey: eventsKey)
        }
        if let encodedReminders = try? encoder.encode(reminders) {
            UserDefaults.standard.set(encodedReminders, forKey: remindersKey)
        }
    }
    
    func loadData() {
        let decoder = JSONDecoder()
        if let savedEvents = UserDefaults.standard.data(forKey: eventsKey),
           let decodedEvents = try? decoder.decode([Event].self, from: savedEvents) {
            events = decodedEvents
        }
        if let savedReminders = UserDefaults.standard.data(forKey: remindersKey),
           let decodedReminders = try? decoder.decode([Reminder].self, from: savedReminders) {
            reminders = decodedReminders
        }
    }
    
    func addEvent(title: String, date: Date) {
        let newEvent = Event(id: UUID(), title: title, date: date)
        events.append(newEvent)
        saveData()
    }
    
    func addReminder(task: String, date: Date) {
        let newReminder = Reminder(id: UUID(), task: task, date: date)
        reminders.append(newReminder)
        saveData()
    }
}

// MARK: - OpenAI API Models

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatAPIRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

struct ChatChoice: Codable {
    let message: ChatMessage
}

struct ChatAPIResponse: Codable {
    let choices: [ChatChoice]
}

// MARK: - Content View

struct AIAssistantView: View {
    @State private var inputText: String = ""
    @State private var responseMessage: String = ""
    @ObservedObject var storage = LocalStorage()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // User Interface: Displays title and input field (simulating voice/text input).
                Text("AI Assistant")
                    .font(.largeTitle)
                    .padding(.bottom, 8)
                
                Text("Enter your command below:")
                    .font(.headline)
                
                TextField("e.g., Schedule a meeting with John tomorrow at 2pm", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 8)
                
                // Button to trigger the intent handling.
                Button(action: {
                    // Launch async processing for intent handling.
                    Task {
                        await processInputAsync()
                    }
                }, label: {
                    HStack {
                        Spacer()
                        Text("Submit")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                })
                
                Divider()
                
                // App Response: Shows feedback from the assistant.
                Text("Response:")
                    .font(.headline)
                
                Text(responseMessage)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                // Local Data Storage (displaying events and reminders).
                List {
                    Section(header: Text("Events")) {
                        ForEach(storage.events) { event in
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text("Date: \(formattedDate(event.date))")
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    Section(header: Text("Reminders")) {
                        ForEach(storage.reminders) { reminder in
                            VStack(alignment: .leading) {
                                Text(reminder.task)
                                    .font(.headline)
                                Text("Date: \(formattedDate(reminder.date))")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .padding()
            .navigationBarTitle("AI Assistant", displayMode: .inline)
        }
    }
    
    // Helper to format dates
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Intent Processing (Async Version)
    // This function simulates the "Intents/Request Handler" logic.
    // It inspects the input and decides whether to handle locally or call OpenAI.
    func processInputAsync() async {
        let lowerInput = inputText.lowercased()
        
        // Clear previous response on the main actor.
        await MainActor.run {
            responseMessage = ""
        }
        
        if lowerInput.contains("schedule") || lowerInput.contains("meeting") {
            let title = "Meeting"
            var eventDate = Date()
            if lowerInput.contains("tomorrow") {
                eventDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            }
            if lowerInput.contains("2") {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: eventDate)
                components.hour = 14
                components.minute = 0
                eventDate = Calendar.current.date(from: components) ?? eventDate
            }
            storage.addEvent(title: title, date: eventDate)
            await MainActor.run {
                responseMessage = "Event scheduled: \(title) on \(formattedDate(eventDate))."
            }
        } else if lowerInput.contains("reminder") {
            let task = "Reminder Task"
            let reminderDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            storage.addReminder(task: task, date: reminderDate)
            await MainActor.run {
                responseMessage = "Reminder set: \(task) at \(formattedDate(reminderDate))."
            }
        } else if lowerInput.contains("email") {
            await MainActor.run {
                responseMessage = "Email intent recognized. (Email sending simulated in this prototype.)"
            }
        } else if lowerInput.contains("music") || lowerInput.contains("play") {
            await MainActor.run {
                responseMessage = "Music intent recognized. (Music playback simulated in this prototype.)"
            }
        } else {
            // For unknown intents or general queries, call the OpenAI API.
            let aiResponse = await fetchOpenAIResponse(prompt: inputText)
            await MainActor.run {
                responseMessage = aiResponse
            }
        }
        
        // Clear input after processing on the main thread.
        await MainActor.run {
            inputText = ""
        }
    }
    
    // MARK: - OpenAI API Integration
    // This function calls OpenAI's Chat Completion endpoint asynchronously.
    func fetchOpenAIResponse(prompt: String) async -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return "Invalid API URL."
        }
        
        // Construct the messages array with the user prompt.
        let messages = [ChatMessage(role: "user", content: prompt)]
        
        // Create the API request payload.
        let apiRequest = ChatAPIRequest(model: "gpt-3.5-turbo", messages: messages, temperature: 0.7)
        
        // Prepare the URLRequest.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // IMPORTANT: Replace "YOUR_OPENAI_API_KEY" with your actual key.
        request.addValue("Bearer YOUR_OPENAI_API_KEY", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(apiRequest)
        } catch {
            return "Failed to encode API request."
        }
        
        do {
            // Perform the network request.
            let (data, response) = try await URLSession.shared.data(for: request)
            // Optionally, check for HTTP errors.
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                return "OpenAI API error: \(httpResponse.statusCode)"
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(ChatAPIResponse.self, from: data)
            if let reply = apiResponse.choices.first?.message.content {
                return reply.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return "No response from OpenAI."
            }
        } catch {
            return "Error calling OpenAI API: \(error.localizedDescription)"
        }
    }
}

// MARK: - App Entry Point

@main
struct AIAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            AIAssistantView()
        }
    }
}
