import SwiftUI

struct 将棋View: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        VStack(spacing: レイアウト.盤と手駒の隙間) {
            盤外(.対面)
            盤面のみ()
            盤外(.手前)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(操作エリア外で駒選択を解除())
        .modifier(成駒確認アラート())
        .modifier(レイアウト.推定())
        .ignoresSafeArea()
        .modifier(アニメーション())
    }
}

//Apple Watch の画面比率は概ね9:11
private enum レイアウト {
    struct 推定: ViewModifier {
        func body(content: Content) -> some View {
            GeometryReader {
                content
                    .environment(\.マスの大きさ, レイアウト.マスの大きさを計算($0))
            }
        }
    }
    private static func マスの大きさを計算(_ ジオメトリ: GeometryProxy) -> CGFloat {
        let 横換算 = 一辺を基準にした際の計算式(全体の長さ: ジオメトリ.size.width,
                                盤外コマの比率: 0)
        let 縦換算 = 一辺を基準にした際の計算式(全体の長さ: ジオメトリ.size.height,
                                盤外コマの比率: 2)
        return min(横換算, 縦換算)
        func 一辺を基準にした際の計算式(全体の長さ: CGFloat, 盤外コマの比率: Double) -> CGFloat {
            (全体の長さ - Self.盤と手駒の隙間 * 2)
            / (9 + Self.マスに対する段筋の大きさの比率 + 盤外コマの比率)
        }
    }
    static let 盤と手駒の隙間: CGFloat = 4
    static let マスに対する段筋の大きさの比率: Double = 0 //0.5
    static let 複数個の盤外コマの幅比率: Double = 1.3
    struct マスの大きさKey: EnvironmentKey { static let defaultValue = 10.0 }
}

extension EnvironmentValues {
    var マスの大きさ: CGFloat {
        get { self[レイアウト.マスの大きさKey.self] }
        set { self[レイアウト.マスの大きさKey.self] = newValue }
    }
}

private struct 盤面のみ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                if 行 != 0 { Divider() }
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        if 列 != 0 { Divider() }
                        盤上のコマもしくはマス(行 * 9 + 列)
                    }
                }
            }
        }
        .border(.primary, width: 1)
        .frame(width: self.マスの大きさ * 9,
               height: self.マスの大きさ * 9)
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
            } else { // ==== マス ====
                Color.clear //?
                    .contentShape(Rectangle())
            }
        }
        .onTapGesture { 📱.この駒を選択する(self.元々の場所) }
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

private struct 盤外: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か { 📱.こちら側の陣営(self.立場) }
    private var 各駒: [駒の種類] {
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    private var 揃え方: Alignment {
        self.立場 == .手前 ? .leading : .trailing
    }
    var body: some View {
        //ZStack(alignment: self.揃え方) {
        ZStack(alignment: .center) {
            Color.clear //?
            HStack(spacing: 0) {
                ForEach(self.各駒) { 盤外のコマ(self.陣営, $0) }
            }
        }
        .frame(width:  self.マスの大きさ * 9,
               height: self.マスの大きさ)
        .contentShape(Rectangle())
        .onTapGesture { 📱.こちらの手駒エリアを選択する(self.陣営) }
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か) { self.立場 = ﾀﾁﾊﾞ }
}

private struct 盤外のコマ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    private var 数: Int { 📱.局面.この手駒の数(self.場所) }
    private var 幅比率: Double {
        self.数 >= 2 ? レイアウト.複数個の盤外コマの幅比率 : 1
    }
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .frame(width: self.マスの大きさ * self.幅比率,
                       height: self.マスの大きさ)
                .onTapGesture { self.📱.この駒を選択する(self.場所) }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        self.場所 = .手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

