import SwiftUI
import UniformTypeIdentifiers

// MARK: 仕様
// 手前が「王」、対面が「玉」。

struct ContentView: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private let マスに対する段筋の大きさ: Double = 0.5
    private let 盤上と盤外の隙間: CGFloat = 4
    var body: some View {
        GeometryReader { 画面 in
            let マスの大きさ = self.マスの大きさを計算(画面.size)
            VStack(spacing: self.盤上と盤外の隙間) {
                盤外(.対面, マスの大きさ)
                VStack(spacing: 0) {
                    if !self.上下反転 { self.筋表記(幅: マスの大きさ * self.マスに対する段筋の大きさ) }
                    HStack(spacing: 0) {
                        if self.上下反転 { self.段表記(高さ: マスの大きさ * self.マスに対する段筋の大きさ) }
                        self.盤面(マスの大きさ)
                        if !self.上下反転 { self.段表記(高さ: マスの大きさ * self.マスに対する段筋の大きさ) }
                    }
                    if self.上下反転 { self.筋表記(幅: マスの大きさ * self.マスに対する段筋の大きさ) }
                }
                盤外(.手前, マスの大きさ)
            }
        }
        .padding()
    }
    private func マスの大きさを計算(_ 画面サイズ: CGSize) -> CGFloat {
        let 横基準 = 画面サイズ.width / (9 + マスに対する段筋の大きさ)
        let 縦基準 = (画面サイズ.height - 盤上と盤外の隙間 * 2) / (11 + マスに対する段筋の大きさ)
        return min(横基準, 縦基準)
    }
    private func 盤面(_ マスの大きさ: CGFloat) -> some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(0 ..< 9) { 行 in
                HStack(spacing: 0) {
                    Divider()
                    ForEach(0 ..< 9) { 列 in
                        盤上のコマもしくはマス(行 * 9 + 列)
                            .modifier(移動直後の強調表示のためにこのマスを優先表示(行 * 9 + 列, マスの大きさ))
                        Divider()
                    }
                }
                .modifier(移動直後の強調表示のためにこの行を優先表示(行))
                Divider()
            }
        }
        .border(.primary)
        .frame(width: マスの大きさ * 9, height: マスの大きさ * 9)
        .clipped()
    }
    private func 筋表記(幅: CGFloat) -> some View {
        HStack(spacing: 0) {
            let 字 = ["９","８","７","６","５","４","３","２","１"]
            ForEach(self.上下反転 ? 字.reversed() : 字, id: \.self) { 列 in
                Text(列)
                    .minimumScaleFactor(0.1)
                    .font(.caption)
                    .padding(self.上下反転 ? .top : .bottom, 4)
                    .frame(width: 幅, height: 幅)
                    .padding(.horizontal, 幅/2)
            }
        }
        .padding(self.上下反転 ? .leading : .trailing, 幅)
    }
    private func 段表記(高さ: CGFloat) -> some View {
        VStack(spacing: 0) {
            let 字 = ["一","二","三","四","五","六","七","八","九"]
            ForEach(self.上下反転 ? 字.reversed() : 字, id: \.self) { 行 in
                Text(行.description)
                    .minimumScaleFactor(0.1)
                    .font(.caption)
                    .padding(self.上下反転 ? .trailing : .leading, 4)
                    .frame(width: 高さ, height: 高さ)
                    .padding(.vertical, 高さ/2)
            }
        }
    }
}

