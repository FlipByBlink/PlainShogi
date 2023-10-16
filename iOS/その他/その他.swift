import SwiftUI
import GroupActivities

struct コマンド: Commands {
    @ObservedObject var モデル: アプリモデル
    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("メニューを表示") { モデル.表示中のシート = .メニュー }
                .keyboardShortcut(",")
                .disabled(モデル.表示中のシート == .広告)
        }
        CommandMenu("操作") {
            Group {
                Button("一手だけ戻す") { モデル.一手戻す() }
                    .keyboardShortcut("z", modifiers: [])
                Button("履歴を表示") { モデル.表示中のシート = .履歴 }
                    .keyboardShortcut("y", modifiers: [])
                    .disabled(局面モデル.履歴.isEmpty)
                Button("ブックマークを表示") { モデル.表示中のシート = .ブックマーク }
                    .keyboardShortcut("d", modifiers: [])
                Button("駒増減モードを開始") { モデル.増減モードを開始する() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(モデル.増減モード中)
                Button("盤面を初期化") { モデル.盤面を初期化する() }
                    .keyboardShortcut(.delete)
                Button("強調表示をクリア") { モデル.強調表示をクリア() }
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                Button("駒の選択を解除") { モデル.駒の選択を解除する() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(モデル.選択中の駒 == .なし)
                Button("テキストとしてコピー") { モデル.現在の局面をテキストとしてコピー() }
                    .keyboardShortcut("c", modifiers: [])
                Button("テキストを局面としてペースト") { モデル.テキストを局面としてペースト() }
                    .keyboardShortcut("v", modifiers: [])
                self.SharePlayメニューボタン()
            }
            .disabled(モデル.表示中のシート == .広告)
        }
        CommandMenu("見た目") { Self.見た目コマンド() }
    }
    @StateObject private var groupStateObserver = GroupStateObserver()
    private func SharePlayメニューボタン() -> some View {
        Button("SharePlayメニューを表示") { モデル.表示中のシート = .SharePlayガイド }
            .disabled(!self.groupStateObserver.isEligibleForGroupSession)
    }
    private struct 見た目コマンド: View {
        @AppStorage("上下反転") var 上下反転: Bool = false
        @AppStorage("セリフ体") var セリフ体: Bool = false
        @AppStorage("太字") var 太字: Bool = false
        @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
        @AppStorage("English表記") var english表記: Bool = false
        @AppStorage("直近操作強調表示機能オフ") var 直近操作強調オフ: Bool = false
        var body: some View {
            Toggle("上下反転", isOn: self.$上下反転)
            Toggle("セリフ体", isOn: self.$セリフ体)
            Toggle("太字", isOn: self.$太字)
            Picker("駒のサイズ", selection: self.$サイズ) {
                ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
            }
            Toggle("English表記", isOn: self.$english表記)
            Toggle("操作した直後の駒の強調表示を常に無効", isOn: self.$直近操作強調オフ)
        }
    }
    init(_ モデル: アプリモデル) { self.モデル = モデル }
}

enum データ移行ver_1_3 {
    static var ローカルのデータがある: Bool {
        UserDefaults.standard.data(forKey: "履歴") != nil
    }
    static func ローカルのデータを削除する() {
        UserDefaults.standard.removeObject(forKey: "履歴")
    }
    static func ローカルの直近の局面を読み込む() -> 局面モデル {
        guard let ローカルデータ = UserDefaults.standard.data(forKey: "履歴") else {
            return .初期セット
        }
        do {
            let ローカルの履歴 = try JSONDecoder().decode([局面モデル].self, from: ローカルデータ)
            guard let 対象局面 = ローカルの履歴.last else { assertionFailure(); return .初期セット }
            return 対象局面
        } catch {
            assertionFailure(); return .初期セット
        }
    }
}

enum 固定値 {
    static var 盤面枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 1.0
            case .pad:
#if targetEnvironment(macCatalyst)
                2.5
#else
                1.33
#endif
            default: 1.0
        }
    }
    static var 強調枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 2.0
            case .pad:
#if targetEnvironment(macCatalyst)
                3
#else
                2.5
