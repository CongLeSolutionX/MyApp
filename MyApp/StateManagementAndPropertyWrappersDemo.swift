//
//  StateManagementAndPropertyWrappersDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import Observation // Needed for @Observable

// --- 1. Data Models ---

// Conforms to ObservableObject (for @StateObject, @ObservedObject, @EnvironmentObject)
class DataModelOO: ObservableObject {
    @Published var counter: Int = 0
    @Published var toggleState: Bool = false
    @Published var name: String = "ObservableObject Name"

    func incrementCounter() {
        counter += 1
    }
}

// Conforms to Observable (for @Bindable, @Environment with object type)
@Observable
class DataModelObservable {
    var textFieldValue: String = "Initial Text"
    var sliderValue: Double = 0.5
    var profileName: String = "Observable Profile"
}

// --- 2. Subviews Demonstrating State Reception ---

// Demonstrates receiving state via @Binding
struct BindingSubView: View {
    @Binding var counter: Int // Receives a binding from a @State

    var body: some View {
        HStack {
            Text("Via @Binding: \(counter)")
            Button("Incr Binding") {
                counter += 1 // Modifies the original @State through the binding
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 5)
    }
}

// Demonstrates receiving state via @ObservedObject
// NOTE: @ObservedObject watches an EXISTING ObservableObject instance passed to it.
// It does NOT own the object's lifecycle.
struct ObservedObjectSubView: View {
    @ObservedObject var model: DataModelOO // Receives an existing DataModelOO

    var body: some View {
        VStack(alignment: .leading) {
            Text("Via @ObservedObject:")
            Text("  OO Counter: \(model.counter)")
            Toggle("  OO Toggle", isOn: $model.toggleState) // Binding to @Published property
        }
        .padding(.vertical, 5)
    }
}

// Demonstrates receiving state via @EnvironmentObject
// NOTE: Relies on an ancestor injecting the object via .environmentObject()
struct EnvironmentObjectSubView: View {
    @EnvironmentObject var model: DataModelOO // Reads DataModelOO from the environment

    var body: some View {
        HStack {
            Text("Via @EnvironmentObject: \(model.counter)")
            Button("Incr EnvObj") {
                model.incrementCounter() // Can call methods on the object
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 5)
    }
}

// Demonstrates receiving state via @Bindable (for @Observable objects)
struct BindableSubView: View {
    @Bindable var model: DataModelObservable // Creates bindable access to the Observable model

    var body: some View {
        VStack(alignment: .leading) {
            Text("Via @Bindable:")
            TextField("Observable Text", text: $model.textFieldValue) // Binding via $
                .textFieldStyle(.roundedBorder)
            HStack {
                Text("Slider Value: \(model.sliderValue, specifier: "%.2f")")
                Slider(value: $model.sliderValue) // Binding via $
            }
        }
        .padding(.vertical, 5)
    }
}

// Demonstrates receiving an @Observable object via @Environment
struct EnvironmentObservableSubView: View {
    // Read the Observable object directly from the environment by type
    @Environment(DataModelObservable.self) private var model

    // Optional version if the object might not be in the environment
     @Environment(DataModelObservable.self) private var optModel: DataModelObservable?

    var body: some View {
         // If using the non-optional version:
         Text("Via @Environment(Observable): \(model.profileName)")

         // If using the optional version:
          if let model = optModel {
              Text("Via @Environment(Observable): \(model.profileName)")
          } else {
              Text("Via @Environment(Observable): Not found")
          }
    }
}

// --- 3. Specialized Demos ---

// Demonstrates @Namespace and matchedGeometryEffect
struct NamespaceDemoView: View {
    @Namespace private var animationNamespace
    @Binding var showDetail: Bool // Control visibility from parent

    var body: some View {
        HStack {
            if !showDetail {
                Circle()
                    .fill(.blue)
                    .matchedGeometryEffect(id: "circleShape", in: animationNamespace)
                    .frame(width: 50, height: 50)
                Spacer() // Push circle left
            } else {
              Spacer() // Push shape right when detail shown elsewhere
            }
        }
        .frame(maxWidth: .infinity) // Take full width
        // The corresponding item would be shown elsewhere using the same namespace/id
    }
}

// Demonstrates @ScaledMetric
struct ScaledMetricDemoView: View {
    // Scales the base value (50) relative to the .body text style's scaling
    @ScaledMetric private var imageSize: CGFloat = 50

    // Scales based on a specific style
    // @ScaledMetric(relativeTo: .largeTitle) private var titleScaledSize: CGFloat = 30

