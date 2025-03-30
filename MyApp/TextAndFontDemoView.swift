//
//  TextAndFontDemoView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// Demonstrates various features of the SwiftUI Text and Font system.
struct TextAndFontDemoView: View {

    // State variables for interactive examples
    @State private var sampleString = "SwiftUI Text"
    @State private var someDate = Date()
    @State private var someNumber: Double = 12345.67
    @State private var isBold = false
    @State private var isItalic = false
    @State private var textScaleOption: Text.Scale = .default
    
    // Formatter example
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
    
    // AttributedString example
    var attributedString: AttributedString {
        var attributedString = AttributedString("Visit our ")
        var link = AttributedString("website")
        link.link = URL(string: "https://www.example.com")
        link.underlineStyle = .single // Example of applying SwiftUI attributes
        attributedString.append(link)
        attributedString.append(AttributedString(" for more info."))
        attributedString.font = .system(.caption)
        return attributedString
    }
    
    // Markdown example
    var markdownString: AttributedString {
        // Note: Markdown parsing happens implicitly when using Text("...") initializer
        // with markdown syntax. This demonstrates manual creation.
        // SwiftUI's Text view directly supports Markdown literals.
        try! AttributedString(markdown: "**Bold** and *italic* text using Markdown.")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // --- Text Initialization ---
                Group {
                    Text("Text Initialization")
                        .font(.title)
                        .padding(.bottom, 5)

                    Text("Simple String: \(sampleString)")
                    
                    // Implicit Localization (Assumes "greeting_key" exists in Localizable.strings)
                    Text("greeting_key", comment: "A greeting to the user")
                    
                    // Verbatim String (No localization)
                    Text(verbatim: "This string is not localized.")
                    
                    // AttributedString
                    Text(attributedString)
                        .tint(.blue) // Affects link color
                        
                    // Markdown String
                    // Text view directly supports Markdown in String literals
                    Text("Direct Markdown: **Bold** and *italic*")
                    Text(markdownString) // Using pre-built AttributedString
                    
                    // Date Formatting
                    Text(someDate, style: .date)
                    Text(someDate, style: .time)
                    Text(someDate, style: .relative)
                    Text(someDate, style: .offset)
                    Text(someDate, style: .timer) // Counts down/up from date

                    // Formatter (Legacy)
                    Text(NSNumber(value: someNumber), formatter: currencyFormatter)
                    
                    // FormatStyle (Modern)
                    Text(someNumber, format: .currency(code: "EUR"))
                    
                    // Image inside Text
                    Text("Logo: \(Image(systemName: "swift"))")
                        .foregroundStyle(.orange)
                    
                    // Text Concatenation
                    Text("Hello")
                        .bold() +
                    Text(" World!")
                        .italic()
                        .foregroundStyle(.blue)
                }
                .padding(.leading)
                
                Divider()

                // --- Font System ---
                Group {
                    Text("Font System")
                        .font(.title)
                        .padding(.bottom, 5)
                    
                    Text("System Font: Large Title")
                        .font(.largeTitle)
                    Text("System Font: Body")
                        .font(.body)
                    Text("System Font: Caption")
                        .font(.caption)
                        
                    Text("System Font: Size 24, Semibold, Rounded")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        
                    Text("Custom Font: Didot 20pt")
                        // Ensure "Didot" font is available in the project/system
                        .font(.custom("Didot", size: 20))
                        
                    Text("Fixed Size Custom Font: Gill Sans 18pt")
                        // Ensure "Gill Sans" font is available in the project/system
                        .font(.custom("Gill Sans", fixedSize: 18))
                        
                    // Font Modifiers
                    Text("Bold Modifier")
                        .font(.headline)
                        .bold()
                    Text("Italic Modifier")
                        .font(.headline)
                        .italic()
                    Text("Weight Modifier: Ultralight")
                        .font(.headline)
                        .fontWeight(.ultraLight) // Or .weight(.ultraLight)
                    Text("Monospaced Font Modifier")
                        .font(.title3.monospaced()) // Apply monospaced design
                    Text("12345 vs 98765 (Monospaced Digits)")
                        .font(.body.monospacedDigit()) // Only digits are monospaced
                    Text("Leading Modifier: Tight")
                        .font(.body.leading(.tight))
                    Text("Leading Modifier: Loose")
                        .font(.body.leading(.loose))
                    // Width modifier (requires variable width font)
                    Text("Width Modifier: Condensed")
                        .font(.system(size: 20).width(.condensed))
                     Text("Width Modifier: Expanded")
                        .font(.system(size: 20).width(.expanded))
                }
                .padding(.leading)
                
                Divider()

                // --- Text Modifiers ---
                Group {
                    Text("Text Modifiers")
                        .font(.title)
                        .padding(.bottom, 5)
                        
                    Text("Foreground Style: Teal")
                        .foregroundStyle(.teal) // Preferred over foregroundColor
                        
                    Text("Kerning: 5")
                        .kerning(5)
                        
                    Text("Tracking: 5")
                        .tracking(5)
                        
                    Text("Strikethrough")
                        .strikethrough(true, pattern: .dot, color: .red)
                        
                    Text("Underline")
                        .underline(true, pattern: .dash, color: .green)
                        
                    Text("Baseline Offset: 10")
                        .baselineOffset(10)
                        .border(.red) // Show bounds
                    Text("Baseline Offset: -10")
                         .baselineOffset(-10)
                         .border(.red) // Show bounds
                         
                    Text("Text Case: Uppercase")
                         .textCase(.uppercase)
                         
                    Text("Text Scale: Secondary")
                        .textScale(.secondary) // Make text smaller relative to context
                    
                    // Toggle bold/italic with state
                    VStack {
                         Text("Toggleable Style")
                            .bold(isBold)
                            .italic(isItalic)
                         Toggle("Bold", isOn: $isBold.animation())
                         Toggle("Italic", isOn: $isItalic.animation())
                    }

                    // Typesetting Language (Example for Thai)
                    Text(verbatim: "สวัสดี SwiftUI") // Hello SwiftUI in Thai
                        .typesettingLanguage(.init(languageCode: .thai))

                    // Custom Text Attribute (Requires defining a TextAttribute conforming type)
                    // Text("Custom Attribute").customAttribute(MyCustomAttribute())
                }
                .padding(.leading)
                
                Divider()

                // --- Text Layout Modifiers ---
                Group {
                    Text("Text Layout Modifiers")
                        .font(.title)
                        .padding(.bottom, 5)

                    Text("This is a long line of text that will be limited to two lines and truncated if it exceeds that limit.")
                        .lineLimit(2)
                        .frame(width: 200)
                        .border(.gray)
                    
                    Text("Line limit range: 2 to 4 lines allowed. This text might wrap.")
                        .lineLimit(2...4) // Reserves space for at least 2, max 4
                        .frame(width: 200)
                        .border(.gray)

                     Text("Line limit 2, reserves space: \n This text always takes space for 2 lines.")
                         .lineLimit(2, reservesSpace: true)
                         .frame(width: 200, alignment: .leading)
                         .border(.gray)
                    
                    Text("Multiline Alignment:\nCentered Text\nWithin the Frame")
                        .multilineTextAlignment(.center)
                        .frame(width: 200)
                        .border(.gray)
                        
                    Text("Truncation Mode: Head truncation if this text is too long.")
                        .truncationMode(.head)
                        .lineLimit(1)
                        .frame(width: 200)
                        .border(.gray)
                    
                    Text("Allows Tightening: Squeezing letters together if needed.")
                        .allowsTightening(true)
                        .lineLimit(1)
                        .frame(width: 200)
                        .border(.gray)
                        
                    Text("Minimum Scale Factor: Text shrinks down to half size.")
                         .minimumScaleFactor(0.5)
                         .frame(height: 20) // Needs height constraint to scale
                         .border(.gray)
                         
                    Text("Line Spacing:\nAdd extra vertical space\nbetween lines.")
                         .lineSpacing(10)
                         .frame(width: 200)
                         .border(.gray)
                }
                .padding(.leading)

            } // End main VStack
            .padding()
        } // End ScrollView
    }
}

// Example of a Custom TextAttribute (Optional Feature)
//struct MyCustomAttribute: TextAttribute {
//    // Implement necessary properties/methods if needed
//}


// Preview Provider
struct TextAndFontDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Add navigation view for better title display
             TextAndFontDemoView()
                .navigationTitle("Text & Font Demo")
        }
    }
}
