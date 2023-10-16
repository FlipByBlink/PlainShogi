import SwiftUI

struct シート管理: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    @EnvironmentObject private var アプリ内課金: アプリ内課金モデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $モデル.表示中のシート) { カテゴリ in
                if case .広告 = カテゴリ {
                    広告コンテンツ()
                        .environmentObject(アプリ内課金)
                } else {
                    NavigationView {
                        Group {
                            switch カテゴリ {
                                case .メニュー: アプリメニュー()
                                case .履歴: 履歴メニュー()
                                case .ブックマーク: ブックマークメニュー()
                                case .手駒増減(let 陣営): 手駒増減メニュー(陣営)
                                case .SharePlayガイド: SharePlayガイド()
                                case .広告: Text(verbatim: "🐛")
                            }
                        }
                        .toolbar { self.閉じるボタン() }
                    }
                    .environmentObject(モデル)
                    .onAppear { フィードバック.軽め() }
                }
            }
            .onAppear {
                if アプリ内課金.checkToShowADSheet() { モデル.表示中のシート = .広告 }
            }
    }
    private func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                モデル.表示中のシート = nil
                フィードバック.軽め()
            } label: {
                Image(systemName: "chevron.down")
                    .grayscale(1.0)
            }
            .accessibilityLabel("Dismiss")
            .keyboardShortcut(.cancelAction)
        }
    }
}
