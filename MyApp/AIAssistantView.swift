//
//  AIAssistantView.swift
//  MyApp
//
//  Created by Cong Le on 3/21/25.
//

import SwiftUI

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

// MARK: - Main Content View

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
                    processInput()
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
    
    // Helper function to format the date for display.
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Intent Processing
    
    // This function simulates the "Intents/Request Handler" logic.
    // It inspects the input and, based on keywords, decides what action to take.
    func processInput() {
        let lowerInput = inputText.lowercased()
        responseMessage = "" // Clear previous response
        
        // Schedule event intent: If the input mentions "schedule" or "meeting".
        if lowerInput.contains("schedule") || lowerInput.contains("meeting") {
            // In a real app, you would use natural language processing (NLP)
            // to extract detailed information. This example uses fixed defaults.
            let title = "Meeting"
            var eventDate = Date()
            if lowerInput.contains("tomorrow") {
                eventDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            }
            // Simple simulation: if time "2" is mentioned, set hour to 14 (2 PM).
            if lowerInput.contains("2") {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: eventDate)
                components.hour = 14
                components.minute = 0
                eventDate = Calendar.current.date(from: components) ?? eventDate
            }
            storage.addEvent(title: title, date: eventDate)
            responseMessage = "Event scheduled: \(title) on \(formattedDate(eventDate))."
            
        // Reminder intent: When the input mentions "reminder" or "set reminder".
        } else if lowerInput.contains("reminder") {
            let task = "Reminder Task"
            // Set default reminder time to one hour later.
            let reminderDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            storage.addReminder(task: task, date: reminderDate)
            responseMessage = "Reminder set: \(task) at \(formattedDate(reminderDate))."
            
        // Email intent: Simulate email sending.
        } else if lowerInput.contains("email") {
            responseMessage = "Email intent recognized. (Email sending simulated in this prototype.)"
            
        // Music intent: Simulate music playback.
        } else if lowerInput.contains("music") || lowerInput.contains("play") {
            responseMessage = "Music intent recognized. (Music playback simulated in this prototype.)"
            
        // Unknown intent: Ask the user for clarification.
        } else {
            responseMessage = "I'm not sure what you mean. Could you please clarify your request?"
        }
        
        // Clear input after processing.
        inputText = ""
    }
}

// MARK: - App Entry Point

@main
struct AIAssistantApps: App {
    var body: some Scene {
        WindowGroup {
            AIAssistantView()
        }
    }
}
