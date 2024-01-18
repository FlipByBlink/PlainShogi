import SwiftUI
import AVFAudio
#if os(watchOS)
import WatchKit
#endif

enum システムフィードバック {
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

class フィードバック {
    private var メイン音声プレイヤーズ: [AVAudioPlayer] = []
    private var ジャラジャラ音声プレイヤー: AVAudioPlayer?
    init() {
        Task(priority: .background) {
            self.メイン音声プレイヤーズ = (1...6).compactMap {
                if let ﾃﾞｰﾀ = NSDataAsset(name: "sound\($0)")?.data,
                   let ﾌﾟﾚｲﾔｰ = try? AVAudioPlayer(data: ﾃﾞｰﾀ) {
                    ﾌﾟﾚｲﾔｰ.volume = 0.5
                    ﾌﾟﾚｲﾔｰ.prepareToPlay()
                    return ﾌﾟﾚｲﾔｰ
                } else {
                    assertionFailure()
                    return nil
                }
            }
            if let ﾃﾞｰﾀ = NSDataAsset(name: "BigActionSound")?.data,
               let ﾌﾟﾚｲﾔｰ = try? AVAudioPlayer(data: ﾃﾞｰﾀ) {
                ﾌﾟﾚｲﾔｰ.volume = 0.13
                ﾌﾟﾚｲﾔｰ.prepareToPlay()
                self.ジャラジャラ音声プレイヤー = ﾌﾟﾚｲﾔｰ
            } else {
                assertionFailure()
            }
        }
    }
    private func メイン音声再生() {
        Task(priority: .background) {
            self.メイン音声プレイヤーズ.randomElement()?.play()
        }
    }
    private func ジャラジャラ音声再生() {
        Task(priority: .background) {
            self.ジャラジャラ音声プレイヤー?.play()
        }
    }
    static func 音声カテゴリー設定() {
        try? AVAudioSession().setCategory(.ambient)
    }
}
