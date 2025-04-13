//
//  V1.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import Observation // For @Observable
import Combine // For ObservableObject

// --- Models ---
// Older ObservableObject approach
class Settings: ObservableObject {
    @Published var score: Int = 0
    @Published var username: String = "Guest"
}

// Newer @Observable approach
@Observable
class UserProfile {
    var name: String = "Anonymous"
    var favoriteColor: Color = .blue
}

// --- Environment Key Example ---
private struct CustomFontSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 14
}

extension EnvironmentValues {
    var customFontSize: CGFloat {
        get { self[CustomFontSizeKey.self] }
        set { self[CustomFontSizeKey.self] = newValue }
    }
}

// MARK: - @State Example

struct StateExampleView: View {
    // @State: Source of truth for local, value-type state within a view.
    // Private because it's owned and managed by this view specifically.
    @State private var counter: Int = 0
    @State private var isToggled: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Counter: \(counter)")
                .font(.title)

            Button("Increment") {
                counter += 1 // Direct mutation invalidates the view
            }
            .buttonStyle(.borderedProminent)

            Toggle(isOn: $isToggled) { // Use $ prefix for Binding
                Text("Is Feature Enabled?")
            }
            .padding(.horizontal)

            if isToggled {
                Text("Feature is ON!")
                    .foregroundStyle(.green)
            }
        }
        .navigationTitle("@State Example")
    }
}

// MARK: - @Binding Example

// Subview that receives a binding
struct BindingExampleView: View {
    // @Binding: Receives a mutable reference (Binding) from a parent view.
    // Doesn't own the data, just reads/writes it.
    @Binding var value: Int

    var body: some View {
        VStack {
            Text("Bound Value: \(value)")
            Button("Increase from Child") {
                value += 1 // Modifies the parent's @State
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(8)
    }
}

// Parent view holding the @State and passing the Binding
struct StateAndBindingParentView: View {
    @State private var sharedCounter: Int = 5

    var body: some View {
        VStack(spacing: 20) {
            Text("Parent Counter: \(sharedCounter)")
                .font(.title2)
            BindingExampleView(value: $sharedCounter) // Pass binding with $
        }
        .navigationTitle("@Binding Example")
    }
}

// MARK: - @StateObject / @ObservedObject Example

// Subview receiving the ObservableObject
struct ObservedObjectExampleView: View {
    // @ObservedObject: References an external ObservableObject.
    // Updates when the object's @Published properties change.
    // Doesn't own the object's lifecycle - expects parent to own it.
    @ObservedObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading) {
            Text("Observed Score: \(settings.score)")
            Stepper("Adjust Score", value: $settings.score) // Use $ for binding to @Published var

            Text("Observed Username: \(settings.username)")
            TextField("Username", text: $settings.username)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
    }
}

// Parent view creating and owning the ObservableObject
struct StateObjectParentView: View {
    // @StateObject: Creates and owns an instance of an ObservableObject.
    // Persists across view updates. Source of Truth for reference types.
    @StateObject private var gameSettings = Settings()

    var body: some View {
        VStack(spacing: 20) {
            Text("Parent Score: \(gameSettings.score)")
                .font(.title2)
            Text("Parent Username: \(gameSettings.username)")
                .font(.caption)

            ObservedObjectExampleView(settings: gameSettings) // Pass the object instance directly
        }
        .navigationTitle("@StateObject/@ObservedObject")
    }
}

// MARK: - @EnvironmentObject Example

// Subview reading from the environment
struct EnvironmentObjectExampleView: View {
    // @EnvironmentObject: Reads an ObservableObject injected into the environment.
    // The view *must* have this object type injected by an ancestor.
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading) {
            Text("Env Score: \(settings.score)")
            Button("Increase Env Score") {
                settings.score += 5
            }
            .buttonStyle(.bordered)
            Text("Env Username: \(settings.username)")
        }
        .padding()
        .background(Color.purple.opacity(0.2))
        .cornerRadius(8)
    }
}

// Intermediate/Parent View
struct EnvironmentObjectParentView: View {
    // Often, the @StateObject is higher up the hierarchy
    @StateObject private var userSettings = Settings()

    var body: some View {
        VStack(spacing: 20) {
            Text("Parent Score: \(userSettings.score)")
            // Inject the object into the environment for ChildView and its descendants
            EnvironmentObjectExampleView()
                .environmentObject(userSettings)
        }
         .navigationTitle("@EnvironmentObject")
    }
}

// MARK: - @Environment Example

struct EnvironmentExampleView: View {
    // @Environment: Reads values from the view's environment.
    // Can read system values (like colorScheme) or custom ones.
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.customFontSize) var fontSize // Custom env value

    var body: some View {
        VStack(alignment: .leading) {
            Text("Current Color Scheme: \(colorScheme == .dark ? "Dark" : "Light")")
            Text("This text uses the custom font size.")
                .font(.system(size: fontSize)) // Apply custom size
        }
        .padding()
        .background(Color.cyan.opacity(0.2))
        .cornerRadius(8)
        .navigationTitle("@Environment Example")
    }
}

struct EnvironmentParentView : View {
    @State private var customSize: CGFloat = 18

     var body: some View {
         VStack {
             EnvironmentExampleView()
                 // Set the custom environment value for descendants
                 .environment(\.customFontSize, customSize)

             Slider(value: $customSize, in: 10...30, step: 1) {
                 Text("Adjust Font Size")
             }
             .padding()
         }
     }
}

// MARK: - @Bindable (@Observable) Example

struct ObservableObjectView: View {
    // For @Observable objects passed down, use @Bindable to get bindings.
    @Bindable var profile: UserProfile

    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile Name: \(profile.name)")
            TextField("Edit Name", text: $profile.name) // $ works via dynamic member lookup
                 .textFieldStyle(.roundedBorder)

            ColorPicker("Favorite Color", selection: $profile.favoriteColor)
        }
        .padding()
        .background(profile.favoriteColor.opacity(0.2))
        .cornerRadius(8)
    }
}

struct BindableParentView: View {
    // State can hold @Observable objects too.
    @State private var user = UserProfile()

    var body: some View {
        VStack(spacing: 20) {
             Text("Parent Name: \(user.name)")
                 .font(.title2)
             ObservableObjectView(profile: user) // Pass the object directly
         }
         .navigationTitle("@Bindable / @Observable")
    }
}

// MARK: - Demo Root View

struct StateManagementDemoView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("@State", destination: StateExampleView())
                NavigationLink("@Binding", destination: StateAndBindingParentView())
                NavigationLink("@StateObject / @ObservedObject", destination: StateObjectParentView())
                NavigationLink("@EnvironmentObject", destination: EnvironmentObjectParentView())
                NavigationLink("@Environment", destination: EnvironmentParentView())
                NavigationLink("@Bindable / @Observable", destination: BindableParentView())
            }
            .navigationTitle("State Management")
        }
    }
}

// Preview Provider
struct StateManagementDemoView_Previews: PreviewProvider {
    static var previews: some View {
        StateManagementDemoView()
    }
}
