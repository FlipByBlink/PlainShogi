import SwiftUI

struct 🛠盤面初期化ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.盤面を初期化する() }
            📱.🚩メニューを表示 = false
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
    }
}

struct 🛠移動直後強調表示クリアボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.盤駒の通常移動直後の強調表示をクリア() }
            振動フィードバック()
        } label: {
            Label("移動直後の強調表示をクリア", systemImage: "eraser.line.dashed")
        }
        .disabled(📱.盤駒の通常移動直後の駒 == nil)
        .disabled(📱.🚩移動直後強調表示機能オフ)
    }
}

struct 🛠盤面整理開始ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.🚩駒を整理中 = true }
            📱.🚩メニューを表示 = false
            振動フィードバック()
        } label: {
            Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
        }
    }
}

struct 駒を消すボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 位置: Int
    var body: some View {
        if 📱.🚩駒を整理中 {
            GeometryReader { 📐 in
                Button {
                    withAnimation {
                        📱.局面.盤駒.removeValue(forKey: self.位置)
                        振動フィードバック()
                    }
                } label: {
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, .background)
                            .tint(.primary)
                            .frame(width: 📐.size.width * 2/5,
                                   height: 📐.size.height * 2/5)
                    }
                }
            }
        }
    }
    init(_ ｲﾁ: Int) { self.位置 = ｲﾁ }
}

struct 整理完了ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation {
                📱.🚩駒を整理中 = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .padding(24)
        }
        .tint(.secondary)
        .accessibilityLabel("Done")
    }
}

struct 手駒調整ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    @State private var 手駒の数を増減中: Bool = false
    var body: some View {
        if 📱.🚩駒を整理中 {
            Button {
                self.手駒の数を増減中 = true
                振動フィードバック()
            } label: {
                Image(systemName: "plusminus")
                    .minimumScaleFactor(0.1)
                    .padding()
            }
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .sheet(isPresented: self.$手駒の数を増減中) {
                手駒調整シート(self.陣営)
                    .onDisappear { self.手駒の数を増減中 = false }
            }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 手駒調整シート: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @Environment(\.dismiss) var 🔙dismissAction: DismissAction
    private var 陣営: 王側か玉側か
    private var タイトル: String {
        switch (self.陣営, 📱.🚩English表記) {
            case (.王側, false): return "王側の手駒"
            case (.玉側, false): return "玉側の手駒"
            case (_, true): return "Pieces"
        }
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(駒の種類.allCases) { 職名 in
                    Stepper {
                        HStack(spacing: 16) {
                            Text(📱.この持ち駒のメタデータ(self.陣営, 職名).駒の表記)
                                .font(.title)
                            Text(📱.この持ち駒のメタデータ(self.陣営, 職名).数.description)
                                .font(.title3)
                                .monospacedDigit()
                        }
                        .padding(.leading)
                        .padding(.vertical, 8)
                    } onIncrement: {
                        📱.局面.手駒[self.陣営]?.一個増やす(職名)
                    } onDecrement: {
                        📱.局面.手駒[self.陣営]?.一個減らす(職名)
                    }
                    .padding(.trailing)
                }
            }
            .listStyle(.plain)
            .navigationTitle(self.タイトル)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.🔙dismissAction.callAsFunction()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 初回起動時に駒の動かし方の説明アラート: ViewModifier {
    @AppStorage("起動回数") var 起動回数: Int = 0
    @State private var 🚩説明アラートを表示: Bool = false
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.起動回数 += 1
                if self.起動回数 == 1 {
                    self.🚩説明アラートを表示 = true
                }
            }
            .alert("駒の動かし方", isPresented: self.$🚩説明アラートを表示) {
                Button("はじめる") {
                    self.🚩説明アラートを表示 = false
                    振動フィードバック()
                }
            } message: {
                Text("長押しして駒を持ち上げ、そのままスライドして移動させる。")
            }
    }
}

struct 移動直後の強調表示のためにこのマスを優先表示: ViewModifier {
    @EnvironmentObject var 📱: 📱アプリモデル
    private let 表示上の位置: Int
    private let マスの大きさ: CGFloat
    private var 🚩条件: Bool {
        let 元々の位置 = 📱.🚩上下反転 ? (80 - 表示上の位置) : 表示上の位置
        return 📱.盤駒の通常移動直後の駒?.盤上の位置 == 元々の位置
    }
    func body(content: Content) -> some View {
        content
            .overlay {
                if self.🚩条件 {
                    Rectangle()
                        .frame(width: マスの大きさ + 1, height: マスの大きさ + 1)
                        .foregroundColor(.clear)
                        .border(.primary, width: 1)
                }
            }
            .zIndex(self.🚩条件 ? 1 : 0)
    }
    init(_ ｲﾁ: Int, _ ﾏｽﾉｵｵｷｻ: CGFloat) {
        (self.表示上の位置, self.マスの大きさ) = (ｲﾁ, ﾏｽﾉｵｵｷｻ)
    }
}

struct 移動直後の強調表示のためにこの行を優先表示: ViewModifier {
    @EnvironmentObject var 📱: 📱アプリモデル
    private let 行: Int
    private var 🚩条件: Bool {
        if let 駒 = 📱.盤駒の通常移動直後の駒 {
            let 表示上の位置 = 📱.🚩上下反転 ? (80 - 駒.盤上の位置) : 駒.盤上の位置
            return 行 == 表示上の位置 / 9
        } else {
            return false
        }
    }
    func body(content: Content) -> some View {
        content
            .zIndex(self.🚩条件 ? 1 : 0)
    }
    init(_ ｷﾞｮｳ: Int) {
        self.行 = ｷﾞｮｳ
    }
}

//==== 一度実装したがリリース保留にした「移動直後の駒にマークを付ける機能」 ====
//struct 移動直後マーク: View {
//    @EnvironmentObject var 📱: 📱AppModel
//    var 位置: Int
//
//    var body: some View {
//        if 📱.🚩移動直後の駒にマークを付ける {
//            if 📱.移動直後の駒の位置 == 位置 {
//                GeometryReader { 📐 in
//                    ZStack(alignment: .bottomTrailing) {
//                        Color.clear
//
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .symbolRenderingMode(.palette)
//                            .foregroundStyle(.primary, .background)
//                            .frame(width: 📐.size.width * 1/3,
//                                   height: 📐.size.height * 1/3)
//                    }
//                }
//            }
//        }
//    }
//
//    init(_ ｲﾁ: Int) {
//        位置 = ｲﾁ
//    }
//}
//
//.overlay() { 移動直後マーク(位置) }
//
//@AppStorage("移動直後の駒にマークを付ける") var 🚩移動直後の駒にマークを付ける: Bool = false
//
//@Published var 移動直後の駒の位置: Int?
//
//Toggle(isOn: 📱.$🚩移動直後の駒にマークを付ける) {
//    Label("移動直後の駒にマークを付ける", systemImage: "app.badge.checkmark")
//}
//
//Text("移動直後の駒にマークを付いたマークは空白のマスをタップすることで一旦 非表示にすることができます。")
