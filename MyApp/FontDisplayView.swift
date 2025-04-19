//
//  FontDisplayView.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI

// 1. Data Structure to hold font information
struct FontFamilyInfo: Identifiable, Hashable {
    let id = UUID() // Make it identifiable for SwiftUI lists
    let familyName: String
    let fontNames: [String]
}

// 2. SwiftUI View to display the fonts
struct FontDisplayView: View {
    // Sample data based on the provided list
    // In a real app, you would parse this data programmatically
    let fontData: [FontFamilyInfo] = [
        FontFamilyInfo(familyName: "Academy Engraved LET", fontNames: ["AcademyEngravedLetPlain"]),
        FontFamilyInfo(familyName: "Al Nile", fontNames: ["AlNile", "AlNile-Bold"]),
        FontFamilyInfo(familyName: "American Typewriter", fontNames: ["AmericanTypewriter", "AmericanTypewriter-Light", "AmericanTypewriter-Semibold", "AmericanTypewriter-Bold", "AmericanTypewriter-Condensed", "AmericanTypewriter-CondensedLight", "AmericanTypewriter-CondensedBold"]),
        FontFamilyInfo(familyName: "Apple Color Emoji", fontNames: ["AppleColorEmoji"]),
        FontFamilyInfo(familyName: "Apple SD Gothic Neo", fontNames: ["AppleSDGothicNeo-Regular", "AppleSDGothicNeo-Thin", "AppleSDGothicNeo-UltraLight", "AppleSDGothicNeo-Light", "AppleSDGothicNeo-Medium", "AppleSDGothicNeo-SemiBold", "AppleSDGothicNeo-Bold"]),
        FontFamilyInfo(familyName: "Apple Symbols", fontNames: ["AppleSymbols"]),
        FontFamilyInfo(familyName: "Arial", fontNames: ["ArialMT", "Arial-ItalicMT", "Arial-BoldMT", "Arial-BoldItalicMT"]),
        FontFamilyInfo(familyName: "Arial Hebrew", fontNames: ["ArialHebrew", "ArialHebrew-Light", "ArialHebrew-Bold"]),
        FontFamilyInfo(familyName: "Arial Rounded MT Bold", fontNames: ["ArialRoundedMTBold"]),
        FontFamilyInfo(familyName: "Avenir", fontNames: ["Avenir-Book", "Avenir-Roman", "Avenir-BookOblique", "Avenir-Oblique", "Avenir-Light", "Avenir-LightOblique", "Avenir-Medium", "Avenir-MediumOblique", "Avenir-Heavy", "Avenir-HeavyOblique", "Avenir-Black", "Avenir-BlackOblique"]),
        FontFamilyInfo(familyName: "Avenir Next", fontNames: ["AvenirNext-Regular", "AvenirNext-Italic", "AvenirNext-UltraLight", "AvenirNext-UltraLightItalic", "AvenirNext-Medium", "AvenirNext-MediumItalic", "AvenirNext-DemiBold", "AvenirNext-DemiBoldItalic", "AvenirNext-Bold", "AvenirNext-BoldItalic", "AvenirNext-Heavy", "AvenirNext-HeavyItalic"]),
        FontFamilyInfo(familyName: "Avenir Next Condensed", fontNames: ["AvenirNextCondensed-Regular", "AvenirNextCondensed-Italic", "AvenirNextCondensed-UltraLight", "AvenirNextCondensed-UltraLightItalic", "AvenirNextCondensed-Medium", "AvenirNextCondensed-MediumItalic", "AvenirNextCondensed-DemiBold", "AvenirNextCondensed-DemiBoldItalic", "AvenirNextCondensed-Bold", "AvenirNextCondensed-BoldItalic", "AvenirNextCondensed-Heavy", "AvenirNextCondensed-HeavyItalic"]),
        FontFamilyInfo(familyName: "Baskerville", fontNames: ["Baskerville", "Baskerville-Italic", "Baskerville-SemiBold", "Baskerville-SemiBoldItalic", "Baskerville-Bold", "Baskerville-BoldItalic"]),
        FontFamilyInfo(familyName: "Bodoni 72", fontNames: ["BodoniSvtyTwoITCTT-Book", "BodoniSvtyTwoITCTT-BookIta", "BodoniSvtyTwoITCTT-Bold"]),
        FontFamilyInfo(familyName: "Bodoni 72 Oldstyle", fontNames: ["BodoniSvtyTwoOSITCTT-Book", "BodoniSvtyTwoOSITCTT-BookIt", "BodoniSvtyTwoOSITCTT-Bold"]),
        FontFamilyInfo(familyName: "Bodoni 72 Smallcaps", fontNames: ["BodoniSvtyTwoSCITCTT-Book"]),
        FontFamilyInfo(familyName: "Bodoni Ornaments", fontNames: ["BodoniOrnamentsITCTT"]),
        FontFamilyInfo(familyName: "Bradley Hand", fontNames: ["BradleyHandITCTT-Bold"]),
        FontFamilyInfo(familyName: "Chalkboard SE", fontNames: ["ChalkboardSE-Regular", "ChalkboardSE-Light", "ChalkboardSE-Bold"]),
        FontFamilyInfo(familyName: "Chalkduster", fontNames: ["Chalkduster"]),
        FontFamilyInfo(familyName: "Charter", fontNames: ["Charter-Roman", "Charter-Italic", "Charter-Bold", "Charter-BoldItalic", "Charter-Black", "Charter-BlackItalic"]),
        FontFamilyInfo(familyName: "Cochin", fontNames: ["Cochin", "Cochin-Italic", "Cochin-Bold", "Cochin-BoldItalic"]),
        FontFamilyInfo(familyName: "Copperplate", fontNames: ["Copperplate", "Copperplate-Light", "Copperplate-Bold"]),
        FontFamilyInfo(familyName: "Courier New", fontNames: ["CourierNewPSMT", "CourierNewPS-ItalicMT", "CourierNewPS-BoldMT", "CourierNewPS-BoldItalicMT"]),
        FontFamilyInfo(familyName: "DIN Alternate", fontNames: ["DINAlternate-Bold"]),
        FontFamilyInfo(familyName: "DIN Condensed", fontNames: ["DINCondensed-Bold"]),
        FontFamilyInfo(familyName: "Damascus", fontNames: ["Damascus", "DamascusLight", "DamascusMedium", "DamascusSemiBold", "DamascusBold"]),
        FontFamilyInfo(familyName: "Devanagari Sangam MN", fontNames: ["DevanagariSangamMN", "DevanagariSangamMN-Bold"]),
        FontFamilyInfo(familyName: "Didot", fontNames: ["Didot", "Didot-Italic", "Didot-Bold"]),
        FontFamilyInfo(familyName: "Euphemia UCAS", fontNames: ["EuphemiaUCAS", "EuphemiaUCAS-Italic", "EuphemiaUCAS-Bold"]),
        FontFamilyInfo(familyName: "Farah", fontNames: ["Farah"]),
        FontFamilyInfo(familyName: "Futura", fontNames: ["Futura-Medium", "Futura-MediumItalic", "Futura-Bold", "Futura-CondensedMedium", "Futura-CondensedExtraBold"]),
        FontFamilyInfo(familyName: "Galvji", fontNames: ["Galvji", "Galvji-Bold"]),
        FontFamilyInfo(familyName: "Geeza Pro", fontNames: ["GeezaPro", "GeezaPro-Bold"]),
        FontFamilyInfo(familyName: "Georgia", fontNames: ["Georgia", "Georgia-Italic", "Georgia-Bold", "Georgia-BoldItalic"]),
        FontFamilyInfo(familyName: "Gill Sans", fontNames: ["GillSans", "GillSans-Italic", "GillSans-Light", "GillSans-LightItalic", "GillSans-SemiBold", "GillSans-SemiBoldItalic", "GillSans-Bold", "GillSans-BoldItalic", "GillSans-UltraBold"]),
        FontFamilyInfo(familyName: "Grantha Sangam MN", fontNames: ["GranthaSangamMN-Regular", "GranthaSangamMN-Bold"]),
        FontFamilyInfo(familyName: "Helvetica", fontNames: ["Helvetica", "Helvetica-Oblique", "Helvetica-Light", "Helvetica-LightOblique", "Helvetica-Bold", "Helvetica-BoldOblique"]),
        FontFamilyInfo(familyName: "Helvetica Neue", fontNames: ["HelveticaNeue", "HelveticaNeue-Italic", "HelveticaNeue-UltraLight", "HelveticaNeue-UltraLightItalic", "HelveticaNeue-Thin", "HelveticaNeue-ThinItalic", "HelveticaNeue-Light", "HelveticaNeue-LightItalic", "HelveticaNeue-Medium", "HelveticaNeue-MediumItalic", "HelveticaNeue-Bold", "HelveticaNeue-BoldItalic", "HelveticaNeue-CondensedBold", "HelveticaNeue-CondensedBlack"]),
        FontFamilyInfo(familyName: "Hiragino Maru Gothic ProN", fontNames: ["HiraMaruProN-W4"]),
        FontFamilyInfo(familyName: "Hiragino Mincho ProN", fontNames: ["HiraMinProN-W3", "HiraMinProN-W6"]),
        FontFamilyInfo(familyName: "Hiragino Sans", fontNames: ["HiraginoSans-W3", "HiraginoSans-W4", "HiraginoSans-W5", "HiraginoSans-W6", "HiraginoSans-W7", "HiraginoSans-W8"]),
        FontFamilyInfo(familyName: "Hoefler Text", fontNames: ["HoeflerText-Regular", "HoeflerText-Italic", "HoeflerText-Black", "HoeflerText-BlackItalic"]),
        FontFamilyInfo(familyName: "Impact", fontNames: ["Impact"]),
        FontFamilyInfo(familyName: "Kailasa", fontNames: ["Kailasa", "Kailasa-Bold"]),
        FontFamilyInfo(familyName: "Kefa", fontNames: ["Kefa-Regular"]),
        FontFamilyInfo(familyName: "Khmer Sangam MN", fontNames: ["KhmerSangamMN"]),
        FontFamilyInfo(familyName: "Kohinoor Bangla", fontNames: ["KohinoorBangla-Regular", "KohinoorBangla-Light", "KohinoorBangla-Semibold"]),
        FontFamilyInfo(familyName: "Kohinoor Devanagari", fontNames: ["KohinoorDevanagari-Regular", "KohinoorDevanagari-Light", "KohinoorDevanagari-Semibold"]),
        FontFamilyInfo(familyName: "Kohinoor Gujarati", fontNames: ["KohinoorGujarati-Regular", "KohinoorGujarati-Light", "KohinoorGujarati-Bold"]),
        FontFamilyInfo(familyName: "Kohinoor Telugu", fontNames: ["KohinoorTelugu-Regular", "KohinoorTelugu-Light", "KohinoorTelugu-Medium"]),
        FontFamilyInfo(familyName: "Lao Sangam MN", fontNames: ["LaoSangamMN"]),
        FontFamilyInfo(familyName: "Malayalam Sangam MN", fontNames: ["MalayalamSangamMN", "MalayalamSangamMN-Bold"]),
        FontFamilyInfo(familyName: "Marker Felt", fontNames: ["MarkerFelt-Thin", "MarkerFelt-Wide"]),
        FontFamilyInfo(familyName: "Menlo", fontNames: ["Menlo-Regular", "Menlo-Italic", "Menlo-Bold", "Menlo-BoldItalic"]),
        FontFamilyInfo(familyName: "Mishafi", fontNames: ["DiwanMishafi"]),
        FontFamilyInfo(familyName: "Mukta Mahee", fontNames: ["MuktaMahee-Regular", "MuktaMahee-Light", "MuktaMahee-Bold"]),
        FontFamilyInfo(familyName: "Myanmar Sangam MN", fontNames: ["MyanmarSangamMN", "MyanmarSangamMN-Bold"]),
        FontFamilyInfo(familyName: "Noteworthy", fontNames: ["Noteworthy-Light", "Noteworthy-Bold"]),
        FontFamilyInfo(familyName: "Noto Nastaliq Urdu", fontNames: ["NotoNastaliqUrdu", "NotoNastaliqUrdu-Bold"]),
        FontFamilyInfo(familyName: "Noto Sans Kannada", fontNames: ["NotoSansKannada-Regular", "NotoSansKannada-Light", "NotoSansKannada-Bold"]),
        FontFamilyInfo(familyName: "Noto Sans Myanmar", fontNames: ["NotoSansMyanmar-Regular", "NotoSansMyanmar-Light", "NotoSansMyanmar-Bold"]),
        FontFamilyInfo(familyName: "Noto Sans Oriya", fontNames: ["NotoSansOriya", "NotoSansOriya-Bold"]),
        FontFamilyInfo(familyName: "Noto Sans Syriac", fontNames: ["NotoSansSyriac-Regular", "NotoSansSyriac-Regular_Thin", "NotoSansSyriac-Regular_ExtraLight", "NotoSansSyriac-Regular_Light", "NotoSansSyriac-Regular_Medium", "NotoSansSyriac-Regular_SemiBold", "NotoSansSyriac-Regular_Bold", "NotoSansSyriac-Regular_ExtraBold", "NotoSansSyriac-Regular_Black"]),
        FontFamilyInfo(familyName: "Optima", fontNames: ["Optima-Regular", "Optima-Italic", "Optima-Bold", "Optima-BoldItalic", "Optima-ExtraBlack"]),
        FontFamilyInfo(familyName: "Palatino", fontNames: ["Palatino-Roman", "Palatino-Italic", "Palatino-Bold", "Palatino-BoldItalic"]),
        FontFamilyInfo(familyName: "Papyrus", fontNames: ["Papyrus", "Papyrus-Condensed"]),
        FontFamilyInfo(familyName: "Party LET", fontNames: ["PartyLetPlain"]),
        FontFamilyInfo(familyName: "PingFang HK", fontNames: ["PingFangHK-Regular", "PingFangHK-Ultralight", "PingFangHK-Thin", "PingFangHK-Light", "PingFangHK-Medium", "PingFangHK-Semibold"]),
        FontFamilyInfo(familyName: "PingFang MO", fontNames: ["PingFangMO-Regular", "PingFangMO-Ultralight", "PingFangMO-Thin", "PingFangMO-Light", "PingFangMO-Medium", "PingFangMO-Semibold"]),
        FontFamilyInfo(familyName: "PingFang SC", fontNames: ["PingFangSC-Regular", "PingFangSC-Ultralight", "PingFangSC-Thin", "PingFangSC-Light", "PingFangSC-Medium", "PingFangSC-Semibold"]),
        FontFamilyInfo(familyName: "PingFang TC", fontNames: ["PingFangTC-Regular", "PingFangTC-Ultralight", "PingFangTC-Thin", "PingFangTC-Light", "PingFangTC-Medium", "PingFangTC-Semibold"]),
        FontFamilyInfo(familyName: "Rockwell", fontNames: ["Rockwell-Regular", "Rockwell-Italic", "Rockwell-Bold", "Rockwell-BoldItalic"]),
        FontFamilyInfo(familyName: "STIX Two Math", fontNames: ["STIXTwoMath-Regular"]),
        FontFamilyInfo(familyName: "STIX Two Text", fontNames: ["STIXTwoText", "STIXTwoText-Italic", "STIXTwoText_Medium", "STIXTwoText-Italic_Medium-Italic", "STIXTwoText_SemiBold", "STIXTwoText-Italic_SemiBold-Italic", "STIXTwoText_Bold", "STIXTwoText-Italic_Bold-Italic"]),
        FontFamilyInfo(familyName: "Savoye LET", fontNames: ["SavoyeLetPlain"]),
        FontFamilyInfo(familyName: "Sinhala Sangam MN", fontNames: ["SinhalaSangamMN", "SinhalaSangamMN-Bold"]),
        FontFamilyInfo(familyName: "Snell Roundhand", fontNames: ["SnellRoundhand", "SnellRoundhand-Bold", "SnellRoundhand-Black"]),
        FontFamilyInfo(familyName: "Super Bread", fontNames: ["SuperBread"]), // Added Super Bread
        FontFamilyInfo(familyName: "Symbol", fontNames: ["Symbol"]),
        FontFamilyInfo(familyName: "Tamil Sangam MN", fontNames: ["TamilSangamMN", "TamilSangamMN-Bold"]),
        FontFamilyInfo(familyName: "Thonburi", fontNames: ["Thonburi", "Thonburi-Light", "Thonburi-Bold"]),
        FontFamilyInfo(familyName: "Times New Roman", fontNames: ["TimesNewRomanPSMT", "TimesNewRomanPS-ItalicMT", "TimesNewRomanPS-BoldMT", "TimesNewRomanPS-BoldItalicMT"]),
        FontFamilyInfo(familyName: "Trebuchet MS", fontNames: ["TrebuchetMS", "TrebuchetMS-Italic", "TrebuchetMS-Bold", "Trebuchet-BoldItalic"]),
        FontFamilyInfo(familyName: "Verdana", fontNames: ["Verdana", "Verdana-Italic", "Verdana-Bold", "Verdana-BoldItalic"]),
        FontFamilyInfo(familyName: "Zapf Dingbats", fontNames: ["ZapfDingbatsITC"]),
        FontFamilyInfo(familyName: "Zapfino", fontNames: ["Zapfino"])
    ]

