//
//  DataFlowView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
import Combine // Needed for ObservableObject

// MARK: - Data Models -

/// 1. ObservableObject Model (Older Approach)
///    - Used with @StateObject (source of truth), @ObservedObject, @EnvironmentObject.
///    - Requires `ObservableObject` conformance.
///    - Properties that should trigger UI updates need the `@Published` property wrapper.
class DataModel: ObservableObject {
    @Published var counter: Int = 0
    @Published var name: String = "ObservableObject Model"

    func incrementCounter() {
        counter += 1
    }

    func resetCounter() {
        counter = 0
    }
}

/// 2. @Observable Model (Newer Approach - Observation Framework)
///    - Used with @State (can hold reference types), @Environment, @Bindable.
///    - Requires the `@Observable` macro (part of the Observation framework).
///    - Properties are automatically tracked for changes without `@Published`.
@Observable
class SettingsModel {
    var themeColor: Color = .blue
    var fontSize: Double = 14.0
    var isFeatureEnabled: Bool = false

    init(themeColor: Color = .blue, fontSize: Double = 14.0, isFeatureEnabled: Bool = false) {
        self.themeColor = themeColor
        self.fontSize = fontSize
        self.isFeatureEnabled = isFeatureEnabled
    }
}

// MARK: - Custom Environment Key -

/// 3. EnvironmentKey (For defining custom EnvironmentValues)
///    - Defines a key to access a custom value in the `EnvironmentValues`.
///    - Requires a `defaultValue`.
private struct MyCustomEnvKey: EnvironmentKey {
    static let defaultValue: String = "Default Custom Value"
}

/// 4. EnvironmentValues Extension
///    - Provides convenient access to the custom environment value via a key path.
extension EnvironmentValues {
    var myCustomEnvKey: String {
        get { self[MyCustomEnvKey.self] }
        set { self[MyCustomEnvKey.self] = newValue }
    }
}

// MARK: - Views -

/// 5. Root View (Often holds the primary sources of truth)
struct ContentView: View {
    /// @State: Source of truth for *value types* (Structs, Enums, basic types like Int, Bool).
    /// Owned and managed by the view. Private because it's internal state.
    @State private var localValueCounter: Int = 0

    /// @StateObject: Source of truth for *reference types* (Classes conforming to ObservableObject).
    /// Owned and managed by the view. SwiftUI ensures it persists across view updates.
    /// Private because it's owned state.
    @StateObject private var dataModel = DataModel()

    /// @State can also hold reference types, especially useful with the newer @Observable macro.
    /// The view still owns this specific *instance* of the SettingsModel.
    @State private var settings = SettingsModel(themeColor: .orange, fontSize: 16.0)

    var body: some View {
        NavigationView {
            List {
                // --- Section for @State demo ---
                Section("@State (Value Type)") {
                    Text("Local Counter: \(localValueCounter)")
                    Button("Increment Local") {
                        localValueCounter += 1
                    }
                    // Pass a Binding ($) to allow modification in a subview
                    BindingValueView(counter: $localValueCounter)
                }

                // --- Section for @StateObject / @ObservedObject / @EnvironmentObject demo ---
                Section("@StateObject / @ObservedObject / @EnvironmentObject (ObservableObject)") {
                    Text("DataModel Counter (StateObject): \(dataModel.counter)")
                    Text("DataModel Name (StateObject): \(dataModel.name)")
                    Button("Increment DataModel (StateObject)") {
                        dataModel.incrementCounter()
                    }
                    // Pass the object itself (ObservedObject doesn't own it)
                    ObservedObjectView(model: dataModel)
                    // EnvironmentObject reads from the environment (set below)
                    EnvironmentObjectView()
                    // Pass a Binding ($) to a property of the StateObject
                    BindingReferencePropertyView(name: $dataModel.name)
                }

                // --- Section for @State / @Environment / @Bindable with @Observable ---
                Section("@State / @Environment / @Bindable (@Observable Model)") {
                    Text("Settings Font Size (State): \(settings.fontSize, specifier: "%.1f")")
                        .font(.system(size: settings.fontSize))
                    Text("Feature Enabled (State): \(settings.isFeatureEnabled ? "Yes" : "No")")
                        .foregroundStyle(settings.themeColor)

                    // Pass the object itself (Environment reads it)
                    BindableEnvironmentView()

                    // Show reading it via @Environment directly
                    EnvironmentReaderObservableView()
                    
                    Button("Toggle Feature (State)") {
                        settings.isFeatureEnabled.toggle()
                    }
                }

                // --- Section for @Environment (Standard Key) ---
                Section("@Environment (Standard Key)") {
                    EnvironmentReaderStandardView()
                }

                // --- Section for @Environment (Custom Key) ---
                Section("@Environment (Custom Key)") {
                    CustomEnvironmentReaderView()
                }
            }
            .navigationTitle("SwiftUI Data Flow")
            // Set the ObservableObject in the environment for @EnvironmentObject
            .environmentObject(dataModel)
            // Set the @Observable object in the environment for @Environment(SettingsModel.self)
            .environment(settings)
            // Set the custom environment value
            .environment(\.myCustomEnvKey, "Live Custom Value Set!")
        }
    }
}

