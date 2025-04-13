////
////  StateManagementDemoView.swift
////  MyApp
////
////  Created by Cong Le on 4/12/25.
////
//
//import SwiftUI
//import Observation // For @Observable
//import Combine    // For ObservableObject
//
//// --- Data Models ---
//
//// Older ObservableObject pattern
//class CounterSettings: ObservableObject {
//    @Published var count: Int = 0
//    @Published var incrementAmount: Int = 1
//}
//
//// Newer @Observable pattern
//@Observable
//class Theme {
//    var primaryColor: Color = .blue
//    var fontSize: CGFloat = 16
//}
//
//// --- Environment Definition ---
//
//private struct ThemeEnvironmentKey: EnvironmentKey {
//    static let defaultValue: Theme = Theme() // Provide a default instance
//}
//
//extension EnvironmentValues {
//    // Computed property to access the Theme in the environment
//    var appTheme: Theme {
//        get { self[ThemeEnvironmentKey.self] }
//        set { self[ThemeEnvironmentKey.self] = newValue }
//    }
//}
//
//// --- View Examples ---
//
//// MARK: @State Example
//struct StateExampleView: View {
//    @State private var isLightOn: Bool = false
//
//    var body: some View {
//        VStack {
//            Image(systemName: isLightOn ? "lightbulb.fill" : "lightbulb")
//                .font(.largeTitle)
//                .foregroundStyle(isLightOn ? .yellow : .gray)
//            Toggle("Light Switch", isOn: $isLightOn) // $ provides Binding
//                .fixedSize() // Prevents Toggle from stretching
//        }
//        .padding()
//        .navigationTitle("@State")
//    }
//}
//
//// MARK: @Binding Example
//struct LightBulbView: View {
//    @Binding var isOn: Bool // Receives state from parent
//
//    var body: some View {
//        Image(systemName: isOn ? "lightbulb.fill" : "lightbulb")
//            .font(.system(size: 80))
//            .foregroundStyle(isOn ? .yellow : .gray)
//            .onTapGesture {
//                isOn.toggle() // Mutates the parent's @State
//            }
//    }
//}
//
//struct BindingParentView: View {
//    @State private var isKitchenLightOn: Bool = true
//
//    var body: some View {
//        VStack {
//            Text("Kitchen Light Status")
//            LightBulbView(isOn: $isKitchenLightOn) // Pass binding with $
//        }
//        .padding()
//        .navigationTitle("@Binding")
//    }
//}
//
//// MARK: @StateObject / @ObservedObject Example
//struct CounterDisplayView: View {
//    @ObservedObject var settings: CounterSettings // Observes external settings
//
//    var body: some View {
//        VStack {
//            Text("Count: \(settings.count)")
//                .font(.title)
//            Stepper("Increment Amount", value: $settings.incrementAmount) // Bind to @Published
//        }
//        .padding()
//        .background(Color.green.opacity(0.1))
//    }
//}
//
//struct StateObjectParentView: View {
//    // Creates and owns the instance. Persists across redraws *of this view*.
//    @StateObject private var counterSettings = CounterSettings()
//
//    var body: some View {
//        VStack {
//            Text("Owned Count: \(counterSettings.count)")
//            Button("Increment by \(counterSettings.incrementAmount)") {
//                counterSettings.count += counterSettings.incrementAmount
//            }
//            .buttonStyle(.borderedProminent)
//
//            CounterDisplayView(settings: counterSettings) // Pass the instance
//        }
//        .padding()
//        .navigationTitle("@StateObject / @ObservedObject")
//    }
//}
//
//// MARK: @EnvironmentObject Example
//struct ScoreDisplayView: View {
//    @EnvironmentObject var settings: CounterSettings // Reads from environment
//
//    var body: some View {
//        HStack {
//            Text("Environment Score: \(settings.count)")
//            Button("+10 from Environment") {
//                settings.count += 10
//            }
//            .buttonStyle(.bordered)
//        }
//        .padding()
//        .background(Color.orange.opacity(0.1))
//    }
//}
//
//struct EnvironmentObjectRootView: View {
//    @StateObject private var globalSettings = CounterSettings()
//
//    var body: some View {
//        VStack {
//            Text("Root Count: \(globalSettings.count)")
//            ScoreDisplayView() // Descendant reads the object
//            ScoreDisplayView() // Another descendant reads the *same* object
//        }
//        .environmentObject(globalSettings) // Inject into environment
//        .padding()
//        .navigationTitle("@EnvironmentObject")
//    }
//}
//
//// MARK: @Environment Example
//struct EnvironmentReaderView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.appTheme) var theme // Read custom environment value
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("System Environment:")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//            Text(" - Color Scheme: \(colorScheme == .dark ? "Dark" : "Light")")
//
//            Divider().padding(.vertical, 5)
//
//            Text("Custom Environment:")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//            Text(" - Font Size: \(theme.fontSize, specifier: "%.0f")")
//            Text(" - Primary Color:")
//                .foregroundStyle(theme.primaryColor) // Use the color
//        }
//        .padding()
//        .background(Color.cyan.opacity(0.1))
//    }
//}
//
//struct EnvironmentProviderView: View {
//     @State private var currentTheme = Theme()
//
//     var body: some View {
//         VStack {
//             EnvironmentReaderView()
//                 .environment(\.appTheme, currentTheme) // Set custom value
//
//             // Controls to change the environment value
//             ColorPicker("Set Primary Color", selection: $currentTheme.primaryColor)
//             Slider(value: $currentTheme.fontSize, in: 12...24) {
//                 Text("Font Size")
//             }
//         }
//         .padding()
//         .navigationTitle("@Environment")
//     }
//}
//
//// MARK: @Bindable (@Observable) Example
//struct ThemeEditorView: View {
//    // Use @Bindable to get bindings to @Observable object properties
//    @Bindable var theme: Theme
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Editing Theme")
//                .font(.headline)
//            // $theme.propertyName creates a binding
//            ColorPicker("Primary Color", selection: $theme.primaryColor)
//            HStack {
//                Text("Font Size: \(theme.fontSize, specifier: "%.0f")")
//                Slider(value: $theme.fontSize, in: 10...30)
//            }
//        }
//        .padding()
//        .background(theme.primaryColor.opacity(0.1))
//        .cornerRadius(10)
//    }
//}
//
//struct BindableParentView: View {
//    // @State can hold @Observable objects. View updates when object changes.
//    @State private var appTheme = Theme()
//
//    var body: some View {
//        VStack {
//            Text("Current Theme Preview")
//                .font(.system(size: appTheme.fontSize))
//                .foregroundStyle(appTheme.primaryColor)
//                .padding(.bottom)
//
//            ThemeEditorView(theme: appTheme) // Pass the @Observable object directly
//        }
//        .padding()
//        .navigationTitle("@Bindable / @Observable")
//    }
//}
//
//// MARK: - Root Demo View
//struct StateManagementDemoView: View {
//     var body: some View {
//         NavigationView {
//             List {
//                 Section("Value Types & Basic Flow") {
//                     NavigationLink("@State", destination: StateExampleView())
//                     NavigationLink("@Binding", destination: BindingParentView())
//                 }
//                 Section("ObservableObject Pattern") {
//                     NavigationLink("@StateObject / @ObservedObject", destination: StateObjectParentView())
//                     NavigationLink("@EnvironmentObject", destination: EnvironmentObjectRootView())
//                 }
//                 Section("@Observable Pattern") {
//                     NavigationLink("@Bindable / @Observable", destination: BindableParentView())
//                 }
//                 Section("Environment Values") {
//                    NavigationLink("@Environment", destination: EnvironmentProviderView())
//                 }
//             }
//             .navigationTitle("State Management")
//         }
//     }
// }
//
//#Preview {
//    StateManagementDemoView()
//}
