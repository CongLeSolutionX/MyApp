//
//  PresentationSizingUnification.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI

// Define the content view that will be presented in the sheet
struct SheetContentView: View {
    let title: String
    let description: String
    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet

    var body: some View {
        NavigationView { // Embed in NavigationView for title bar and potential nav links
            VStack(alignment: .leading, spacing: 20) {
                Text(description)
                    .padding(.horizontal)

                // Example Content
                List {
                    ForEach(1..<6) { index in
                        Label("List Item \(index)", systemImage: "\(index).circle")
                    }
                }

                Spacer() // Pushes content up

                Button("Done") {
                    dismiss() // Dismiss the sheet when tapped
                }
                .frame(maxWidth: .infinity) // Make button wider
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Define the main view that presents the sheets with different sizing
struct PresentationSizingDemoView: View {

    // State variables to control the presentation of each sheet type
    @State private var showFormSizedSheet = false
    @State private var showPageSizedSheet = false
    @State private var showFractionSizedSheet = false
    @State private var showFixedSizedSheet = false
    @State private var showFittedSizedSheet = false

    var body: some View {
        NavigationView {
            List {
                Section("Standard Sizes") {
                    // Button to show a sheet with .form sizing
                    Button("Show '.form' Sized Sheet") {
                        showFormSizedSheet = true
                    }
                    .sheet(isPresented: $showFormSizedSheet) {
                        SheetContentView(
                            title: ".form Sizing",
                            description: "This sheet uses `.presentationSizing(.form)`, ideal for forms or focused tasks."
                        )
                        .presentationSizing(.form) // Apply .form sizing
                    }

                    // Button to show a sheet with .page sizing
                    Button("Show '.page' Sized Sheet") {
                        showPageSizedSheet = true
                    }
                    .sheet(isPresented: $showPageSizedSheet) {
                        SheetContentView(
                            title: ".page Sizing",
                            description: "This sheet uses `.presentationSizing(.page)`, which typically takes more screen space, suitable for rich content."
                        )
                        .presentationSizing(.page) // Apply .page sizing
                    }
                }

//                Section("Custom Sizes") {
                    // Button to show a sheet with .fraction sizing
                    Button("Show '.fraction(0.75)' Sized Sheet") {
                        showFractionSizedSheet = true
                    }
                    .sheet(isPresented: $showFractionSizedSheet) {
                        SheetContentView(
                            title: ".fraction Sizing",
                            description: "This sheet uses `.presentationSizing(.fraction(0.75))`, taking up 75% of the available height."
                        )
//                        .presentationSizing(.fraction(0.75)) // Apply .fraction sizing
//                    }

                    // Button to show a sheet with .fixed sizing
                    Button("Show '.fixed(w: 320, h: 400)' Sized Sheet") {
                        showFixedSizedSheet = true
                    }
                    .sheet(isPresented: $showFixedSizedSheet) {
                        SheetContentView(
                            title: ".fixed Sizing",
                            description: "This sheet uses `.presentationSizing(.fixed(width: 320, height: 400))`, specifying exact dimensions."
                        )
//                        .presentationSizing(.fixed(width: 320, height: 400)) // Apply .fixed sizing
                    }

                    // Button to show a sheet with .fitted sizing
                    Button("Show '.fitted' Sized Sheet") {
                        showFittedSizedSheet = true
                    }
                    .sheet(isPresented: $showFittedSizedSheet) {
                        // Use a simpler content view for .fitted to better demonstrate
                        VStack {
                           Text("Fitted Content")
                                .font(.headline)
                                .padding()
                           Text("This sheet uses `.presentationSizing(.fitted)`. The sheet size adapts precisely to the content size.")
                                .padding([.horizontal, .bottom])
                           Button("OK") { showFittedSizedSheet = false }
                                .buttonStyle(.bordered)
                                .padding(.bottom)
                        }
                        .presentationSizing(.fitted) // Apply .fitted sizing
                    }
                }
            }
            .navigationTitle("Sheet Presentation Sizing")
        }
    }
}

// Preview Provider
struct PresentationSizingDemoView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationSizingDemoView()
    }
}
