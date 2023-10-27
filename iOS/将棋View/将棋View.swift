import SwiftUI
import UniformTypeIdentifiers

struct 将棋View: View {
    var body: some View {
        盤と手駒を配置 {
            盤外(.対面)
            盤面と段と筋()
            盤外(.手前)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(操作エリア外で駒選択を解除())
        .modifier(成駒確認アラート())
        .modifier(レイアウト.推定())
        .modifier(オプション変更アニメーション())
    }
}

private struct 盤と手駒を配置<Content: View>: View {
    @Environment(\.縦並び) var 縦並び
    @ViewBuilder var content: () -> Content
    var body: some View {
        if self.縦並び {
            VStack(spacing: レイアウト.盤と手駒の隙間) { self.content() }
        } else {
            HStack(spacing: レイアウト.盤と手駒の隙間) { self.content() }
        }
    }
}

private struct 盤面と段と筋: View {
    @EnvironmentObject var モデル: アプリモデル
    private var 通常の向き: Bool { !モデル.上下反転 }
    var body: some View {
        if self.通常の向き {
            VStack(alignment: .leading, spacing: 0) {
                筋()
                HStack(spacing: 0) { 盤面のみ(); 段() }
            }
        } else {
            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: 0) { 段(); 盤面のみ() }
                筋()
            }
        }
    }
}

private struct 盤面のみ: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
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
        .border(.primary, width: self.枠線の太さ)
        .frame(width: self.マスの大きさ * 9,
               height: self.マスの大きさ * 9)
    }
    private var 枠線の太さ: CGFloat {
        switch self.マスの大きさ {
            case ..<50: 1
            case 50..<100: 1.5
            case 100...: 2
            default: 1
        }
    }
}

