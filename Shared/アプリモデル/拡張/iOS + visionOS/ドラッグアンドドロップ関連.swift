#if os(iOS) || os(visionOS)
import SwiftUI

//MARK: - ==== ドラッグ関連 ====
extension アプリモデル {
    func この駒をドラッグし始める(_ 場所: 駒の場所) -> NSItemProvider {
        self.選択中の駒の値を変更する(.なし)
        self.フィードバック.軽め()
        self.ドラッグ中の駒 = .アプリ内の駒(場所)
        return self.ドラッグ対象となるアイテムを用意する()
    }
    private func ドラッグ対象となるアイテムを用意する() -> NSItemProvider {
        let テキスト = self.現在の盤面をテキストに変換する()
        let itemProvider = NSItemProvider(object: テキスト as NSItemProviderWriting)
        itemProvider.suggestedName = "アプリ内でのコマ移動"
        return itemProvider
    }
}

//MARK: - ==== ドロップ関連 ====
extension アプリモデル {
    func ここにドロップする(_ 置いた場所: 駒の移動先パターン, _ dropInfo: DropInfo) -> Bool {
        do {
            switch self.ドラッグ中の駒 {
                case .アプリ内の駒(let 出発場所):
                    try self.局面.駒を移動させる(出発場所, 置いた場所)
                    self.駒移動後の成駒について対応する(出発場所, 置いた場所)
                    self.ドラッグ中の駒 = .無し
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    self.フィードバック.ドロップ()
                case .アプリ外のコンテンツ:
                    let itemProviders = dropInfo.itemProviders(for: [.utf8PlainText])
                    self.このアイテムを盤面に反映する(itemProviders)
                case .無し:
                    return false
            }
            return true
        } catch 局面モデル.駒移動エラー.無効 {
            return false
        } catch {
            print("🚨", error.localizedDescription)
            assertionFailure()
            return false
        }
    }
    func ここはドロップ可能か確認する(_ 移動先: 駒の移動先パターン) -> DropProposal? {
        guard case .アプリ内の駒(let ドラッグし始めた場所) = self.ドラッグ中の駒 else { return nil }
        if self.局面.ここからここへは移動不可(ドラッグし始めた場所, 移動先) {
            return DropProposal(operation: .cancel)
        } else {
            return nil
        }
    }
    func 有効なドロップかチェックする(_ dropInfo: DropInfo) -> Bool {
        let itemProviders = dropInfo.itemProviders(for: [.utf8PlainText])
        guard let itemProvider = itemProviders.first else { return false }
#if targetEnvironment(macCatalyst)
        if !MacCatalyst調整.このアイテムはアプリ内でのドラッグ(itemProvider) {
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
#else
        if let suggestedName = itemProvider.suggestedName {
            if suggestedName != "アプリ内でのコマ移動" {
                self.ドラッグ中の駒 = .アプリ外のコンテンツ
            }
        } else {
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
#endif
    }
}
#endif
