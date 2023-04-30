import SwiftUI

struct 🗄️コマンド: Commands {
    @ObservedObject var 📱: 📱アプリモデル
    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("メニューを表示") { 📱.シートを表示 = .メニュー }
                .keyboardShortcut(",")
        }
        CommandMenu("ショートカット") {
            Button("一手だけ戻す") { 📱.一手戻す() }
                .keyboardShortcut("z", modifiers: [])
            Button("履歴を表示") { 📱.シートを表示 = .履歴 }
                .keyboardShortcut("y", modifiers: [])
                .disabled(局面モデル.履歴.isEmpty)
            Button("ブックマークを表示") { 📱.シートを表示 = .ブックマーク }
                .keyboardShortcut("d", modifiers: [])
            Button("編集を開始") { 📱.編集モードを開始する() }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(📱.編集中)
            Button("盤面を初期化") { 📱.盤面を初期化する() }
                .keyboardShortcut(.delete)
            Button("強調表示をクリア") { 📱.強調表示をクリア() }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
            Button("駒の選択を解除") { 📱.駒の選択を解除する() }
                .keyboardShortcut(.cancelAction)
                .disabled(📱.選択中の駒 == .なし)
        }
        CommandMenu("見た目") { Self.見た目コマンド() }
    }
    private struct 見た目コマンド: View {
        @AppStorage("上下反転") private var 上下反転: Bool = false
        @AppStorage("セリフ体") private var セリフ体: Bool = false
        @AppStorage("太字") private var 太字: Bool = false
        @AppStorage("サイズ") private var サイズ: フォント.サイズ = .標準
        @AppStorage("English表記") private var English表記: Bool = false
        @AppStorage("直近操作強調表示機能オフ") private var 直近操作強調オフ: Bool = false
        var body: some View {
            Toggle("上下反転", isOn: self.$上下反転)
            Toggle("セリフ体", isOn: self.$セリフ体)
            Toggle("太字", isOn: self.$太字)
            Picker("駒のサイズ", selection: self.$サイズ) {
                ForEach(フォント.サイズ.allCases) { Text($0.rawValue) }
            }
            Toggle("English表記", isOn: self.$English表記)
            Toggle("操作した直後の駒を強調表示を常に無効", isOn: self.$直近操作強調オフ)
        }
    }
    init(_ 📱: 📱アプリモデル) { self.📱 = 📱 }
}

enum 🗄️データ移行ver_1_3 {
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

enum 🗄️固定値 {
    static var 枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return 1.0
            case .pad:
#if targetEnvironment(macCatalyst)
                return 2
#else
                return 1.33
#endif
            case .tv: return 2
            default: return 1.0
        }
    }
    static var 全体パディング: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return 16
            case .pad:
#if targetEnvironment(macCatalyst)
                return 40
#else
                return 24
#endif
            case .tv: return 36
            default: return 16
        }
    }
}

struct 🗄️自動スリープ無効化: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task { UIApplication.shared.isIdleTimerDisabled = true }
    }
}

struct 🗄️初回起動時に駒の動かし方の説明バナー: ViewModifier {
    @AppStorage("起動回数") private var 起動回数: Int = 0
    @State private var 🚩バナーを表示: Bool = false
    func body(content: Content) -> some View {
        content
            .onAppear(perform: self.起動直後の確認作業)
            .overlay(alignment: .top) {
                if self.🚩バナーを表示 {
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる。",
                          systemImage: "hand.point.up.left")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding()
                    .onTapGesture { self.🚩バナーを表示 = false }
                }
            }
            .animation(.default.speed(0.33), value: self.🚩バナーを表示)
    }
    private func 起動直後の確認作業() {
        self.起動回数 += 1
        if self.起動回数 == 1 {
            self.🚩バナーを表示 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.🚩バナーを表示 = false
            }
        }
    }
}

enum 🗄️MacCatalyst {
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
    struct 微調整: ViewModifier {
        func body(content: Content) -> some View {
            content
#if targetEnvironment(macCatalyst)
                .onAppear {
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                        .titlebar?
                        .titleVisibility = .hidden
                }
                .padding(.bottom, 24)
#endif
        }
    }
    static func このアイテムはアプリ内でのドラッグ(_ ⓘtemProvider: NSItemProvider) -> Bool {
        ⓘtemProvider.hasRepresentationConforming(toTypeIdentifier: "com.apple.uikit.private.drag-item")
        //- MacではSuggestNameが利用不可っぽい。
        //- iOSと違いMac上ではregisteredTypeに"com.apple.uikit.private.drag-item"が追加されている。
        //- なので代わりにそれで判定。
    }
}

struct 💬RequestUserReview: ViewModifier {
    //@EnvironmentObject var 📱: 📱AppModel
    @State private var ⓒheckToRequest: Bool = false
    func body(content: Content) -> some View {
        content
            .modifier(💬PrepareToRequestUserReview(self.$ⓒheckToRequest))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    self.ⓒheckToRequest = true
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
