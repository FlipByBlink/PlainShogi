#if os(iOS) || os(visionOS)
import SwiftUI
import UniformTypeIdentifiers

extension アプリモデル {
    func 現在の盤面をテキストに変換する() -> String {
        テキスト連携機能.テキストに変換する(self.局面)
    }
    func テキストを局面に変換して読み込む(_ テキスト: String) throws {
        if let インポートした局面 = テキスト連携機能.局面モデルに変換する(テキスト) {
            self.局面.現在の局面として適用する(インポートした局面)
            self.SharePlay中なら現在の局面を参加者に送信する()
            self.フィードバック.成功()
        } else {
            throw Self.テキスト読み込みエラー.局面変換失敗
        }
    }
    func 現在の局面をテキストとしてコピー() {
        UIPasteboard.general.string = self.現在の盤面をテキストに変換する()
        self.フィードバック.成功()
    }
    func テキストを局面としてペースト() throws {
        guard let テキスト = UIPasteboard.general.string else {
            throw Self.テキスト読み込みエラー.ペーストされたものがテキストではない
        }
        try self.テキストを局面に変換して読み込む(テキスト)
    }
    private enum テキスト読み込みエラー: Error {
        case 局面変換失敗, ペーストされたものがテキストではない
    }
    func このアイテムを盤面に反映する(_ itemProviders: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let itemProvider = itemProviders.first else { return }
                let secureCodingObject = try await itemProvider.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let データ = secureCodingObject as? Data else { return }
                guard let テキスト = String(data: データ, encoding: .utf8) else { return }
                try self.テキストを局面に変換して読み込む(テキスト)
            } catch {
                print(#function, error)
            }
            self.ドラッグ中の駒 = .無し
        }
    }
}
#endif