    var body: some View {
        VStack {
            Text("ScaledMetric Image Size: \(Int(imageSize))")
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.orange)
        }
    }
}

// --- 4. ContentView (Orchestrator) ---

struct StateManagementAndPropertyWrappersDemo_ContentView: View {
    // @State: Source of truth for simple value types, owned by the view
    @State private var localCounter: Int = 0
    @State private var isPlaying: Bool = false // Example state for binding demo

    // @StateObject: Source of truth for ObservableObject reference types, owned by the view
    @StateObject private var ooModel = DataModelOO()

    // @State can also store Observable types. Use @Bindable for bindings.
    @State private var observableModel = DataModelObservable()

    // @Namespace: For matched geometry effect animations
    @Namespace private var animationNamespace
    @State private var showShapeDetail: Bool = false // Toggles the namespace demo

    // @Environment: Reading environment values
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        NavigationStack {
            List {
                // --- @State Demonstration ---
                Section("@State") {
                    Text("Local Counter (@State): \(localCounter)")
                    Stepper("Increment Local", value: $localCounter) // Needs binding ($)
                    BindingSubView(counter: $localCounter) // Pass binding ($) to subview
                }

                // --- @StateObject/@ObservedObject Demonstration ---
                Section("@StateObject / @ObservedObject") {
                    Text("OO Counter (@StateObject): \(ooModel.counter)")
                    Button("Increment StateObject") {
                        ooModel.incrementCounter() // Modify directly
                    }
                    .buttonStyle(.bordered)
                    ObservedObjectSubView(model: ooModel) // Pass the object instance
                }

                // --- @EnvironmentObject Demonstration ---
                Section("@EnvironmentObject") {
                    // Need to inject ooModel into the environment for this subview
                    EnvironmentObjectSubView()
                        .environmentObject(ooModel) // Injected here
                }

                 // --- @Observable / @Bindable Demonstration ---
                 Section("@Observable / @Bindable") {
                     Text("Observable Name (@State): \(observableModel.profileName)")
                     BindableSubView(model: observableModel) // Pass the Observable object
                 }

                 // --- @Environment with @Observable ---
                 Section("@Environment (reading @Observable)") {
                      // Need to inject observableModel into environment
                      EnvironmentObservableSubView()
                          .environment(observableModel) // Injected here
                 }

                // --- @Environment (reading system values) ---
                Section("@Environment (System Values)") {
                     Text("Current Color Scheme: \(colorScheme == .dark ? "Dark" : "Light")")
                     Text("Dynamic Type Size: \(dynamicTypeSize.description)") // Needs description
                }

                // --- @Namespace Demonstration ---
                Section("@Namespace / matchedGeometryEffect") {
                     NamespaceDemoView(showDetail: $showShapeDetail)

                     if showShapeDetail {
                         Circle()
                             .fill(.blue)
                             .matchedGeometryEffect(id: "circleShape", in: animationNamespace)
                             .frame(width: 150, height: 150)
                             .frame(maxWidth: .infinity, alignment: .center) // Center it
                     }

                     Button(showShapeDetail ? "Hide Detail Shape" : "Show Detail Shape") {
                         withAnimation(.spring()) {
                             showShapeDetail.toggle()
                         }
                     }
                     .buttonStyle(.bordered)
                }

                // --- @ScaledMetric Demonstration ---
                Section("@ScaledMetric") {
                     ScaledMetricDemoView()
                         // Try changing Dynamic Type size in Simulator/Device settings
                }
            }
            .navigationTitle("State Wrappers")
        }
        // Environment modifiers can also be applied here to affect more views,
        // but placed closer to usage above for clarity in this demo.
        // .environmentObject(ooModel)
        // .environment(observableModel)
    }
}

// --- Helper for Environment ---
// Simple description extension for DynamicTypeSize for display purposes
extension DynamicTypeSize: @retroactive CustomStringConvertible {
     public var description: String {
         switch self {
         case .xSmall: return "xSmall"
         case .small: return "Small"
         case .medium: return "Medium"
         case .large: return "Large"
         case .xLarge: return "xLarge"
         case .xxLarge: return "xxLarge"
         case .xxxLarge: return "xxxLarge"
         case .accessibility1: return "accessibility1"
         case .accessibility2: return "accessibility2"
         case .accessibility3: return "accessibility3"
         case .accessibility4: return "accessibility4"
         case .accessibility5: return "accessibility5"
         @unknown default: return "Unknown"
         }
     }
 }

// --- Preview Provider ---
#Preview {
    StateManagementAndPropertyWrappersDemo_ContentView()
}
