import Foundation

class フィードバックモデル {
    private let 音声: 音声フィードバックモデル = .init()
    func 軽め() {
        システムフィードバック.軽め()
    }
    func 強め(_ 音声あり: Bool = true) {
        システムフィードバック.強め()
        if 音声あり, self.効果音有効 { self.音声.メイン再生() }
    }
    func 成功() {
        システムフィードバック.成功()
    }
    func エラー() {
        システムフィードバック.エラー()
        if self.効果音有効 { self.音声.ジャラジャラ再生() }
    }
    func 警告() {
        システムフィードバック.警告()
    }
}

fileprivate extension フィードバックモデル {
    private var 効果音有効: Bool {
        !UserDefaults.standard.bool(forKey: "効果音無効化")
    }
}
