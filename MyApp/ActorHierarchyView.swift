//
//  ActorHierarchyView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI

// Main View demonstrating the Actor Hierarchy
struct ActorHierarchyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Actor Hierarchy and Isolation")
                    .font(.largeTitle)
                    .padding(.bottom)

                // --- Isolation Concept ---
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("Core Concept: Isolation")
                        .font(.title2)
                }
                Text("Actors ensure thread safety through isolated access to their state. Isolation is enforced via specific methods and the executor model.")
                    .font(.caption)
                    .padding(.bottom)

                Divider()

                // --- Actor Protocol ---
                ActorProtocolView()

                Divider()

                // --- GlobalActor Protocol ---
                GlobalActorProtocolView()

                Divider()

                // --- MainActor ---
                MainActorView()

                Divider()

                // --- Executor ---
                ExecutorView()

            }
            .padding()
        }
    }
}

// Represents the Actor Protocol
struct ActorProtocolView: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label("Actor Protocol", systemImage: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Base protocol for all actors. Implicitly conforms.")
                    .font(.subheadline)
                    .padding(.bottom, 5)

                Section("Key Properties") {
                    PropertyItemView(name: "unownedExecutor", type: "UnownedSerialExecutor", description: "Non-isolated reference to the actor's executor.", icon: "gearshape.arrow.triangle.2.circlepath")
                }
                .padding(.bottom, 5)

                Section("Isolation Methods") {
                    MethodItemView(name: "preconditionIsolated(...)", description: "Halts execution if not isolated (Debug/Release).", icon: "exclamationmark.triangle.fill")
                    MethodItemView(name: "assertIsolated(...)", description: "Halts execution if not isolated (Debug only).", icon: "exclamationmark.bubble.fill")
                    MethodItemView(name: "assumeIsolated(...)", description: "Verifies isolation and allows synchronous access.", icon: "checkmark.shield.fill")
                }
            }
        } label: {
            Label("Protocol: Actor", systemImage: "person.circle.fill") // Using a generic protocol icon wasn't obvious, using actor icon
        }
    }
}

// Represents the GlobalActor Protocol
struct GlobalActorProtocolView: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label("GlobalActor Protocol", systemImage: "globe.americas.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Inherits from Actor. Defines globally unique actors.")
                    .font(.subheadline)
                    .padding(.bottom, 5)

                Section("Key Properties") {
                    PropertyItemView(name: "shared", type: "ActorType", description: "The single, shared instance of the concrete actor.", icon: "shareplay")
                    PropertyItemView(name: "sharedUnownedExecutor", type: "UnownedSerialExecutor", description: "Executor for the shared instance (delegates to shared.unownedExecutor).", icon: "gearshape.fill")
                }
                .padding(.bottom, 5)

                Section("Static Isolation Methods") {
                     MethodItemView(name: "static preconditionIsolated(...)", description: "Static version of preconditionIsolated.", icon: "exclamationmark.triangle.fill")
                    MethodItemView(name: "static assertIsolated(...)", description: "Static version of assertIsolated.", icon: "exclamationmark.bubble.fill")
                }
            }
        } label: {
            Label("Inherits from Actor", systemImage: "arrow.up.forward.circle")
        }
        HStack {
            Spacer()
            Image(systemName: "arrow.down.app.fill")
                 .foregroundColor(.gray)
            Text("Inherits From Actor")
                 .font(.caption)
                 .foregroundColor(.gray)
            Spacer()
        }
    }
}

// Represents the MainActor
struct MainActorView: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label("MainActor", systemImage: "figure.stand")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Concrete GlobalActor tied to the main dispatch queue.")
                    .font(.subheadline)
                    .padding(.bottom, 5)

                Section("Key Properties & Methods") {
                    PropertyItemView(name: "shared", type: "MainActor", description: "The shared MainActor instance.", icon: "shareplay")
                    PropertyItemView(name: "unownedExecutor", type: "UnownedSerialExecutor", description: "Executor representing the main queue.", icon: "gearshape.fill")
                    MethodItemView(name: "static run(...)", description: "Executes a closure on the main actor.", icon: "play.circle.fill")
                    MethodItemView(name: "static assumeIsolated(...)", description: "Verifies main actor isolation.", icon: "checkmark.shield.fill")
                }
            }
        } label: {
             Label("Concrete Global Actor: MainActor", systemImage: "display") // Icon representing UI/Main Thread
        }
         HStack {
            Spacer()
            Image(systemName: "arrow.down.app.fill")
                 .foregroundColor(.gray)
            Text("Is a GlobalActor")
                 .font(.caption)
                 .foregroundColor(.gray)
            Spacer()
        }
    }
}

// Represents the Executor Concept
struct ExecutorView: View {
     var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                 Label("UnownedSerialExecutor", systemImage: "gearshape.2.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                 Text("A lightweight, non-owning reference to a SerialExecutor. Responsible for scheduling actor tasks.")
                     .font(.subheadline)
                     .padding(.bottom, 5)

                 Text("Actors provide their `unownedExecutor` property, which returns one of these references, ensuring tasks run on the correct execution context.")
                    .font(.caption)
            }
        } label: {
            Label("Executor", systemImage: "wrench.and.screwdriver.fill")
        }
     }
}

// Helper View for Properties
struct PropertyItemView: View {
    let name: String
    let type: String
    let description: String
    let icon: String

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20, alignment: .center)
            VStack(alignment: .leading) {
                Text("\(name): \(type)")
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 2)
    }
}

// Helper View for Methods
struct MethodItemView: View {
    let name: String
    let description: String
    let icon: String

    var body: some View {
         HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20, alignment: .center)
             VStack(alignment: .leading) {
                 Text(name)
                     .font(.headline)
                 Text(description)
                     .font(.caption)
                    .foregroundColor(.secondary)
             }
        }
         .padding(.bottom, 2)
    }
}

// Preview Provider
#Preview {
    ActorHierarchyView()
}
