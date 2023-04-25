import SwiftUI
import UniformTypeIdentifiers

// MARK: 仕様
// 手前が「王」、対面が「玉」。

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
    private let マスに対する段筋の大きさ: Double = 0.5
    private let 盤上と盤外の隙間: CGFloat = 4
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private var 通常の向き: Bool { !self.上下反転 }
    var body: some View {
        GeometryReader { 画面 in
            let マスの大きさ = self.マスの大きさを計算(画面.size)
            let 筋 = 筋View(幅: マスの大きさ * self.マスに対する段筋の大きさ)
            let 段 = 段View(高さ: マスの大きさ * self.マスに対する段筋の大きさ)
            VStack(spacing: self.盤上と盤外の隙間) {
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
    }
    private func マスの大きさを計算(_ 画面サイズ: CGSize) -> CGFloat {
        let 横基準 = 画面サイズ.width / (9 + self.マスに対する段筋の大きさ)
        let 縦基準 = (画面サイズ.height - self.盤上と盤外の隙間 * 2) / (11 + self.マスに対する段筋の大きさ)
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
    private var 駒がある: Bool { 📱.局面.盤駒[self.元々の位置] != nil }
    var body: some View {
        Group {
            if self.駒がある {
                コマの見た目(self.元々の場所)
                    .overlay { 駒を消すボタン(self.元々の位置) }
                    .onTapGesture(count: 2) { 📱.この駒を裏返す(self.元々の位置) }
                    .accessibilityHidden(true)
                    .onDrag { 📱.この駒をドラッグし始める(self.元々の場所) }
            } else { // ==== マス ====
                Color(.systemBackground)
            }
        }
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
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    var body: some View {
        ZStack(alignment: self.立場 == .手前 ? .leading : .trailing) {
            Color(.systemBackground)
            HStack(spacing: 0) {
                if self.立場 == .手前 { 手駒編集ボタン(self.陣営) }
                ForEach(self.駒の並び順) { 職名 in
                    盤外のコマ(self.陣営, 職名, self.コマの大きさ)
                }
                if self.立場 == .対面 { 手駒編集ボタン(self.陣営) }
            }
            .frame(height: self.コマの大きさ)
            .padding(.horizontal, 8)
        }
        .frame(width: self.コマの大きさ * 9.5)
        .onDrop(of: [UTType.utf8PlainText],
                delegate: 📬DropDelegate(📱, .盤外(self.陣営)))
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か, _ ｵｵｷｻ: CGFloat) {
        (self.立場, self.コマの大きさ) = (ﾀﾁﾊﾞ, ｵｵｷｻ)
    }
    enum 手前か対面か {
        case 手前, 対面
    }
}

private struct 盤外のコマ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 場所: 駒の場所
    private var コマの大きさ: CGFloat
    private var 数: Int { 📱.局面.この手駒の数(self.場所) }
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .frame(width: self.コマの大きさ * (self.数 >= 2 ? 1.2 : 1))
                .onDrag {
                    📱.この駒をドラッグし始める(self.場所)
                } preview: {
                    ドラッグプレビュー用コマ(📱.この手駒のプレビュー表記(self.場所),
                                 self.コマの大きさ,
                                 📱.下向きに変更(self.場所))
                }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類, _ ｺﾏﾉｵｵｷｻ: CGFloat) {
        (self.場所, self.コマの大きさ) = (.手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ), ｺﾏﾉｵｵｷｻ)
    }
}

private struct コマの見た目: View { //FrameやDrag処理などは呼び出し側で実装する
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 場所: 駒の場所
    var body: some View {
        ZStack {
            Color(.systemBackground)
            Text(self.📱.この駒の表記(self.場所))
                .font(🗄️固定値.駒フォント)
                .fontWeight(self.📱.この駒は操作直後(self.場所) ? .bold : nil)
                .underline(self.📱.この駒にはアンダーラインが必要(self.場所))
                .minimumScaleFactor(0.1)
                .rotationEffect(📱.下向きに変更(self.場所) ? .degrees(180) : .zero)
                .rotationEffect(.degrees(📱.🚩駒を整理中 ? 20 : 0))
                .modifier(Self.ドラッグ直後の効果(self.場所))
                //.modifier(太文字システムオプションの際にこのコマが操作直後なら強調表示(self.場所))
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
    private struct ドラッグ直後の効果: ViewModifier {
        @EnvironmentObject private var 📱: 📱アプリモデル
        private var 場所: 駒の場所
        @State private var ドラッグした直後: Bool = false
        func body(content: Content) -> some View {
            content
                .opacity(self.ドラッグした直後 ? 0.25 : 1.0)
                .onChange(of: 📱.ドラッグ中の駒) {
                    switch $0 {
                        case .アプリ内の駒(let 出発地点):
                            if 出発地点 == self.場所 {
                                self.ドラッグした直後 = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation(.easeIn(duration: 1.5)) {
                                        self.ドラッグした直後 = false
                                    }
                                }
                            }
                        default:
                            break
                    }
                }
        }
        init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
    }
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
    var body: some View {
        ZStack {
            Color(.systemBackground)
            Text(self.表記)
                .font(🗄️固定値.駒フォント)
                .minimumScaleFactor(0.1)
        }
        .frame(width: self.コマの大きさ, height: self.コマの大きさ)
        .rotationEffect(self.上下反転 ? .degrees(180) : .zero)
    }
    init(_ ﾋｮｳｷ: String, _ ｺﾏﾉｵｵｷｻ: CGFloat, _ ｼﾞｮｳｹﾞﾊﾝﾃﾝ: Bool) {
        (self.表記, self.コマの大きさ, self.上下反転) = (ﾋｮｳｷ, ｺﾏﾉｵｵｷｻ, ｼﾞｮｳｹﾞﾊﾝﾃﾝ)
    }
}
