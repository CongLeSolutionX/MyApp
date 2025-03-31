//
//  Image+Extensions.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// --- Placeholder Image Assets ---
// Add: "profile_placeholder", "reuters_logo_white", "barrons_logo_white",
// "trump_small_ap", "greenland_thumb", "ron_johnson_thumb",
// "barrons_thumb1", "barrons_thumb2", "barrons_thumb3",
// "ew_logo", "instyle_logo", "pagesix_logo", "usweekly_logo", "enews_logo"
// Ensure you have white/light versions of logos (Reuters, Barron's etc.) if needed for dark mode.

// --- Dummy Image Extension (Add new placeholders) ---
extension Image {
     // Keep existing cases... Add new ones
     init(_ name: String) {
         if UIImage(named: name) != nil {
             self.init(name)
         } else {
             switch name {
                 // Previous placeholders...
                 case "profile_placeholder": self.init(systemName: "person.crop.circle.fill")
                 case "ap_logo", "cnn_logo", "reuters_logo", "fox_logo", "nyt_logo", "bbc_logo", "wsj_logo", "abc_logo", "haaretz_logo", "verge_logo", "wired_logo": self.init(systemName: "newspaper")
                 case "trump_small_ap", "biden_large", "syria_nyt_thumb", "syria_abc_thumb", "syria_haaretz_thumb", "tech_verge_thumb", "tech_wired_thumb", "greenland_thumb", "ron_johnson_thumb", "barrons_thumb1", "barrons_thumb2", "barrons_thumb3": self.init(systemName: "photo")
                 case "marietta_placeholder", "syria_placeholder", "tech_placeholder": self.init(systemName: "photo.on.rectangle.angled")

                 // Newsstand specific placeholders
                 case "reuters_logo_white", "barrons_logo_white": self.init(systemName: "newspaper.fill") // Specific placeholders or default icons
                 case "ew_logo", "instyle_logo", "pagesix_logo", "usweekly_logo", "enews_logo": self.init(systemName: "app.fill") // Logos for tiles

                 default: self.init(systemName: "questionmark.square.dashed")
             }
         }
     }
 }
