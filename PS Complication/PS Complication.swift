import WidgetKit
import SwiftUI

private struct 🄿rovider: TimelineProvider {
    func placeholder(in context: Context) -> 🄴ntry {
        🄴ntry()
    }
    func getSnapshot(in context: Context, completion: @escaping (🄴ntry) -> ()) {
        completion(🄴ntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        completion(Timeline(entries: [🄴ntry()], policy: .never))
    }
}

private struct 🄴ntry: TimelineEntry {
    let date: Date = .now
}

private struct 🄴ntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var body: some View {
        switch self.widgetFamily {
            case .accessoryCircular, .accessoryCorner:
                ZStack {
                    AccessoryWidgetBackground()
                    GeometryReader { 📐 in
                        Path {
                            $0.addLines([
                                .init(x: 50, y: 20),
                                .init(x: 70, y: 30),
                                .init(x: 78, y: 80),
                                .init(x: 22, y: 80),
                                .init(x: 30, y: 30),
                            ])
                            $0.closeSubpath()
                        }
                        .stroke(lineWidth: 6)
                        .scaleEffect(min(📐.size.width, 📐.size.height) / 100,
                                     anchor: .topLeading)
                    }
                    .padding(6)
                }
                .widgetAccentable()
            case .accessoryInline:
                Text("☖")
            default:
                Text("🐛")
        }
    }
}

@main
struct 🄿SComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PSComplication", provider: 🄿rovider()) { _ in
            🄴ntryView()
        }
        .configurationDisplayName("Plain将棋盤")
        .description("ショートカット")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}
