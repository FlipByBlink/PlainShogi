import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        VStack(spacing: 0) {
            将棋全体View()
            🛠SharePlayインジケーターやメニューボタン()
        }
        .padding()
        .overlay(alignment: .bottomTrailing) { 🛠非SharePlay時のメニューボタン() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .modifier(🛠メニューシート())
        .modifier(成駒確認アラート())
    }
}

private struct 将棋全体View: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private static let マスに対する段筋の大きさ: Double = 0.5
    private static let 盤上と盤外の隙間: CGFloat = 4
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private var 通常の向き: Bool { !self.上下反転 }
    var body: some View {
        GeometryReader { 画面 in
            let マスの大きさ = self.マスの大きさを計算(画面.size)
            let 筋 = 筋ラベル(幅: マスの大きさ * Self.マスに対する段筋の大きさ)
            let 段 = 段ラベル(高さ: マスの大きさ * Self.マスに対する段筋の大きさ)
            VStack(spacing: Self.盤上と盤外の隙間) {
                盤外(.対面, マスの大きさ)
                VStack(spacing: 0) {
                    if self.通常の向き { 筋 }
                    HStack(spacing: 0) {
                        if self.上下反転 { 段 }
                        盤面(マスの大きさ)
                        if self.通常の向き { 段 }
                    }
                    if self.上下反転 { 筋 }
                }
                盤外(.手前, マスの大きさ)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background {
            Color(uiColor: .systemBackground)
                .onTapGesture { 📱.選択中の駒 = .なし }
        }
    }
    private func マスの大きさを計算(_ 画面サイズ: CGSize) -> CGFloat {
        let 横基準 = 画面サイズ.width / (9 + Self.マスに対する段筋の大きさ)
        let 縦基準 = (画面サイズ.height - Self.盤上と盤外の隙間 * 2) / (11 + Self.マスに対する段筋の大きさ)
        return min(横基準, 縦基準)
    }
}

private struct 盤面: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private let マスの大きさ: CGFloat
    var body: some View {
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
        .border(.primary, width: 🗄️固定値.枠線の太さ)
        .frame(width: self.マスの大きさ * 9, height: self.マスの大きさ * 9)
        .clipped()
    }
    init(_ ﾏｽﾉｵｵｷｻ: CGFloat) {
        self.マスの大きさ = ﾏｽﾉｵｵｷｻ
    }
}

private struct 盤上のコマもしくはマス: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 画面上での左上からの位置: Int
    private var 元々の位置: Int {
        📱.🚩上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    private var 元々の場所: 駒の場所 { .盤駒(self.元々の位置) }
    var body: some View {
        Group {
            if 📱.局面.ここに駒がある(self.元々の場所) {
                コマの見た目(self.元々の場所)
                    .onDrag { 📱.この駒をドラッグし始める(self.元々の場所) }
            } else { // ==== マス ====
                Color(.systemBackground)
            }
        }
        .onTapGesture { 📱.この駒を選択する(self.元々の場所) }
        .onDrop(of: [.utf8PlainText],
                delegate: 📬DropDelegate(📱, .盤上(self.元々の位置)))
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

private struct 盤外: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か { 📱.こちら側の陣営(self.立場) }
    private var コマの大きさ: CGFloat
    var body: some View {
        ZStack(alignment: self.立場 == .手前 ? .leading : .trailing) {
            Color(.systemBackground)
            HStack(spacing: 0) {
                if self.立場 == .手前 { 手駒編集ボタン(self.陣営) }
                ForEach(self.立場 == .手前 ? 駒の種類.allCases : 駒の種類.allCases.reversed()) {
                    盤外のコマ(self.陣営, $0, self.コマの大きさ)
                }
                if self.立場 == .対面 { 手駒編集ボタン(self.陣営) }
            }
            .frame(height: self.コマの大きさ)
            .padding(.horizontal, 8)
        }
        .frame(width: self.コマの大きさ * 9.5)
        .onTapGesture { 📱.こちらの手駒エリアを選択する(self.陣営) }
        .onDrop(of: [UTType.utf8PlainText],
                delegate: 📬DropDelegate(📱, .盤外(self.陣営)))
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か, _ ｵｵｷｻ: CGFloat) {
        (self.立場, self.コマの大きさ) = (ﾀﾁﾊﾞ, ｵｵｷｻ)
    }
}

enum 手前か対面か {
    case 手前, 対面
}

private struct 盤外のコマ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 場所: 駒の場所
    private var コマの大きさ: CGFloat
    private var 数: Int { 📱.局面.この手駒の数(self.場所) }
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .frame(maxWidth: self.コマの大きさ * (self.数 >= 2 ? 1.4 : 1))
                .onTapGesture { self.📱.この駒を選択する(self.場所) }
                .onDrag {
                    📱.この駒をドラッグし始める(self.場所)
                } preview: {
                    ドラッグプレビュー用コマ(📱.この手駒のプレビュー表記(self.場所),
                                 self.コマの大きさ,
                                 📱.この駒は下向き(self.場所))
                }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類, _ ｺﾏﾉｵｵｷｻ: CGFloat) {
        (self.場所, self.コマの大きさ) = (.手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ), ｺﾏﾉｵｵｷｻ)
    }
}

