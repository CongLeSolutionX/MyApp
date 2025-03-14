//
//  AVCameraControlCenterLiveActivity.swift
//  AVCameraControlCenter
//
//  Created by Cong Le on 3/14/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AVCameraControlCenterAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AVCameraControlCenterLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AVCameraControlCenterAttributes.self) { context in
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

extension AVCameraControlCenterAttributes {
    fileprivate static var preview: AVCameraControlCenterAttributes {
        AVCameraControlCenterAttributes(name: "World")
    }
}

extension AVCameraControlCenterAttributes.ContentState {
    fileprivate static var smiley: AVCameraControlCenterAttributes.ContentState {
        AVCameraControlCenterAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AVCameraControlCenterAttributes.ContentState {
         AVCameraControlCenterAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AVCameraControlCenterAttributes.preview) {
   AVCameraControlCenterLiveActivity()
} contentStates: {
    AVCameraControlCenterAttributes.ContentState.smiley
    AVCameraControlCenterAttributes.ContentState.starEyes
}
