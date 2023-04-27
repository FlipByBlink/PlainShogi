import SwiftUI

struct 🚧フォントデバッグメニュー: View {
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    @AppStorage("太字") private var 太字: Bool = false
    @AppStorage("サイズ") private var サイズ: フォント.サイズ = .標準
    var body: some View {
        HStack {
            Toggle(isOn: self.$セリフ体) {
                Label("セリフ体", systemImage: "paintbrush.pointed")
            }
            .toggleStyle(.button)
            Toggle(isOn: self.$太字) {
                Label("太字", systemImage: "bold")
            }
            .toggleStyle(.button)
            Picker(selection: self.$サイズ) {
                ForEach(フォント.サイズ.allCases) { Text($0.rawValue) }
            } label: {
                Label("サイズ", systemImage: "magnifyingglass")
            }
            .pickerStyle(.segmented)
        }
        .font(.system(size: 10))
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
                return 32
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
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる。", systemImage: "hand.point.up.left")
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

struct 🗄️MacCatalystでタイトルバー非表示: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
#if targetEnvironment(macCatalyst)
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar?.titleVisibility = .hidden
#endif
            }
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
