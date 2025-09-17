//
//  LiveDeparturesLiveActivity.swift
//  LiveDepartures
//
//  Created by William O'Connor on 17/09/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveDeparturesAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LiveDeparturesLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveDeparturesAttributes.self) { context in
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

extension LiveDeparturesAttributes {
    fileprivate static var preview: LiveDeparturesAttributes {
        LiveDeparturesAttributes(name: "World")
    }
}

extension LiveDeparturesAttributes.ContentState {
    fileprivate static var smiley: LiveDeparturesAttributes.ContentState {
        LiveDeparturesAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LiveDeparturesAttributes.ContentState {
         LiveDeparturesAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LiveDeparturesAttributes.preview) {
   LiveDeparturesLiveActivity()
} contentStates: {
    LiveDeparturesAttributes.ContentState.smiley
    LiveDeparturesAttributes.ContentState.starEyes
}