#endif
            default: 1.0
        }
    }
    static var 全体パディング: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 16
            case .pad: 24
            default: 16
        }
    }
    static var SharePlayインジケーター上部パディング: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 12
            case .pad: 16
            default: 16
        }
    }
}

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
    class Delegate: UIResponder, UIApplicationDelegate {
#if targetEnvironment(macCatalyst)
        override func buildMenu(with builder: UIMenuBuilder) {
            builder.remove(menu: .services)
            builder.remove(menu: .file)
            builder.remove(menu: .edit)
            builder.remove(menu: .format)
            builder.remove(menu: .toolbar)
            builder.remove(menu: .sidebar)
            builder.remove(menu: .help)
        }
#endif
    }
    struct titleBar隠し: ViewModifier {
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

struct ユーザーレビュー依頼: ViewModifier {
    @State private var checkToRequest: Bool = false
    func body(content: Content) -> some View {
        content
            .modifier(💬PrepareToRequestUserReview(self.$checkToRequest))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    self.checkToRequest = true
                }
            }
    }
}

//struct データ管理_ver_1_2_2 {
//    static var 以前のデータがあるか: Bool {
//        UserDefaults.standard.dictionary(forKey: "駒の配置") != nil
//        &&
//        UserDefaults.standard.dictionary(forKey: "手駒") != nil
//    }
//    static func 以前のデータを削除する() {
//        UserDefaults.standard.removeObject(forKey: "駒の配置")
//        UserDefaults.standard.removeObject(forKey: "手駒")
//    }
//    static func 以前アプリ起動した際のログを読み込む() -> 局面モデル {
//        let 💾 = UserDefaults.standard
//        var 駒の配置: [Int: 盤上の駒] = [:]
//        var 手駒: [王側か玉側か: 持ち駒] = 空の手駒
//        if let 駒⃣の配置 = 💾.dictionary(forKey: "駒の配置") as? [String: [String]] {
//            if let 手⃣駒 = 💾.dictionary(forKey: "手駒") as? [String: [String: String]] {
//                駒⃣の配置.forEach { (位置テキスト: String, 駒テキスト: [String]) in
//                    if 駒テキスト.count != 3 { return }
//                    if let 陣営 = 王側か玉側か(rawValue: 駒テキスト[0]) {
//                        if let 職名 = 駒の種類(rawValue: 駒テキスト[1]) {
//                            if let 位置 = Int(位置テキスト) {
//                                if let 成り = Bool(駒テキスト[2]) {
//                                    駒の配置.updateValue(盤上の駒(陣営, 職名, 成り), forKey: 位置)
//                                } else {
//                                    駒の配置.updateValue(盤上の駒(陣営, 職名), forKey: 位置)
//                                }
//                            }
//                        }
//                    }
//                }
//                王側か玉側か.allCases.forEach { 陣営 in
//                    if let 手駒テキスト = 手⃣駒[陣営.rawValue] {
//                        手駒テキスト.forEach { (職名テキスト: String, 数テキスト: String) in
//                            if let 職名 = 駒の種類(rawValue: 職名テキスト) {
//                                if let 数 = Int(数テキスト) {
//                                    手駒[陣営]?.配分.updateValue(数, forKey: 職名)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        return 局面モデル(盤駒: 駒の配置, 手駒: 手駒)
//    }
//    static func 更新する(駒の配置: [Int: 盤上の駒], 手駒: [王側か玉側か: 持ち駒]) {
//        var 駒⃣の配置: [String: [String]] = [:]
//        var 手⃣駒: [String: [String: String]] = ["王側": [:], "玉側": [:]]
//        駒の配置.forEach { (位置: Int, 駒: 盤上の駒) in
//            駒⃣の配置.updateValue([駒.陣営.rawValue, 駒.職名.rawValue, 駒.成り.description], forKey: 位置.description)
//        }
//        王側か玉側か.allCases.forEach { 陣営 in
//            手駒[陣営]?.配分.forEach { (職名: 駒の種類, 数: Int) in
//                手⃣駒[陣営.rawValue]?[職名.rawValue] = 数.description
//            }
//        }
//        UserDefaults.standard.set(駒⃣の配置, forKey: "駒の配置")
//        UserDefaults.standard.set(手⃣駒, forKey: "手駒")
//    }
//}
