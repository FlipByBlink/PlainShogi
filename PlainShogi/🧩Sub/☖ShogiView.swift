import SwiftUI
import UniformTypeIdentifiers

struct 将棋View: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
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
    }
}

private struct 盤と手駒を配置<Content: View>: View {
    @Environment(\.縦並び) private var 縦並び
    @ViewBuilder var content: () -> Content
    var body: some View {
        if self.縦並び {
            VStack(spacing: レイアウト.盤と手駒の隙間) { self.content() }
        } else {
            HStack(spacing: レイアウト.盤と手駒の隙間) { self.content() }
        }
    }
}

private enum レイアウト {
    struct 推定: ViewModifier {
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        private var 縦並び: Bool {
            self.verticalSizeClass == .regular
            &&
            self.horizontalSizeClass == .compact
        }
        func body(content: Content) -> some View {
            GeometryReader { 対象領域 in
                content
                    .environment(\.マスの大きさ, レイアウト.マスの大きさを算出(対象領域, self.縦並び))
                    .environment(\.縦並び, self.縦並び)
            }
        }
        //private func とても縦長(_ ジオメトリ: GeometryProxy) -> Bool {
        //    ジオメトリ.size.height > ジオメトリ.size.width * 2
        //}
    }
    private static func マスの大きさを算出(_ ジオメトリ: GeometryProxy, _ 縦並び: Bool) -> CGFloat {
        let 横換算 = 一辺を基準にした際の計算式(全体の長さ: ジオメトリ.size.width,
                                盤外コマの比率: 縦並び ? 0 : Self.複数個の盤外コマの幅比率 * 2)
        let 縦換算 = 一辺を基準にした際の計算式(全体の長さ: ジオメトリ.size.height,
                                盤外コマの比率: 縦並び ? 2 : 0)
        return min(横換算, 縦換算)
        func 一辺を基準にした際の計算式(全体の長さ: CGFloat, 盤外コマの比率: Double) -> CGFloat {
            (全体の長さ - Self.盤と手駒の隙間 * 2)
            / (9 + Self.マスに対する段筋の大きさの比率 + 盤外コマの比率)
        }
    }
    static let 盤と手駒の隙間: CGFloat = 4
    static let マスに対する段筋の大きさの比率: Double = 0.5
    static let 複数個の盤外コマの幅比率: Double = 1.3
    struct 縦並びKey: EnvironmentKey { static let defaultValue = false }
    struct マスの大きさKey: EnvironmentKey { static let defaultValue = 80.0 }
}

extension EnvironmentValues {
    var 縦並び: Bool {
        get { self[レイアウト.縦並びKey.self] }
        set { self[レイアウト.縦並びKey.self] = newValue }
    }
    var マスの大きさ: CGFloat {
        get { self[レイアウト.マスの大きさKey.self] }
        set { self[レイアウト.マスの大きさKey.self] = newValue }
    }
}

private struct 盤面と段と筋: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 通常の向き: Bool { !📱.🚩上下反転 }
    var body: some View {
        if self.通常の向き {
            VStack(spacing: 0) {
                筋()
                HStack(spacing: 0) {
                    盤面のみ()
                    段()
                }
            }
        } else {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    段()
                    盤面のみ()
                }
                筋()
            }
        }
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
        .border(.primary, width: 🗄️固定値.枠線の太さ)
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
    @Environment(\.マスの大きさ) private var マスの大きさ
    @Environment(\.縦並び) private var 縦並び
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か { 📱.こちら側の陣営(self.立場) }
    private var 各駒: [駒の種類] {
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    private var 最大の長さ: CGFloat {
        self.マスの大きさ * (9 + レイアウト.マスに対する段筋の大きさの比率)
    }
    private var 揃え方: Alignment {
        switch (self.縦並び, self.立場) {
            case (true, .手前): return .leading
            case (true, .対面): return .trailing
            case (false, .手前): return .bottom
            case (false, .対面): return .top
        }
    }
    var body: some View {
        ZStack(alignment: self.揃え方) {
            Color(.systemBackground)
            Self.各種コマと編集ボタンの配置 {
                if self.立場 == .手前 { 手駒編集ボタン(self.陣営) }
                ForEach(self.各駒) { 盤外のコマ(self.陣営, $0) }
                if self.立場 == .対面 { 手駒編集ボタン(self.陣営) }
            }
        }
        .frame(maxWidth: self.最大の長さ, maxHeight: self.最大の長さ)
        .onTapGesture { 📱.こちらの手駒エリアを選択する(self.陣営) }
        .onDrop(of: [UTType.utf8PlainText],
                delegate: 📬DropDelegate(📱, .盤外(self.陣営)))
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か) { self.立場 = ﾀﾁﾊﾞ }
    private struct 各種コマと編集ボタンの配置<Content: View>: View {
        @Environment(\.縦並び) private var 縦並び
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

enum 手前か対面か {
    case 手前, 対面
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
                .onDrag {
                    📱.この駒をドラッグし始める(self.場所)
                } preview: {
                    ドラッグプレビュー用コマ(📱.この手駒のプレビュー表記(self.場所),
                                 self.マスの大きさ,
                                 📱.この駒は下向き(self.場所))
                }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        self.場所 = .手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
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

private struct 筋: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    private var 幅: CGFloat { self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率 }
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

private struct 段: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    private var 高さ: CGFloat { self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率 }
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

private struct 操作エリア外で駒選択を解除: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .background {
                Color(uiColor: .systemBackground)
                    .onTapGesture { 📱.選択中の駒 = .なし }
            }
    }
}