struct 盤上のコマもしくはマス: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @State private var ドラッグ中 = false
    @State private var 🚩成り駒ダイアログを表示: Bool = false
    private var 画面上での左上からの位置: Int
    private var 元々の位置: Int {
        📱.🚩上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    private var 表記: String { 📱.この盤上の駒の表記(self.元々の位置) }
    var body: some View {
        GeometryReader { 📐 in
            if let 駒 = 📱.局面.盤駒[元々の位置] {
                コマ(self.表記, self.$ドラッグ中)
                    .modifier(下向きに変える(駒.陣営, 📱.🚩上下反転))
                    .overlay { 駒を消すボタン(self.元々の位置) }
                    .onTapGesture(count: 2) { 📱.この駒を裏返す(self.元々の位置) }
                    .accessibilityHidden(true)
                    .onDrag {
                        振動フィードバック()
                        self.ドラッグ中 = true
                        return 📱.この盤上の駒をドラッグし始める(self.元々の位置)
                    } preview: {
                        ドラッグプレビュー用コマ(self.表記, 📐.size, 駒.陣営, 📱.🚩上下反転)
                    }
                    .confirmationDialog("この駒を成り駒にしますか？",
                                        isPresented: self.$🚩成り駒ダイアログを表示,
                                        titleVisibility: .visible) {
                        Button(role: .destructive) {
                            📱.この駒を裏返す(self.元々の位置)
                        } label: {
                            Text("成り駒にする")
                        }
                    }
            } else { // ==== マス ====
                Rectangle()
                    .foregroundStyle(.background)
            }
        }
        .onDrop(of: [.utf8PlainText], delegate: 📬盤上ドロップ(📱, self.元々の位置, self.$🚩成り駒ダイアログを表示))
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

struct 盤外: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か {
        switch (self.立場, 📱.🚩上下反転) {
            case (.手前, false): return .王側
            case (.対面, false): return .玉側
            case (.手前, true): return .玉側
            case (.対面, true): return .王側
        }
    }
    private var コマの大きさ: CGFloat
    private var 駒の並び順: [駒の種類] {
        self.立場 == .手前 ? 駒の種類.allCases : 駒の種類.allCases.reversed()
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            HStack(spacing: 0) {
                ForEach(self.駒の並び順) { 職名 in
                    盤外のコマ(self.陣営, 職名)
                        .frame(maxWidth: self.コマの大きさ * 3)
                }
            }
            .frame(height: self.コマの大きさ)
            .frame(maxWidth: self.コマの大きさ * 16)
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
    @EnvironmentObject var 📱: 📱アプリモデル
    @State private var ドラッグ中 = false
    private var 陣営: 王側か玉側か
    private var 職名: 駒の種類
    private var メタデータ: (駒の表記: String, 数: Int, 数の表記: String) {
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
                        .frame(maxWidth: 📐.size.height * (self.メタデータ.数 >= 2 ? 1.5 : 1))
                        .modifier(下向きに変える(self.陣営, 📱.🚩上下反転))
                        .onDrag{
                            振動フィードバック()
                            self.ドラッグ中 = true
                            return 📱.この持ち駒をドラッグし始める(self.陣営, self.職名)
                        } preview: {
                            ドラッグプレビュー用コマ(self.メタデータ.駒の表記, 📐.size, self.陣営, 📱.🚩上下反転)
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
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 表記: String
    @Binding private var ドラッグ中: Bool
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
    private var 陣営: 王側か玉側か
    private var 上下反転: Bool
    private var 🚩条件: Bool {
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

struct ドラッグプレビュー用コマ: View {
    private var 表記: String
    private var サイズ: CGSize
    private var 陣営: 王側か玉側か
    private var 上下反転: Bool
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            Text(self.表記)
                .minimumScaleFactor(0.1)
        }
        .frame(width: self.サイズ.height, height: self.サイズ.height)
        .modifier(下向きに変える(self.陣営, self.上下反転))
    }
    init(_ ﾋｮｳｷ: String, _ ｻｲｽﾞ: CGSize, _ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼﾞｮｳｹﾞﾊﾝﾃﾝ: Bool) {
        (self.表記, self.サイズ, self.陣営, self.上下反転) = (ﾋｮｳｷ, ｻｲｽﾞ, ｼﾞﾝｴｲ, ｼﾞｮｳｹﾞﾊﾝﾃﾝ)
    }
}

func 振動フィードバック() {
    UISelectionFeedbackGenerator().selectionChanged()
}




struct ContentView_Previews: PreviewProvider {
    static let 📱 = 📱アプリモデル()
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
