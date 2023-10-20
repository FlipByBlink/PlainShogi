import SwiftUI

struct 画像キャッシュハンドラー: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @AppStorage("セリフ体") var セリフ体オプション: Bool = false
    @AppStorage("太字") var 太字オプション: Bool = false
    @AppStorage("サイズ") var サイズオプション: 字体.サイズ = .標準
    @State private var 現在の盤面を画像として保存: Bool = false
    @Binding var サムネイル: Image
    func body(content: Content) -> some View {
        content
            .task(priority: .background) { self.画像保存をリクエスト() }
            .onChange(of: self.モデル.局面) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.モデル.上下反転) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.モデル.english表記) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.モデル.直近操作強調表示機能オフ) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.セリフ体オプション) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.太字オプション) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.サイズオプション) { _ in self.画像保存をリクエスト() }
            .onChange(of: self.現在の盤面を画像として保存) {
                if $0 { self.画像保存を実行() }
            }
    }
    init(_ サムネイル: Binding<Image>) {
        self._サムネイル = サムネイル
    }
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