private struct コマの見た目: View { //操作処理などは呼び出し側で実装する
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("太字") private var 太字オプション: Bool = false
    private var 場所: 駒の場所
    private var 表記: String? { 📱.この駒の表記(self.場所) }
    private var この駒を選択中: Bool { 📱.選択中の駒 == self.場所 }
    private var この駒は操作直後: Bool { 📱.この駒は操作直後なので強調表示(self.場所) }
    var body: some View {
        if let 表記 {
            ZStack {
                Color.clear //?
                テキスト(字: 表記,
                     強調: self.この駒は操作直後,
                     下線: 📱.この駒にはアンダーラインが必要(self.場所))
                .rotationEffect(📱.この駒は下向き(self.場所) ? .degrees(180) : .zero)
                .rotationEffect(.degrees(📱.編集中 ? 15 : 0))
                .onChange(of: 📱.編集中) { _ in 📱.駒の選択を解除する() }
            }
            .contentShape(Rectangle())
            .border(.tint, width: self.この駒を選択中 ? 2 : 0)
            .animation(.default.speed(2), value: self.この駒を選択中)
            .modifier(🪄編集モード用ⓧマーク(self.場所))
            .overlay {
                if self.太字オプション, self.この駒は操作直後 {
                    Rectangle().fill(.quaternary)
                }
            }
        } else {
            Text("🐛")
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

private struct 成駒確認アラート: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .alert("成りますか？", isPresented: $📱.成駒確認アラートを表示) {
                Button("成る") { 📱.今移動した駒を成る() }
                Button("キャンセル", role: .cancel) { 📱.成駒確認アラートを表示 = false }
            } message: {
                Text(📱.成駒確認メッセージ)
            }
    }
}

private struct 操作エリア外で駒選択を解除: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .background {
                Color.clear //?
                    .onTapGesture { 📱.駒の選択を解除する() }
            }
    }
}

private struct アニメーション: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    @AppStorage("太字") private var 太字: Bool = false
    @AppStorage("サイズ") private var サイズ: 🔠フォント.サイズ = .標準
    func body(content: Content) -> some View {
        content
            .animation(.default, value: 📱.🚩English表記)
            .animation(.default, value: 📱.🚩上下反転)
            .animation(.default, value: 📱.編集中)
            .animation(.default, value: self.セリフ体)
            .animation(.default, value: self.太字)
            .animation(.default, value: self.サイズ)
    }
}

private struct テキスト: View {
    var 字: String
    var 対象: 🔠フォント.対象カテゴリ = .コマ
    var 強調: Bool = false
    var 下線: Bool = false
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    @AppStorage("太字") private var 太字オプション: Bool = false
    @AppStorage("サイズ") private var サイズオプション: 🔠フォント.サイズ = .標準
    private var サイズポイント: CGFloat {
        switch self.対象 {
            case .コマ, .段筋:
                return self.マスの大きさ * 1 //self.サイズオプション.比率(self.対象)
            case .プレビュー(let コマの大きさ):
                return コマの大きさ * 1 //self.サイズオプション.比率(self.対象)
        }
    }
    private var 太字: Bool { self.強調 || self.太字オプション }
    private var フォント: Font {
        .system(size: self.サイズポイント,
                weight: self.太字 ? .bold : .regular,
                design: self.セリフ体 ? .serif : .default)
    }
    private var 装飾文字: AttributedString {
        var 値 = AttributedString(stringLiteral: self.字)
        値.font = self.フォント
        if self.下線 { 値.underlineStyle = .single }
        値.languageIdentifier = "ja"
        return 値
    }
    var body: some View {
        Text(self.装飾文字)
            .minimumScaleFactor(0.5)
    }
}

private struct 🪄編集モード用ⓧマーク: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    @AppStorage("太字") private var 太字: Bool = false
    private var 編集中の盤上の駒: Bool {
        guard 📱.編集中, case .盤駒(_) = self.場所 else { return false }
        return true
    }
    func body(content: Content) -> some View {
        content
            .mask {
                if self.編集中の盤上の駒 {
                    Circle()
                        .padding(.trailing, self.マスの大きさ / 2)
                        .padding(.bottom, self.マスの大きさ / 2)
                        .background(Color.white)
                        .padding(2)
                        .compositingGroup()
                        .luminanceToAlpha()
                } else {
                    Rectangle()
                }
            }
            .overlay(alignment: .topLeading) {
                if self.編集中の盤上の駒 {
                    Image(systemName: "xmark")
                        .resizable()
                        .padding(self.マスの大きさ / 8)
                        .font(.body.weight(self.太字 ? .heavy : .semibold))
                        .frame(width: self.マスの大きさ / 2,
                               height: self.マスの大きさ / 2)
                }
            }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}
