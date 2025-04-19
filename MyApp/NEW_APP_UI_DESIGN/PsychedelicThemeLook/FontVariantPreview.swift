//
//  FontVariantPreview.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//



import SwiftUI

// --- SwiftUI Previews for Multiple Font Variants ---

// This preview assumes the following setup based on the screenshot:
// 1. Font files (DopestbyMARSNEV.otf, DopestbyMARSNEVitalic.otf,
//    DopestbyMARSNEVlight.otf, DopestbyMARSNEVlightitalic.otf) are added to the project.
// 2. Target Membership is checked for the app target for ALL these font files.
// 3. The Info.plist contains the "Fonts provided by application" (UIAppFonts) array
//    with string items for each of these .otf filenames.

#Preview("Dopest Font Family Variants") {

    // --- Assumed Font Names (Verify with discovery code if needed!) ---
    // These names are educated guesses based on common font naming conventions
    // and the filenames seen. The actual names might differ slightly (e.g., hyphens).
    let regularName = "Psycha"
    let italicName = "PsychaRegular-Italic" // Common convention adds a hyphen
    let lightName = "PsychaRegular-Light"   // Common convention adds a hyphen
    let lightItalicName = "PsychaRegular-LightItalic" // Common convention

    // --- Preview Layout ---
    ScrollView { // Use ScrollView in case content overflows on smaller devices
        VStack(alignment: .leading, spacing: 20) {
            Text("Font Variant Showcase: Dopest")
                .font(.custom(regularName, size: 28)) // Use the regular font for the title
                .padding(.bottom)

            // --- Regular Variant ---
            VStack(alignment: .leading) {
                Text("Variant: Regular").font(.headline)
                Text("Assumed Name: \(regularName)").font(.caption).foregroundColor(.gray)
                Text("The quick brown fox jumps over the lazy dog. 1234567890")
                    .font(.custom(regularName, size: 20))
            }
            Divider()

            // --- Italic Variant ---
            VStack(alignment: .leading) {
                Text("Variant: Italic").font(.headline)
                 Text("Assumed Name: \(italicName)").font(.caption).foregroundColor(.gray)
                 Text("The quick brown fox jumps over the lazy dog. 1234567890")
                    .font(.custom(italicName, size: 20)) // Use assumed italic name
            }
            Divider()

            // --- Light Variant ---
            VStack(alignment: .leading) {
                Text("Variant: Light").font(.headline)
                 Text("Assumed Name: \(lightName)").font(.caption).foregroundColor(.gray)
                 Text("The quick brown fox jumps over the lazy dog. 1234567890")
                    .font(.custom(lightName, size: 20)) // Use assumed light name
            }
            Divider()

            // --- Light Italic Variant ---
            VStack(alignment: .leading) {
                Text("Variant: Light Italic").font(.headline)
                 Text("Assumed Name: \(lightItalicName)").font(.caption).foregroundColor(.gray)
                 Text("The quick brown fox jumps over the lazy dog. 1234567890")
                    .font(.custom(lightItalicName, size: 20)) // Use assumed light italic name
            }

            Divider().padding(.vertical)

            // --- Important Note ---
             Text("⚠️ Verification Note:")
                 .font(.headline)
                 .foregroundColor(.orange)
             Text("The font names used above (\(italicName), \(lightName), \(lightItalicName)) are *assumptions*. If the fonts don't render correctly, use the `UIFont.fontNames(forFamilyName:)` discovery code at runtime to find the exact registered names and update them here.")
                 .font(.footnote)

        }
        .padding() // Add padding around the main VStack content
    }
}

// --- Placeholder View (If you need a View struct to attach the preview to) ---
// You can attach the #Preview to any relevant View struct in your project.
// If you don't have one readily available for this specific preview,
// you can create a simple placeholder like this:

struct FontVariantPreviewContainer: View {
    var body: some View {
        Text("This view is just a container for the previews.")
    }
}


