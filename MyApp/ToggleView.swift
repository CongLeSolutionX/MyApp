//
//  SimpleToggleView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI

// --- @Entry Macro Examples ---

extension EnvironmentValues {
    // Old way (boilerplate)
    /*
    private struct KaraokePartyColorKey: EnvironmentKey {
        static let defaultValue: Color = .purple
    }
    var karaokePartyColor: Color {
        get { self[KaraokePartyColorKey.self] }
        set { self[KaraokePartyColorKey.self] = newValue }
    }
    */

    // New way with @Entry
    @Entry var karaokePartyColor: Color = .purple
}

//extension FocusValues {
//    // Old way (boilerplate)
//    /*
//    private struct LyricNoteKey: FocusValueKey {
//       typealias Value = Binding<String?>
//    }
//     var lyricNote: Binding<String?>? {
//        get { self[LyricNoteKey.self] }
//        set { self[LyricNoteKey.self] = newValue }
//    }
//    */
//    // New way with @Entry
//    @Entry var lyricNote: String? = nil // Example focus value
//}

extension Transaction {
    // Old way (boilerplate)
    /*
    private struct AnimatePartyIconsKey: TransactionKey {
        static let defaultValue: Bool = false
    }
    var animatePartyIcons: Bool {
        get { self[AnimatePartyIconsKey.self] }
        set { self[AnimatePartyIconsKey.self] = newValue }
    }
     */
    // New way with @Entry
    @Entry var animatePartyIcons: Bool = false
}

// ContainerValues example was shown in the Custom Container section above

// --- @Previewable Macro Example ---

struct SimpleToggleView: View {
    @Binding var isOn: Bool
    var label: String

    var body: some View {
        Toggle(label, isOn: $isOn)
            .padding()
    }
}

// Old Preview Setup (Boilerplate Wrapper View)
/*
struct SimpleToggleView_PreviewWrapper: View {
    @State private var toggleState = true
    var body: some View {
        SimpleToggleView(isOn: $toggleState, label: "Show Karaoke Lyrics")
    }
}
#Preview {
    SimpleToggleView_PreviewWrapper()
}
*/

// New Preview Setup with @Previewable
#Preview {
   @Previewable @State var showLyrics = true // Use @State directly
   SimpleToggleView(isOn: $showLyrics, label: "Show Karaoke Lyrics")
}