private struct コマの見た目: View { //FrameやDrag処理などは呼び出し側で実装する
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    private var 場所: 駒の場所
    private var 表記: String? { 📱.この駒の表記(self.場所) }
    private var この駒を選択中: Bool { 📱.選択中の駒 == self.場所 }
    var body: some View {
        if let 表記 {
            ZStack {
                Color(.systemBackground)
                Text(表記)
                    .font(🗄️フォント.駒(self.セリフ体))
                    .fontWeight(📱.この駒は操作直後なので強調表示(self.場所) ? .bold : nil)
                    .underline(📱.この駒にはアンダーラインが必要(self.場所))
                    .minimumScaleFactor(0.1)
                    .rotationEffect(📱.この駒は下向き(self.場所) ? .degrees(180) : .zero)
                    .rotationEffect(.degrees(📱.🚩駒を整理中 ? 20 : 0))
                    .onChange(of: 📱.🚩駒を整理中) { _ in 📱.選択中の駒 = .なし }
            }
            .padding(.horizontal, 4)
            .border(.tint, width: self.この駒を選択中 ? 2 : 0)
            .animation(.default.speed(2), value: self.この駒を選択中)
            .modifier(編集モード用ⓧマーク(self.場所))
            .modifier(🗄️ドラッグ直後の効果(self.場所))
            .modifier(🗄️太字システムオプション用の強調表示(self.場所))
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

private struct 成駒確認アラート: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .alert("成りますか？", isPresented: $📱.🚩成駒確認アラートを表示) {
                Button("成る") { 📱.今移動した駒を成る() }
                Button("キャンセル", role: .cancel) { 📱.🚩成駒確認アラートを表示 = false }
            } message: {
                Text(📱.成駒確認メッセージ)
            }
    }
}

private struct ドラッグプレビュー用コマ: View {
    private var 表記: String
    private var コマの大きさ: CGFloat
    private var 上下反転: Bool
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    var body: some View {
        ZStack {
            Color(.systemBackground)
            Text(self.表記)
                .font(🗄️フォント.駒(self.セリフ体))
                .minimumScaleFactor(0.1)
        }
        .frame(width: self.コマの大きさ, height: self.コマの大きさ)
        .rotationEffect(self.上下反転 ? .degrees(180) : .zero)
    }
    init(_ ﾋｮｳｷ: String, _ ｺﾏﾉｵｵｷｻ: CGFloat, _ ｼﾞｮｳｹﾞﾊﾝﾃﾝ: Bool) {
        (self.表記, self.コマの大きさ, self.上下反転) = (ﾋｮｳｷ, ｺﾏﾉｵｵｷｻ, ｼﾞｮｳｹﾞﾊﾝﾃﾝ)
    }
}

private struct 筋ラベル: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    let 幅: CGFloat
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private static let 字 = ["９","８","７","６","５","４","３","２","１"]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(self.上下反転 ? Self.字.reversed() : Self.字, id: \.self) {
                Text($0)
                    .minimumScaleFactor(0.1)
                    .font(🗄️フォント.段と筋(self.セリフ体))
                    .padding(self.上下反転 ? .top : .bottom, 1)
                    .frame(width: self.幅, height: self.幅)
                    .padding(.horizontal, self.幅 / 2)
            }
        }
        .padding(self.上下反転 ? .leading : .trailing, self.幅)
    }
}

private struct 段ラベル: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    let 高さ: CGFloat
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private var 字: [String] {
        📱.🚩English表記 ? ["１","２","３","４","５","６","７","８","９"] : ["一","二","三","四","五","六","七","八","九"]
    }
    var body: some View {
        VStack(spacing: 0) {
            ForEach(self.上下反転 ? self.字.reversed() : self.字, id: \.self) {
                Text($0)
                    .minimumScaleFactor(0.1)
                    .font(🗄️フォント.段と筋(self.セリフ体))
                    .padding(self.上下反転 ? .trailing : .leading, 4)
                    .frame(width: self.高さ, height: self.高さ)
                    .padding(.vertical, self.高さ / 2)
            }
        }
    }
}
