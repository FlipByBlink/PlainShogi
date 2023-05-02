import SwiftUI

struct 🛠OptionMenu: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("オプション", systemImage: "gearshape")
        }
    }
   private struct メニュー: View {
       @EnvironmentObject private var 📱: 📱アプリモデル
       @AppStorage("セリフ体") private var セリフ体: Bool = false
       @AppStorage("太字") private var 太字: Bool = false
        var body: some View {
            List {
                Toggle(isOn: $📱.🚩上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                Toggle(isOn: self.$セリフ体) { //watchOSは日本語Serifフォント非対応っぽい
                    Label("セリフ体", systemImage: "paintbrush.pointed")
                        .font(.system(.body, design: .serif))
                }
                Toggle(isOn: self.$太字) {
                    Label("太字", systemImage: "bold")
                        .font(.body.bold())
                }
                Toggle(isOn: $📱.🚩English表記) {
                    Label("English表記", systemImage: "p.circle")
                }
                Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                    Label("操作した直後の駒の強調表示を常に無効",
                          systemImage: "square.slash")
                }
            }
            .navigationTitle("オプション")
        }
    }
}
