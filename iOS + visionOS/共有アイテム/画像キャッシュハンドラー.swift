import SwiftUI

struct 画像キャッシュハンドラー: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @State private var 現在の盤面を画像として保存: Bool = false
    @Binding var サムネイル: Image
    func body(content: Content) -> some View {
        content
            .task(priority: .background) { self.画像保存をリクエスト() }
            .onChange(of: モデル.局面) { _ in self.画像保存をリクエスト() }
            .onChange(of: モデル.上下反転) { _ in self.画像保存をリクエスト() }
            .onChange(of: モデル.english表記) { _ in self.画像保存をリクエスト() }
            .onChange(of: モデル.直近操作強調表示機能オフ) { _ in self.画像保存をリクエスト() }
            .onChange(of: モデル.セリフ体) { _ in self.画像保存をリクエスト() }
            .onChange(of: モデル.太字) { _ in self.画像保存をリクエスト() }
            .onChange(of: モデル.サイズ) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.現在の盤面を画像として保存) {
                if $0 { self.画像保存を実行() }
            }
    }
    init(_ サムネイル: Binding<Image>) {
        self._サムネイル = サムネイル
    }
}

private extension 画像キャッシュハンドラー {
    private func 画像保存をリクエスト() {
        Task(priority: .background) {
            try? await Task.sleep(for: .seconds(0.5))
            self.現在の盤面を画像として保存 = true
        }
    }
    private func 画像保存を実行() {
        画像書き出し.保存(モデル)
        self.サムネイル = 画像書き出し.サムネイルを取得(モデル)
        self.現在の盤面を画像として保存 = false
    }
}
