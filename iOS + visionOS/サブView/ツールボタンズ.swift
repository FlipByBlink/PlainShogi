import SwiftUI

struct ツールボタンズ: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @State private var サムネイル: Image = .init(.aboutAppIcon)
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .overlay(alignment: .top) {
                HStack {
                    if Self.このデバイスはiPhone { self.共有ボタン() }
                    Spacer()
                    if Self.このデバイスはiPad { self.共有ボタン() }
                    if モデル.増減モード中 {
                        増減モード完了ボタン()
                    } else {
                        メニューボタン()
                    }
                }
                .animation(.default, value: モデル.増減モード中)
            }
#elseif os(visionOS)
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    if モデル.増減モード中 {
                        増減モード完了ボタン()
                    } else {
                        メニューボタン()
                    }
                    self.共有ボタン()
                }
            }
#endif
            .modifier(画像キャッシュハンドラー(self.$サムネイル))
    }
}

private extension ツールボタンズ {
    private func 共有ボタン() -> some View {
        Group {
            if !モデル.増減モード中 {
                メイン画面の共有ボタン(self.$サムネイル)
            }
        }
    }
    private static var このデバイスはiPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    private static var このデバイスはiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
