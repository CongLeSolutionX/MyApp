//
//  SampleLiveActivity.swift
//  Sample
//
//  Created by Cong Le on 3/14/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SampleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SampleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SampleAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SampleAttributes {
    fileprivate static var preview: SampleAttributes {
        SampleAttributes(name: "World")
    }
}

extension SampleAttributes.ContentState {
    fileprivate static var smiley: SampleAttributes.ContentState {
        SampleAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SampleAttributes.ContentState {
         SampleAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SampleAttributes.preview) {
   SampleLiveActivity()
} contentStates: {
    SampleAttributes.ContentState.smiley
    SampleAttributes.ContentState.starEyes
}
