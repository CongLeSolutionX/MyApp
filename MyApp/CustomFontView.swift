//
//  CustomFontView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI
import UIKit // Needed for UIFont name discovery

// --- Pre-computation Task: Adding Custom Fonts (Manual Steps) ---
//
// IMPORTANT: These steps must be done MANUALLY in Xcode before this code will work as expected
//            with a specific custom font like "Dopest".
//
// 1. Find & Download Font: Obtain the font file (e.g., "Dopest.ttf").
//
// 2. Add to Project:
//    - Drag the .ttf (or .otf) file into your Xcode project navigator.
//    - Ensure the "Add to targets" checkbox for your app target is CHECKED in the dialog that appears.
//
// 3. Verify Target Membership:
//    - Select the font file in the Xcode navigator.
//    - Open the File Inspector (right-hand sidebar).
//    - Under "Target Membership", ensure your app's target is CHECKED. This is crucial!
//    [Image Reference: Like 1*wU7hNZvOE0utH1i7osILlg.png in the article]
//
// 4. Update Info.plist:
//    - Open your project's `Info.plist` file (usually located in the root or Supporting Files).
//    - Add a new key:
//        - For iOS/tvOS/watchOS: "Fonts provided by application" (Raw Key: `UIAppFonts`)
//        - For macOS: "Application fonts resource path" (Raw Key: `ATSApplicationFontsPath`)
//    - Set the Type:
//        - For `UIAppFonts`: `Array`
//        - For `ATSApplicationFontsPath`: `String`
//    - Add the font filename(s) as values:
//        - For `UIAppFonts` (Array): Add a new item (String) for each font file (e.g., "Dopest.ttf").
//        - For `ATSApplicationFontsPath` (String): Enter the folder path relative to Resources (e.g., "." for Resources, or "Fonts/" if in a Fonts subfolder). Less common than UIAppFonts.
//    [Image Reference: Like 1*MwKoAmkJ1aXgZ8bpQze07g.png for UIAppFonts]
//
//    *Plist Path Note:* The article mentions potential issues with subfolder paths in `UIAppFonts`.
//    Usually, just listing the filename ("Dopest.ttf") works even if it's in a group/folder
//    in the navigator, as long as Target Membership is correct. Only use paths like
//    "FolderName/Dopest.ttf" if the simple filename doesn't work.
//
// --- End Pre-computation Task ---

// --- Main SwiftUI View Demonstrating Custom Font Usage ---

struct CustomFontDemoView: View {

    // --- State & Properties ---

    // Example Font Name (Replace with your actual discovered font name)
    // This name MUST match the one found using the discovery code below,
    // NOT necessarily the filename.
    let customFontName = "DopestbyMARSNEV" // As discovered in the article's example

    // Dynamic Padding using @ScaledMetric
    // This padding will scale relative to the .title text style,
    // matching the dynamic font scaling used below.
    @ScaledMetric(relativeTo: .title) var scaledPadding: CGFloat = 16 // Base padding value

    // --- Body ---

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Group {
                    Text("SwiftUI Custom Fonts Demo")
                        .font(.system(.largeTitle).bold())
                        .padding(.bottom)

                    Divider()

                    Text("1. Basic Usage (.custom)")
                        .font(.headline)
                    Text("Hello From CongLeSolutionX!")
                        // Apply the custom font using the DISCOVERED name
                        // This version scales relative to the .body text style by default
                        .font(.custom(customFontName, size: 36))
                        .padding(.bottom)

                    Divider()
                }

                Group {
                    Text("2. Fixed Size (.custom fixedSize)")
                        .font(.headline)
                    Text("Fixed Size Text")
                        // This version uses a fixed size, ignoring Dynamic Type settings
                        .font(.custom(customFontName, fixedSize: 30))
                        .padding(.bottom)

                    Divider()
                }

                Group {
                    Text("3. Dynamic Size Relative To Style")
                        .font(.headline)
                    Text("Dynamic Title Text")
                        // This version scales relative to the .title text style
                        .font(.custom(customFontName, size: 36, relativeTo: .title))
                        .padding(.bottom)

                    Divider()
                }

                Group {
                    Text("4. Dynamic Padding (@ScaledMetric)")
                        .font(.headline)

                    Text("Dynamic Text + Dynamic Padding")
                        .font(.custom(customFontName, size: 30, relativeTo: .title))
                        // Apply the scaled padding value
                        .padding(scaledPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .padding(.bottom)

                    Divider()
                }

                Group {
                    troubleshootingSection
                }
            }
            .padding() // Add padding around the VStack content
        }
        .onAppear(perform: discoverFontNames) // Run font discovery when the view appears
    }

    // --- Font Discovery Logic ---

    func discoverFontNames() {
        print("--- Discovering Available Font Families and Names ---")
        var foundCustomFont = false
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) \tFont names: \(names)")
            if names.contains(customFontName) {
                foundCustomFont = true
            }
        }
        print("---------------------------------------------------")
        if foundCustomFont {
            print("✅ Successfully found '\(customFontName)' registered.")
        } else {
            print("⚠️ WARNING: '\(customFontName)' was NOT found among registered fonts.")
            print("   >> Check Manual Steps (Target Membership & Info.plist) and spelling.")
        }
        print("---------------------------------------------------")
    }

    // --- Troubleshooting Information View ---

    var troubleshootingSection: some View {
        Group {
            Text("Troubleshooting Guide")
                .font(.title2.bold())
                .padding(.top)

            Text("If your custom font isn't displaying, check these common issues:")
                .font(.subheadline)
                .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("**Target Membership:** Ensure the font file (.ttf/.otf) has its target membership checked for your app in the File Inspector.")
                }
                HStack(alignment: .top) {
                    Image(systemName: "list.bullet.rectangle.fill").foregroundColor(.orange)
                    Text("**Info.plist Key:** Verify the correct key is used (`UIAppFonts` for iOS/tvOS/watchOS, `ATSApplicationFontsPath` for macOS).")
                }
                HStack(alignment: .top) {
                    Image(systemName: "doc.text.fill").foregroundColor(.orange)
                    Text("**Info.plist Value:** Double-check the font *filename* (e.g., \"Dopest.ttf\") is correctly listed in the `UIAppFonts` array. Avoid folder paths unless necessary.")
                }
                HStack(alignment: .top) {
                    Image(systemName: "textformat.abc.dottedunderline").foregroundColor(.red)
                    Text("**Font Name:** The name used in `.custom(\"ActualFontName\", ...)` MUST match the name discovered via `UIFont.fontNames(forFamilyName:)`, *not* the filename. Run the discovery code (see console output) to find the correct name (e.g., \"\(customFontName)\").")
                }
            }
            .font(.footnote)
        }
    }
}

// --- App Entry Point ---

//@main
//struct CustomFontApp: App {
//    var body: some Scene {
//        WindowGroup {
//            CustomFontDemoView()
//        }
//    }
//}

// --- SwiftUI Previews ---

#Preview {
    CustomFontDemoView()
}

