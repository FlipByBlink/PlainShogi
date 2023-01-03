import SwiftUI

struct 🛠盤面初期化ボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
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
    @EnvironmentObject var 📱: 📱AppModel
    var body: some View {
        Button {
            withAnimation { 📱.一般的な動作直後の強調表示をクリア() }
            振動フィードバック()
        } label: {
            Label("動作直後の強調表示をクリア", systemImage: "eraser.line.dashed")
        }
        .disabled(📱.一般的な動作直後の駒 == nil)
        .disabled(📱.🚩動作直後強調表示機能オフ)
    }
}

struct 🛠盤面整理開始ボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
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
    @EnvironmentObject var 📱: 📱AppModel
    var 位置: Int
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
    @EnvironmentObject var 📱: 📱AppModel
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
    @EnvironmentObject var 📱: 📱AppModel
    var 陣営: 王側か玉側か
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
    @EnvironmentObject var 📱: 📱AppModel
    @Environment(\.dismiss) var 🔙dismissAction: DismissAction
    var 陣営: 王側か玉側か
    var タイトル: String {
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




//MARK: WIP 作業中 未適用
struct ContentView_段筋付き: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 上下反転: Bool { 📱.🚩上下反転 }
    var body: some View {
        GeometryReader { 画面 in
            let マスの大きさ = min(画面.size.width / (9 + 0.5), 画面.size.height / (11 + 0.5))
            VStack(spacing: 0) {
                盤外(.対面, マスの大きさ)
                if !self.上下反転 { self.筋表記(マスの大きさ) }
                HStack(spacing: 0) {
                    if self.上下反転 { self.段表記(マスの大きさ) }
                    self.盤面(マスの大きさ)
                    if !self.上下反転 { self.段表記(マスの大きさ) }
                }
                if self.上下反転 { self.筋表記(マスの大きさ) }
                盤外(.手前, マスの大きさ)
            }
        }
        .padding()
    }
    func 盤面(_ マスの大きさ: CGFloat) -> some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(0 ..< 9) { 行 in
                HStack(spacing: 0) {
                    Divider()
                    ForEach(0 ..< 9) { 列 in
                        盤上のコマもしくはマス(行 * 9 + 列)
                        Divider()
                    }
                }
                Divider()
            }
        }
        .border(.primary)
        .frame(width: マスの大きさ * 9, height: マスの大きさ * 9)
    }
    func 筋表記(_ 盤のマスの大きさ: CGFloat) -> some View {
        HStack(spacing: 0) {
            let 字 = ["９","８","７","６","５","４","３","２","１"]
            //ForEach(1 ..< 10) { 列 in
            ForEach(self.上下反転 ? 字.reversed() : 字, id: \.self) { 列 in
                Text(列)
                    .minimumScaleFactor(0.1)
                    .font(.caption)
                    .padding(self.上下反転 ? .top : .bottom, 4)
                    .frame(width: 盤のマスの大きさ/2, height: 盤のマスの大きさ/2)
                    .padding(.horizontal, (盤のマスの大きさ/2)/2)
            }
        }
        .padding(self.上下反転 ? .leading : .trailing, 盤のマスの大きさ/2)
    }
    func 段表記(_ 盤のマスの大きさ: CGFloat) -> some View {
        VStack(spacing: 0) {
            let 字 = ["一","二","三","四","五","六","七","八","九"]
            ForEach(self.上下反転 ? 字.reversed() : 字, id: \.self) { 行 in
                Text(行.description)
                    .minimumScaleFactor(0.1)
                    .font(.caption)
                    .padding(self.上下反転 ? .trailing : .leading, 4)
                    .frame(width: 盤のマスの大きさ/2, height: 盤のマスの大きさ/2)
                    .padding(.vertical, (盤のマスの大きさ/2)/2)
            }
        }
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
