import WidgetKit
import SwiftUI

private struct 🄿rovider: TimelineProvider {
    func placeholder(in context: Context) -> 🅂impleEntry {
        🅂impleEntry()
    }
    func getSnapshot(in context: Context, completion: @escaping (🅂impleEntry) -> ()) {
        completion(🅂impleEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        completion(Timeline(entries: [🅂impleEntry()], policy: .never))
    }
}

private struct 🅂impleEntry: TimelineEntry {
    let date: Date = .now
}

private struct 🄿SComplicationEntryView : View {
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text("☖")
                .font(.title)
        }
        .widgetAccentable()
    }
}

@main
struct 🄿SComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PSComplication", provider: 🄿rovider()) { _ in
            🄿SComplicationEntryView()
        }
        .configurationDisplayName("Plain将棋盤")
        .description("ショートカット")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}
