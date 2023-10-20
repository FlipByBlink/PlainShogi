import SwiftUI

struct シート管理: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @EnvironmentObject var アプリ内課金: アプリ内課金モデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $モデル.表示中のシート) { カテゴリ in
                if case .広告 = カテゴリ {
                    広告コンテンツ()
                        .environmentObject(アプリ内課金)
                } else {
                    NavigationStack {
                        Group {
                            switch カテゴリ {
                                case .メニュー: メニュートップ()
                                case .履歴: 履歴メニュー()
                                case .ブックマーク: ブックマークメニュー()
                                case .手駒増減(let 陣営): 手駒増減メニュー(陣営)
                                case .SharePlayガイド: SharePlayガイドメニュー()
                                case .テキスト共有: Self.テキスト共有メニュー()
                                case .画像共有: Self.画像共有メニュー()
                                case .広告: Text(verbatim: "⚠︎")
                            }
                        }
                        .toolbar { self.閉じるボタン() }
                    }
                    .environmentObject(モデル)
                    .onAppear { フィードバック.軽め() }
                }
            }
    }
}

private extension シート管理 {
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
    private static func テキスト共有メニュー() -> some View {
        List {
            Section {
                テキスト共有メニューコンポーネンツ()
            } footer: {
                Text("先頭の文字が「☗」のテキストを読み込んでください")
            }
        }
        .navigationTitle("テキストとして共有")
    }
    private static func 画像共有メニュー() -> some View {
        List {
            画像共有メニューコンポーネンツ()
        }
        .navigationTitle("画像として共有")
    }
}
