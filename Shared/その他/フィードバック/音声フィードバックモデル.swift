import SwiftUI
import AVFAudio

class 音声フィードバックモデル {
    private var メイン音声プレイヤーズ: [AVAudioPlayer] = []
    private var ジャラジャラ音声プレイヤー: AVAudioPlayer?
    init() {
        Task(priority: .background) {
            self.メイン音声プレイヤーズ = (1...6).compactMap {
                if let ﾃﾞｰﾀ = NSDataAsset(name: "mainSound\($0)")?.data,
                   let ﾌﾟﾚｲﾔｰ = try? AVAudioPlayer(data: ﾃﾞｰﾀ) {
                    ﾌﾟﾚｲﾔｰ.volume = 0.5
                    ﾌﾟﾚｲﾔｰ.prepareToPlay()
                    return ﾌﾟﾚｲﾔｰ
                } else {
                    assertionFailure()
                    return nil
                }
            }
            if let ﾃﾞｰﾀ = NSDataAsset(name: "errorSound")?.data,
               let ﾌﾟﾚｲﾔｰ = try? AVAudioPlayer(data: ﾃﾞｰﾀ) {
                ﾌﾟﾚｲﾔｰ.volume = 0.13
                ﾌﾟﾚｲﾔｰ.prepareToPlay()
                self.ジャラジャラ音声プレイヤー = ﾌﾟﾚｲﾔｰ
            } else {
                assertionFailure()
            }
            Self.音声カテゴリー設定()
        }
    }
    func メイン再生() {
        Task(priority: .background) {
            Self.音声カテゴリー設定()
            self.メイン音声プレイヤーズ.randomElement()?.play()
        }
    }
    func ジャラジャラ再生() {
        Task(priority: .background) {
            Self.音声カテゴリー設定()
            self.ジャラジャラ音声プレイヤー?.play()
        }
    }
    private static func 音声カテゴリー設定() {
        try? AVAudioSession().setCategory(.ambient)
    }
}
