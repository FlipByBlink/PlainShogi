import SwiftUI
import AVFAudio

class 音声フィードバック {
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
    func メイン再生() {
        Task(priority: .background) {
            self.メイン音声プレイヤーズ.randomElement()?.play()
        }
    }
    func ジャラジャラ再生() {
        Task(priority: .background) {
            self.ジャラジャラ音声プレイヤー?.play()
        }
    }
    static func カテゴリー設定() {
        try? AVAudioSession().setCategory(.ambient)
    }
}
