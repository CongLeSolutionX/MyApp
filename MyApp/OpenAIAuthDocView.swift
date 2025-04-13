//
//  OpenAIAuthDocView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

// Helper View to display code snippets attractively
struct CodeBlock: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.system(.callout, design: .monospaced)) // Monospaced font for code
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading) // Stretch to full width
            .background(Color(.secondarySystemBackground)) // Subtle background differentiate
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separator), lineWidth: 1) // Subtle border
            )
            .textSelection(.enabled) // Allow users to select and copy code
    }
}

// Main View demonstrating the Authentication concepts
struct OpenAIAuthView: View {

    // State variables to hold optional Organization and Project IDs for the example
    @State private var organizationID: String = ""
    @State private var projectID: String = ""

    // Computed property to dynamically generate the cURL example
    private var curlExample: String {
        var command = """
        curl https://api.openai.com/v1/models \\
          -H "Authorization: Bearer "
        """
        // Append Organization header if ID is provided
        if !organizationID.trimmingCharacters(in: .whitespaces).isEmpty {
            command += " \\\n  -H \"OpenAI-Organization: \(organizationID.trimmingCharacters(in: .whitespaces))\""
        }
        // Append Project header if ID is provided
        if !projectID.trimmingCharacters(in: .whitespaces).isEmpty {
            command += " \\\n  -H \"OpenAI-Project: \(projectID.trimmingCharacters(in: .whitespaces))\""
        }
        return command
    }

    // URLs from the documentation
    private let apiKeySettingsURL = URL(string: "https://platform.openai.com/settings/organization/api-keys")!
    private let orgSettingsURL = URL(string: "https://platform.openai.com/settings/organization/general")!
    private let projectSettingsURL = URL(string: "https://platform.openai.com/settings")! // General settings page for project selection

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {

                    // Section 1: API Key Management and Security Warning
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("API Key Authentication", systemImage: "key.fill")
                                .font(.title2.weight(.semibold))

                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Important Security Reminder")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            Text("Your API key grants access to your account. **Never share it or expose it in client-side code (like this app).** Always load it securely on your server (e.g., from environment variables or a secret management service).")
                                .font(.callout)

                            Text("Manage your API keys in your OpenAI organization settings:")
                            Link(destination: apiKeySettingsURL) {
                                Label("Go to API Key Settings", systemImage: "arrow.up.right.square")
                            }
                            .buttonStyle(.bordered) // Make the link look like a button
                        }
                    }

                    Divider()

                    // Section 2: Basic Authentication Header
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Standard Authentication")
                                .font(.title3.weight(.medium))
                            Text("API requests are authenticated using HTTP Bearer authentication via the `Authorization` header:")
                                .font(.callout)
                            CodeBlock(code: "Authorization: Bearer <YOUR_SECURELY_LOADED_API_KEY>")
                        }
                    }

                    Divider()

                    // Section 3: Multi-Organization / Project Headers (Optional)
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Optional Headers for Specific Organizations/Projects")
                                .font(.title3.weight(.medium))
                            Text("If you belong to multiple organizations or use projects, specify which to use with these headers:")
                                .font(.callout)

                            // Organization ID Input and Link
                            VStack(alignment: .leading) {
                                Text("Organization ID:")
                                TextField("Enter Organization ID (Optional)", text: $organizationID)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                Link("Find Organization ID in Settings", destination: orgSettingsURL)
                                    .font(.caption)
                            }
                            .padding(.bottom, 5)

                            // Project ID Input and Link
                            VStack(alignment: .leading) {
                                Text("Project ID:")
                                TextField("Enter Project ID (Optional)", text: $projectID)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                Link("Find Project ID in Settings", destination: projectSettingsURL)
                                    .font(.caption)
                            }

                            Text("Example Request (cURL):")
                                .padding(.top, 10)

                            // Display the dynamically generated cURL command
                            CodeBlock(code: curlExample)

                            Text("Usage from these requests will be billed to the specified organization and project.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding() // Add padding around the main VStack content
            }
            .navigationTitle("OpenAI API Authentication")
            .navigationBarTitleDisplayMode(.inline) // Keep title neat
        }
    }
}

// SwiftUI Preview Provider
struct OpenAIAuthView_Previews: PreviewProvider {
    static var previews: some View {
        OpenAIAuthView()
    }
}
