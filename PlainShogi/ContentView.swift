import SwiftUI
import UniformTypeIdentifiers

// MARK: 仕様
// 手前が「王」、対面が「玉」。

struct ContentView: View {
    var body: some View {
        GeometryReader { 画面 in
            let マスの大きさ = min(画面.size.width / 9, 画面.size.height / 11)
            VStack(spacing: 0) {
                盤外(.対面, マスの大きさ)
                VStack(spacing: 0) {
                    Divider()
                    ForEach( 0 ..< 9 ) { 行 in
                        HStack(spacing: 0) {
                            Divider()
                            ForEach( 0 ..< 9 ) { 列 in
                                盤上のコマもしくはマス(行 * 9 + 列)
                                Divider()
                            }
                        }
                        Divider()
                    }
                }
                .border(.primary)
                .frame(width: マスの大きさ * 9, height: マスの大きさ * 9)
                盤外(.手前, マスの大きさ)
            }
        }
        .padding()
    }
}

struct 盤上のコマもしくはマス: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var ドラッグ中 = false
    var 画面上での左上からの位置: Int
    var 元々の位置: Int {
        📱.🚩上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    var 表記: String { 📱.この盤上の駒の表記(self.元々の位置) }
    var body: some View {
        GeometryReader { 📐 in
            if let 駒 = 📱.局面.盤駒[元々の位置] {
                コマ(表記, self.$ドラッグ中)
                    .modifier(下向きに変える(駒.陣営, 📱.🚩上下反転))
                    .overlay { 駒を消すボタン(self.元々の位置) }
                    .onTapGesture(count: 2) { 📱.この駒を裏返す(self.元々の位置) }
                    .accessibilityHidden(true)
                    .onDrag {
                        振動フィードバック()
                        self.ドラッグ中 = true
                        return 📱.この盤上の駒をドラッグし始める(self.元々の位置)
                    } preview: {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(.background)
                            Text(表記)
                                .minimumScaleFactor(0.1)
                        }
                        .frame(width: 📐.size.height, height: 📐.size.height)
                        .modifier(下向きに変える(駒.陣営, 📱.🚩上下反転))
                    }
            } else { // ==== マス ====
                Rectangle()
                    .foregroundStyle(.background)
            }
        }
        .onDrop(of: [.utf8PlainText], delegate: 📬盤上ドロップ(📱, self.元々の位置))
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

struct 盤外: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 立場: 手前か対面か
    var 陣営: 王側か玉側か {
        switch (self.立場, 📱.🚩上下反転) {
            case (.手前, false): return .王側
            case (.対面, false): return .玉側
            case (.手前, true): return .玉側
            case (.対面, true): return .王側
        }
    }
    var コマの大きさ: CGFloat
    var 駒の並び順: [駒の種類] {
        self.立場 == .手前 ? 駒の種類.allCases : 駒の種類.allCases.reversed()
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            HStack(spacing: 0) {
                ForEach(self.駒の並び順) { 職名 in
                    盤外のコマ(self.陣営, 職名)
                }
            }
            .frame(height: self.コマの大きさ)
        }
        .onDrop(of: [UTType.utf8PlainText], delegate: 📬盤外ドロップ(📱, self.陣営))
        .overlay(alignment: self.立場 == .手前 ? .bottomLeading : .topTrailing) {
            手駒調整ボタン(self.陣営)
                .modifier(下向きに変える(self.陣営, 📱.🚩上下反転))
        }
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か, _ ｵｵｷｻ: CGFloat) {
        (self.立場, self.コマの大きさ) = (ﾀﾁﾊﾞ, ｵｵｷｻ)
    }
    enum 手前か対面か {
        case 手前, 対面
    }
}

struct 盤外のコマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var ドラッグ中 = false
    var 陣営: 王側か玉側か
    var 職名: 駒の種類
    var メタデータ: (駒の表記: String, 数: Int, 数の表記: String) {
        📱.この持ち駒のメタデータ(self.陣営, self.職名)
    }
    var body: some View {
        if self.メタデータ.数 == 0 {
            EmptyView()
        } else {
            GeometryReader { 📐 in
                HStack {
                    Spacer(minLength: 0)
                    コマ(self.メタデータ.駒の表記 + self.メタデータ.数の表記, self.$ドラッグ中)
                        .frame(maxWidth: 📐.size.height * (self.メタデータ.数>=2 ? 1.5:1))
                        .modifier(下向きに変える(self.陣営, 📱.🚩上下反転))
                        .onDrag{
                            振動フィードバック()
                            self.ドラッグ中 = true
                            return 📱.この持ち駒をドラッグし始める(self.陣営, self.職名)
                        } preview: {
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.background)
                                Text(self.メタデータ.駒の表記)
                                    .minimumScaleFactor(0.1)
                            }
                            .frame(width: 📐.size.height, height: 📐.size.height)
                            .modifier(下向きに変える(self.陣営, 📱.🚩上下反転))
                        }
                    Spacer(minLength: 0)
                }
            }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        (self.陣営, self.職名) = (ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

struct コマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 表記: String
    @Binding var ドラッグ中: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            Text(self.表記)
                .minimumScaleFactor(0.1)
                .opacity(self.ドラッグ中 ? 0.25 : 1.0)
                .rotationEffect(.degrees(📱.🚩駒を整理中 ? 20 : 0))
                .onChange(of: self.ドラッグ中) { ⓝewValue in
                    if ⓝewValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeIn(duration: 1.5)) {
                                self.ドラッグ中 = false
                            }
                        }
                    }
                }
        }
    }
    init(_ ﾋｮｳｷ: String, _ ドラッグ中: Binding<Bool>) {
        (self.表記, self._ドラッグ中) = (ﾋｮｳｷ, ドラッグ中)
    }
}

struct 下向きに変える: ViewModifier {
    var 陣営: 王側か玉側か
    var 上下反転: Bool
    var 🚩条件: Bool {
        (self.陣営 == .玉側) != 上下反転
    }
    func body(content: Content) -> some View {
        content
            .rotationEffect(self.🚩条件 ? .degrees(180) : .zero)
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼﾞｮｳｹﾞﾊﾝﾃﾝ: Bool) {
        (self.陣営, self.上下反転) = (ｼﾞﾝｴｲ, ｼﾞｮｳｹﾞﾊﾝﾃﾝ)
    }
}

func 振動フィードバック() {
    UISelectionFeedbackGenerator().selectionChanged()
}




struct ContentView_Previews: PreviewProvider {
    static let 📱 = 📱AppModel()
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 400, height: 400))
            .environmentObject(📱)
            .task {
                📱.局面.手駒[.王側]?.配分 = [.歩: 2, .角: 1]
                📱.局面.手駒[.玉側]?.配分 = [.歩: 1, .角: 1, .香: 1]
            }
        ContentView()
            .previewLayout(.fixed(width: 200, height: 300))
            .environmentObject(📱)
        ContentView()
            .previewLayout(.fixed(width: 400, height: 200))
            .environmentObject(📱)
    }
}
