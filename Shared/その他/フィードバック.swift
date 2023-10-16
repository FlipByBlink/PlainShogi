import SwiftUI
#if os(watchOS)
import WatchKit
#endif

enum フィードバック {
#if os(iOS)
    static func 軽め() { UISelectionFeedbackGenerator().selectionChanged() }
    static func 強め() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func 成功() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func エラー() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func 警告() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
#elseif os(watchOS)
    static func 軽め() { WKInterfaceDevice.current().play(.click) }
    static func 強め() { WKInterfaceDevice.current().play(.start) }
    static func 成功() { WKInterfaceDevice.current().play(.success) }
    static func エラー() { WKInterfaceDevice.current().play(.failure) }
    static func 警告() { WKInterfaceDevice.current().play(.success) }
#elseif os(tvOS)
    static func 軽め() { /* Nothing to do */ }
    static func 強め() { /* Nothing to do */ }
    static func 成功() { /* Nothing to do */ }
    static func エラー() { /* Nothing to do */ }
    static func 警告() { /* Nothing to do */ }
#endif
}