private struct 盤上のコマもしくはマス: View {
    @EnvironmentObject var モデル: アプリモデル
    private var 画面上での左上からの位置: Int
    private var 元々の位置: Int {
        モデル.上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    private var 元々の場所: 駒の場所 { .盤駒(self.元々の位置) }
    var body: some View {
        Group {
            if モデル.局面.ここに駒がある(self.元々の場所) {
                コマの見た目(self.元々の場所)
                    .onDrag { モデル.この駒をドラッグし始める(self.元々の場所) }
            } else { // ==== マス ====
                Color(.systemBackground)
            }
        }
        .onTapGesture { モデル.この駒を選択する(self.元々の場所) }
        .onDrop(of: [.utf8PlainText],
                delegate: ドロップデリゲート(モデル, .盤上(self.元々の位置)))
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

private struct 盤外: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    @Environment(\.縦並び) var 縦並び
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か { モデル.こちら側の陣営(self.立場) }
    private var 各駒: [駒の種類] {
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    private var 最大の長さ: CGFloat {
        self.マスの大きさ * (9 + レイアウト.マスに対する段筋の大きさの比率)
    }
    private var 揃え方: Alignment {
        switch (self.縦並び, self.立場) {
            case (true, .手前): .leading
            case (true, .対面): .trailing
            case (false, .手前): .bottom
            case (false, .対面): .top
        }
    }
    var body: some View {
        ZStack(alignment: self.揃え方) {
            Color(.systemBackground)
            Self.各種コマと増減ボタンの配置 {
                if self.立場 == .対面 { 手駒増減シート表示ボタン(self.陣営) }
                ForEach(self.各駒) { 盤外のコマ(self.陣営, $0) }
                if self.立場 == .手前 { 手駒増減シート表示ボタン(self.陣営) }
            }
        }
        .frame(maxWidth: self.最大の長さ, maxHeight: self.最大の長さ)
        .onTapGesture { モデル.こちらの手駒エリアを選択する(self.陣営) }
        .onDrop(of: [UTType.utf8PlainText],
                delegate: ドロップデリゲート(モデル, .盤外(self.陣営)))
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か) { self.立場 = ﾀﾁﾊﾞ }
    private struct 各種コマと増減ボタンの配置<Content: View>: View {
        @Environment(\.縦並び) var 縦並び
        @ViewBuilder var content: () -> Content
        var body: some View {
            if self.縦並び {
                HStack(spacing: 1.5) { self.content() }
                    .padding(.horizontal, 8)
            } else {
                VStack(spacing: 2) { self.content() }
                    .padding(.vertical, 8)
            }
        }
    }
}

private struct 盤外のコマ: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 場所: 駒の場所
    private var 数: Int { モデル.局面.この手駒の数(self.場所) }
    private var 幅比率: Double {
        self.数 >= 2 ? レイアウト.複数個の盤外コマの幅比率 : 1
    }
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .frame(width: self.マスの大きさ * self.幅比率,
                       height: self.マスの大きさ)
                .onTapGesture { self.モデル.この駒を選択する(self.場所) }
                .onDrag {
                    モデル.この駒をドラッグし始める(self.場所)
                } preview: {
                    self.プレビュー()
                }
        }
    }
    private func プレビュー() -> some View {
        手駒ドラッグプレビュー用コマ(モデル.この駒のプレビュー表記(self.場所) ?? "⚠︎",
                       self.マスの大きさ,
                       モデル.この駒は下向き(self.場所))
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        self.場所 = .手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

private struct コマの見た目: View { //FrameやDrag処理などは呼び出し側で実装する
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 場所: 駒の場所
    private var 表記: String? { モデル.この駒の表記(self.場所) }
    private var この駒を選択中: Bool { モデル.選択中の駒 == self.場所 }
    private var この駒は操作直後: Bool { モデル.この駒は操作直後なので強調表示(self.場所) }
    var body: some View {
        if let 表記 {
            ZStack {
                Color(.systemBackground)
                テキスト(字: 表記,
                     強調: self.この駒は操作直後,
                     下線: モデル.この駒にはアンダーラインが必要(self.場所))
                .rotationEffect(モデル.この駒は下向き(self.場所) ? .degrees(180) : .zero)
                .rotationEffect(.degrees(モデル.増減モード中 ? 15 : 0))
                .onChange(of: モデル.増減モード中) { _ in モデル.駒の選択を解除する() }
            }
            .border(.tint, width: self.この駒を選択中 ? 固定値.強調枠線の太さ : 0)
            .animation(.default.speed(2), value: self.この駒を選択中)
            .modifier(増減モード用ⓧマーク(self.場所))
            .modifier(ドラッグ直後の効果(self.場所))
            .overlay {
                if モデル.太字, self.この駒は操作直後 {
                    Rectangle().fill(.quaternary)
                }
            }
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

private struct 手駒ドラッグプレビュー用コマ: View {
    private var 表記: String
    private var コマの大きさ: CGFloat
    private var 上下反転: Bool
    var body: some View {
        ZStack {
            Color(.systemBackground)
            テキスト(字: self.表記,
                 対象: .プレビュー(self.コマの大きさ))
        }
        .frame(width: self.コマの大きさ, height: self.コマの大きさ)
        .rotationEffect(self.上下反転 ? .degrees(180) : .zero)
    }
    init(_ ﾋｮｳｷ: String, _ ｺﾏﾉｵｵｷｻ: CGFloat, _ ｼﾞｮｳｹﾞﾊﾝﾃﾝ: Bool) {
        (self.表記, self.コマの大きさ, self.上下反転) = (ﾋｮｳｷ, ｺﾏﾉｵｵｷｻ, ｼﾞｮｳｹﾞﾊﾝﾃﾝ)
    }
}

private struct 筋: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private static let 字 = ["９","８","７","６","５","４","３","２","１"]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(モデル.上下反転 ? Self.字.reversed() : Self.字, id: \.self) {
                テキスト(字: $0, 対象: .段筋)
                    .frame(width: self.マスの大きさ,
                           height: self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率)
            }
        }
    }
}

private struct 段: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 字: [String] {
        モデル.english表記 ? ["１","２","３","４","５","６","７","８","９"] : ["一","二","三","四","五","六","七","八","九"]
    }
    var body: some View {
        VStack(spacing: 0) {
            ForEach(モデル.上下反転 ? self.字.reversed() : self.字, id: \.self) {
                テキスト(字: $0, 対象: .段筋)
                    .frame(width: self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率,
                           height: self.マスの大きさ)
            }
        }
    }
}

private struct ドラッグ直後の効果: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    private var 場所: 駒の場所
    @State private var ドラッグした直後: Bool = false
    func body(content: Content) -> some View {
        content
            .opacity(self.ドラッグした直後 ? 0.25 : 1.0)
            .onChange(of: モデル.ドラッグ中の駒) {
                if case .アプリ内の駒(let 出発地点) = $0, 出発地点 == self.場所 {
                    self.ドラッグした直後 = true
                    withAnimation(.easeIn(duration: 1.25).delay(1)) {
                        self.ドラッグした直後 = false
                    }
                }
            }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

private struct テキスト: View {
    var 字: String
    var 対象: 字体.対象カテゴリ = .コマ
    var 強調: Bool = false
    var 下線: Bool = false
    @Environment(\.マスの大きさ) var マスの大きさ
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    @AppStorage("太字") private var 太字オプション: Bool = false
    @AppStorage("サイズ") private var サイズ: 字体.サイズ = .標準
    // ↑ ドラッグプレビューのためにEnvironmentObjectを避ける必要あり
    private var サイズポイント: CGFloat {
        switch self.対象 {
            case .コマ, .段筋: self.マスの大きさ * self.サイズ.比率(self.対象)
            case .プレビュー(let コマの大きさ): コマの大きさ * self.サイズ.比率(self.対象)
        }
    }
    private var 太字適用: Bool { self.強調 || self.太字オプション }
    var body: some View {
        Text(字体.装飾(self.字,
                   フォント: .system(size: self.サイズポイント,
                                 weight: self.太字適用 ? .bold : .regular,
                                 design: self.セリフ体 ? .serif : .default),
                   下線: self.下線))
        .minimumScaleFactor(0.5)
    }
}
