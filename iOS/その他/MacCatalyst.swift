import SwiftUI

#if targetEnvironment(macCatalyst)
extension アプリモデル {
    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .services)
        builder.remove(menu: .file)
        builder.remove(menu: .edit)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
        builder.remove(menu: .sidebar)
        builder.remove(menu: .help)
    }
}
#endif

enum MacCatalyst調整 {
    struct TitleBar隠し: ViewModifier {
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