/// 6. BindingValueView (Demonstrates @Binding with Value Types)
///    - Uses @Binding to create a two-way connection to a @State property in the parent.
///    - Does *not* own the data.
struct BindingValueView: View {
    @Binding var counter: Int

    var body: some View {
        Stepper("Bound Counter: \(counter)", value: $counter)
    }
}

/// 7. BindingReferencePropertyView (Demonstrates @Binding to a property of an ObservableObject)
///    - Uses @Binding to create a two-way connection to a *property* of an object
///      managed by @StateObject (or @ObservedObject/@EnvironmentObject).
///    - Does *not* own the data object or the property's storage directly.
struct BindingReferencePropertyView: View {
    @Binding var name: String

    var body: some View {
        TextField("Bound Name", text: $name)
            .textFieldStyle(.roundedBorder)
    }
}

/// 8. ObservedObjectView (Observes an external ObservableObject)
///    - Uses @ObservedObject to watch an `ObservableObject` passed in from a parent view.
///    - Does *not* own the object. If the parent view redraws and creates a *new* instance
///      of the model, @ObservedObject will pick up the new instance. Suitable when the parent
///      manages the object's lifecycle (e.g., with @StateObject).
struct ObservedObjectView: View {
    @ObservedObject var model: DataModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Observed Counter: \(model.counter)")
            Button("Increment from ObservedObjectView") {
                model.incrementCounter() // Can modify the object
            }
        }
    }
}

/// 9. EnvironmentObjectView (Reads an ObservableObject from the environment)
///    - Uses @EnvironmentObject to read an `ObservableObject` that an ancestor view
///      placed in the environment using `.environmentObject(...)`.
///    - Does *not* own the object. Assumes the object exists in the environment.
struct EnvironmentObjectView: View {
    @EnvironmentObject var model: DataModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Environment Counter: \(model.counter)")
            Button("Reset from EnvironmentObjectView") {
                model.resetCounter() // Can modify the object
            }
        }
    }
}

/// 10. BindableEnvironmentView (Reads @Observable from Environment, uses @Bindable)
///     - Uses @Environment(MyType.self) to read an `@Observable` object from the environment.
///     - Uses @Bindable locally within the body to easily create bindings ($) to the observable's properties.
struct BindableEnvironmentView: View {
    @Environment(SettingsModel.self) var settings // Read the @Observable model

    var body: some View {
        @Bindable var bindableSettings = settings // Create bindable wrapper

        VStack(alignment: .leading) {
            Text("Bindable/Environment Demo")
                .font(.caption)
            ColorPicker("Theme Color (Bindable)", selection: $bindableSettings.themeColor) // Use $ for binding
            HStack {
                Text("Font Size (Bindable): \(bindableSettings.fontSize, specifier: "%.1f")")
                Slider(value: $bindableSettings.fontSize, in: 10...30) // Use $ for binding
            }
            Toggle("Feature Enabled (Bindable)", isOn: $bindableSettings.isFeatureEnabled) // Use $ for binding
                .tint(bindableSettings.themeColor) // Use direct property access for reading
        }
        .padding(.vertical, 5)
    }
}

/// 11. EnvironmentReaderObservableView (Directly reads @Observable from Environment)
struct EnvironmentReaderObservableView: View {
     @Environment(SettingsModel.self) var settings

     var body: some View {
         Text("Feature Enabled (Direct Read): \(settings.isFeatureEnabled ? "Yes" : "No")")
             .foregroundStyle(settings.themeColor)
             .font(.system(size: settings.fontSize))
     }
}


/// 12. EnvironmentReaderStandardView (Reads a standard EnvironmentValue)
///     - Uses @Environment to read built-in values like color scheme, locale, etc.
///     - Updates automatically when the environment value changes.
struct EnvironmentReaderStandardView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text("Current Color Scheme: \(colorScheme == .dark ? "Dark" : "Light")")
    }
}

/// 13. CustomEnvironmentReaderView (Reads a custom EnvironmentValue)
///     - Uses @Environment with the custom key path defined earlier.
///     - Reads the value set by an ancestor using `.environment(\.myCustomEnvKey, ...)`.
struct CustomEnvironmentReaderView: View {
    @Environment(\.myCustomEnvKey) var customValue

    var body: some View {
        Text("Custom Env Value: \(customValue)")
    }
}

#Preview {
    ContentView()
}
