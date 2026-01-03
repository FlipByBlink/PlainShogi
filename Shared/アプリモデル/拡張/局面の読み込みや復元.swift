import SwiftUI

extension アプリモデル {
    
    func 任意の局面を現在の局面として適用する(_ 局面: 局面モデル) { //履歴, ブックマーク
        self.表示中のシート = nil
        withAnimation { self.局面.現在の局面として適用する(局面) }
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.成功()
    }
    
    func 現在の局面をブックマークする() {
        self.局面.現在の局面をブックマークする()
        self.フィードバック.軽め()
    }
    
    @objc @MainActor
    func iCloudによる外部からの履歴変更を適用する(_ notification: Notification) {
        guard ICloudデータ.このキーが変更された(key: "履歴", notification) else { return }
        Task { @MainActor in
            guard let 外部で変更された局面の最新 = 局面モデル.履歴.last else { return }
            self.局面 = 外部で変更された局面の最新
            self.SharePlay中なら現在の局面を参加者に送信する()
            self.駒の選択を解除する()
        }
    }
}