    var body: some View {
        NavigationView {
            // Display the data in a list
            List {
                // Iterate over each font family
                ForEach(fontData) { familyInfo in
                    // Section provides grouping, but VStack is also fine
                    Section(header: Text(familyInfo.familyName).font(.headline)) {
                        // Iterate over each font name within the family
                        ForEach(familyInfo.fontNames, id: \.self) { fontName in
                            // Display the font name and apply the font itself
                            Text(fontName)
                                .font(Font.custom(fontName, size: 16)) // Apply the actual font
                                .padding(.leading)
                                // Handle cases where a font might not load gracefully
                                .onAppear {
                                    // Optional: Check if font loads correctly
                                    // You might need UIKit interop (`UIFont(name:size:)`) for robust checking
                                }
                        }
                    }
                }
            }
            .navigationTitle("iOS Fonts")
            .listStyle(GroupedListStyle()) // Use grouped style for better visual separation
        }
    }
}

// 3. Preview Provider for Xcode Canvas
struct FontDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        FontDisplayView()
    }
}

// How to get fonts programmatically (informational, not directly used in the view above)
/*
func listAvailableFonts() {
    for familyName in UIFont.familyNames.sorted() {
        let fontNames = UIFont.fontNames(forFamilyName: familyName).sorted()
        print("Family: \(familyName) \tFont names: \(fontNames)")
        // You could populate the `fontData` array here
    }
}
*/
