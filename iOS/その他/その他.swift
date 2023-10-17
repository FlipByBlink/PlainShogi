import SwiftUI

struct バックグラウンド時に駒選択を解除: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.scenePhase) var scenePhase
    func body(content: Content) -> some View {
        content
            .onChange(of: self.scenePhase) {
                if $0 == .background { モデル.駒の選択を解除する() }
            }
    }
}

struct 自動スリープ無効化: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task { UIApplication.shared.isIdleTimerDisabled = true }
    }
}

enum MacCatalyst調整 {
//    class Delegate: UIResponder, UIApplicationDelegate {
//#if targetEnvironment(macCatalyst)
//        override func buildMenu(with builder: UIMenuBuilder) {
//            builder.remove(menu: .services)
//            builder.remove(menu: .file)
//            builder.remove(menu: .edit)
//            builder.remove(menu: .format)
//            builder.remove(menu: .toolbar)
//            builder.remove(menu: .sidebar)
//            builder.remove(menu: .help)
//        }
//#endif
//    }
    struct TitleBar隠し: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
#if targetEnvironment(macCatalyst)
            content
                .padding(20)
                .onAppear {
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                        .titlebar?
                        .titleVisibility = .hidden
                }
                .ignoresSafeArea()
            //titlebarのheightは36?
#else
            content
#endif
        }
    }
    static func このアイテムはアプリ内でのドラッグ(_ itemProvider: NSItemProvider) -> Bool {
        itemProvider.hasRepresentationConforming(toTypeIdentifier: "com.apple.uikit.private.drag-item")
        //- MacではSuggestNameが利用不可っぽい。
        //- iOSと違いMac上ではregisteredTypeに"com.apple.uikit.private.drag-item"が追加されている。
        //- なので代わりにそれで判定。
    }
}
