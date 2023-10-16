import SwiftUI

struct 将棋View_tvOSApp: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            HStack {
                Spacer()
                盤外(.対面)
                Spacer()
                盤面と段と筋()
                Spacer()
                盤外(.手前)
                Spacer()
            }
            .modifier(成駒確認アラート())
            .modifier(駒選択を解除())
            .modifier(一時的にフォーカス効果を非表示())
            .modifier(レイアウト.推定())
            .modifier(アニメーション())
            .padding(64)
        }
        .ignoresSafeArea()
    }
}

private enum レイアウト {
    struct 推定: ViewModifier {
        func body(content: Content) -> some View {
            GeometryReader {
                content
                    .environment(\.マスの大きさ,
                                  $0.size.height / (9 + マスに対する段筋の大きさの比率))
            }
        }
    }
    static let マスに対する段筋の大きさの比率: Double = 0.5
    static let 複数個の盤外コマの幅比率: Double = 1.3
}

private struct 盤面と段と筋: View {
    @EnvironmentObject private var モデル: アプリモデル
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
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
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
                .zIndex(self.この行のマスにフォーカスがある(行) ? 1 : 0)
            }
        }
        .background {
            Color.clear
                .border(.primary, width: 3)
        }
        .frame(width: self.マスの大きさ * 9,
               height: self.マスの大きさ * 9)
    }
    private func この行のマスにフォーカスがある(_ 行: Int) -> Bool {
        let 本来の行 = モデル.上下反転 ? (8 - 行) : 行
        guard case .盤上(let 位置) = self.現在のフォーカス,
              case (本来の行 * 9) ..< (本来の行 * 9 + 9) = 位置 else { return false }
        return true
    }
}

private struct 盤上のコマもしくはマス: View {
    @EnvironmentObject private var モデル: アプリモデル
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    private var 画面上での左上からの位置: Int
    private var 元々の位置: Int {
        モデル.上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    private var 元々の場所: 駒の場所 { .盤駒(self.元々の位置) }
    private var ここに駒がある: Bool { モデル.局面.ここに駒がある(self.元々の場所) }
    private var 増減モード中かつここに駒がない: Bool { モデル.増減モード中 && !self.ここに駒がある }
    private var 通常モード中かつ駒非選択中かつここに駒がある: Bool {
        !モデル.増減モード中 && !self.ここに駒がある && (モデル.選択中の駒 == .なし)
    }
    private var この駒を選択中: Bool { モデル.選択中の駒 == self.元々の場所 }
    var body: some View {
        Color.clear
            .overlay {
                if self.ここに駒がある { コマの見た目(self.元々の場所) }
            }
            .overlay {
                フォーカス効果()
                    .opacity(self.この駒を選択中 ? 0.5 : 1)
                    .opacity(self.増減モード中かつここに駒がない ? 0.33 : 1)
                    .opacity(self.通常モード中かつ駒非選択中かつここに駒がある ? 0.33 : 1)
            }
            .overlay { 駒選択効果() }
            .focusable()
            .focusedValue(\.将棋盤フォーカス値, .盤上(self.元々の位置))
            .onTapGesture { モデル.この駒を選択する(self.元々の場所) }
            .zIndex(self.現在のフォーカス == .盤上(self.元々の位置) ? 1 : 0)
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

private struct 盤外: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    @FocusState private var 手駒郡フォーカス状態: Bool
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か { モデル.こちら側の陣営(self.立場) }
    private var 各駒: [駒の種類] {
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    private var 最大の長さ: CGFloat {
        self.マスの大きさ * (9 + レイアウト.マスに対する段筋の大きさの比率)
    }
    private var 揃え方: Alignment { self.立場 == .手前 ? .bottom : .top }
    private var 駒選択中かつ手駒なし: Bool {
        guard モデル.選択中の駒 != .なし else { return false }
        guard let 手駒 = モデル.局面.手駒[self.陣営] else { assertionFailure(); return false }
        return 手駒.配分.values.reduce(into: true) { if $1 > 0 { $0 = false } }
    }
    private var 盤駒か対面手駒を選択中: Bool {
        switch モデル.選択中の駒 {
            case .盤駒(_): return true
            case .手駒(let 陣営, _): return 陣営 != self.陣営
            case .なし: return false
        }
    }
    var body: some View {
        ZStack(alignment: self.揃え方) {
            Color.clear
                .overlay { フォーカス効果() }
                .overlay { 駒選択効果() }
                .zIndex(self.現在のフォーカス == .手駒エリア全体 ? 1 : 0)
                .focusable(self.駒選択中かつ手駒なし || self.盤駒か対面手駒を選択中)
                .focusedValue(\.将棋盤フォーカス値, .手駒エリア全体)
            VStack(spacing: 8) {
                if self.立場 == .対面 { 手駒増減シート表示ボタン(self.陣営) }
                ForEach(self.各駒) { 盤外のコマ(self.陣営, $0) }
                if self.立場 == .手前 { 手駒増減シート表示ボタン(self.陣営) }
            }
            .focused(self.$手駒郡フォーカス状態)
        }
        .frame(maxWidth: self.マスの大きさ * 1.5,
               maxHeight: self.最大の長さ)
        .focusSection()
        .onTapGesture {
            モデル.こちらの手駒エリアを選択する(self.陣営)
            self.手駒郡フォーカス状態 = true
        }
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か) { self.立場 = ﾀﾁﾊﾞ }
}

private struct 盤外のコマ: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    private var 数: Int { モデル.局面.この手駒の数(self.場所) }
    private var 幅比率: Double {
        self.数 >= 2 ? レイアウト.複数個の盤外コマの幅比率 : 1
    }
    private var フォーカス座標: FocusedValues.フォーカス対象? {
        guard case .手駒(let 陣営, let 職名) = 場所 else { return nil }
        return .手駒(陣営, 職名)
    }
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .frame(width: self.マスの大きさ * self.幅比率,
                       height: self.マスの大きさ)
                .overlay { フォーカス効果() }
                .overlay { 駒選択効果() }
                .focusable(!モデル.増減モード中)
                .focusedValue(\.将棋盤フォーカス値, self.フォーカス座標)
                .onTapGesture { self.モデル.この駒を選択する(self.場所) }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        self.場所 = .手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

private struct コマの見た目: View { //FrameやTap処理などは呼び出し側で実装する
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("太字") private var 太字オプション: Bool = false
    private var 場所: 駒の場所
    private var 表記: String? { モデル.この駒の表記(self.場所) }
    private var この駒を選択中: Bool { モデル.選択中の駒 == self.場所 }
    private var この駒は操作直後: Bool { モデル.この駒は操作直後なので強調表示(self.場所) }
    var body: some View {
        if let 表記 {
            ZStack {
                Color.clear
                テキスト(字: 表記,
                     強調: self.この駒は操作直後,
                     下線: モデル.この駒にはアンダーラインが必要(self.場所))
                .rotationEffect(モデル.この駒は下向き(self.場所) ? .degrees(180) : .zero)
                .rotationEffect(.degrees(モデル.増減モード中 ? 15 : 0))
                .foregroundStyle(self.この駒を選択中 ? .quaternary : .primary)
                .onChange(of: モデル.増減モード中) { _ in モデル.駒の選択を解除する() }
            }
            .animation(.default.speed(2), value: self.この駒を選択中)
            .modifier(増減モード用ⓧマーク(self.場所))
            .overlay {
                if self.太字オプション, self.この駒は操作直後 {
                    Rectangle().fill(.quaternary)
                }
            }
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

private struct フォーカス効果: View {
    @EnvironmentObject private var モデル: アプリモデル
    @EnvironmentObject private var フォーカス効果: フォーカス効果補助モデル
    @Environment(\.isFocused) private var isFocused
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    private var 無効: Bool {
        guard case .手駒(let 選択された陣営, _) = モデル.選択中の駒,
              case .手駒(let フォーカスされた陣営, _) = self.現在のフォーカス else { return false }
        return 選択された陣営 == フォーカスされた陣営
    }
    var body: some View {
        if self.isFocused, !self.無効, !フォーカス効果.一時的に非表示  {
            Color.clear
                .border(.primary, width: 3)
        }
    }
}

private class フォーカス効果補助モデル: ObservableObject {
    @Published var 一時的に非表示: Bool = false
}

private struct 一時的にフォーカス効果を非表示: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    @StateObject private var フォーカス効果 = フォーカス効果補助モデル()
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    func body(content: Content) -> some View {
        content
            .environmentObject(フォーカス効果)
            .onLongPressGesture {
                guard モデル.選択中の駒 == .なし else { return }
                withAnimation { フォーカス効果.一時的に非表示.toggle() }
            }
            .onChange(of: self.現在のフォーカス) { _ in フォーカス効果.一時的に非表示 = false }
    }
}

private struct 駒選択効果: View {
    @EnvironmentObject private var モデル: アプリモデル
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    @Environment(\.isFocused) private var isFocused
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 選択中の駒の場所: 駒の場所 { モデル.選択中の駒 }
    private var 表記: String? { モデル.この駒のプレビュー表記(self.選択中の駒の場所) }
    var body: some View {
        if self.isFocused, let 表記 {
            ZStack {
                Rectangle()
                    .foregroundStyle(.background)
                テキスト(字: 表記, 下線: モデル.この駒にはアンダーラインが必要(self.選択中の駒の場所))
                    .environment(\.マスの大きさ, self.マスの大きさ + 48)
                    .rotationEffect(モデル.この駒は下向き(self.選択中の駒の場所) ? .degrees(180) : .zero)
            }
            .frame(width: self.マスの大きさ + 24,
                   height: self.マスの大きさ + 24)
            .border(.blue, width: 5)
            .offset(x: self.現在のフォーカス == .手駒エリア全体 ? self.マスの大きさ : 0)
        }
    }
}

private struct 成駒確認アラート: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .alert("成りますか？", isPresented: $モデル.成駒確認アラートを表示) {
                Button("成る") { モデル.今移動した駒を成る() }
                Button("キャンセル", role: .cancel) { モデル.成駒確認アラートを表示 = false }
            } message: {
                Text(モデル.成駒確認メッセージ)
            }
    }
}

private struct 筋: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private static let 字 = ["９","８","７","６","５","４","３","２","１"]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(モデル.上下反転 ? Self.字.reversed() : Self.字, id: \.self) {
                テキスト(字: $0, 対象: .段筋)
                    .frame(width: self.マスの大きさ,
                           height: self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率)
            }
        }
        .zIndex(-1)
    }
}

private struct 段: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
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
        .zIndex(-1)
    }
}

private struct 駒選択を解除: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .onExitCommand(perform: モデル.選択中の駒 != .なし ? self.選択解除 : nil)
    }
    private func 選択解除() { モデル.駒の選択を解除する() }
}

private struct アニメーション: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    @AppStorage("太字") private var 太字: Bool = false
    @AppStorage("サイズ") private var サイズ: 字体.サイズ = .標準
    func body(content: Content) -> some View {
        content
            .animation(.default, value: モデル.english表記)
            .animation(.default, value: モデル.上下反転)
            .animation(.default, value: モデル.増減モード中)
            .animation(.default, value: self.太字)
            .animation(.default, value: self.サイズ)
    }
}

private struct テキスト: View {
    var 字: String
    var 対象: 字体.対象カテゴリ = .コマ
    var 強調: Bool = false
    var 下線: Bool = false
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("太字") private var 太字オプション: Bool = false
    @AppStorage("サイズ") private var サイズオプション: 字体.サイズ = .標準
    private var サイズポイント: CGFloat {
        self.マスの大きさ * self.サイズオプション.比率(self.対象)
    }
    private var 太字: Bool { self.強調 || self.太字オプション }
    var body: some View {
        Text(字体.装飾(self.字,
                     フォント: .system(size: self.サイズポイント,
                                   weight: self.太字 ? .bold : .regular),
                     下線: self.下線))
        .minimumScaleFactor(0.5)
    }
}

extension FocusedValues {
    var 将棋盤フォーカス値: Self.将棋盤フォーカスキー.Value? {
        get { self[Self.将棋盤フォーカスキー.self] }
        set { self[Self.将棋盤フォーカスキー.self] = newValue }
    }
    struct 将棋盤フォーカスキー: FocusedValueKey { typealias Value = フォーカス対象 }
    enum フォーカス対象: Equatable {
        case 盤上(_ 位置: Int)
        case 手駒(_ 陣営: 王側か玉側か, _ 職名: 駒の種類)
        case 手駒エリア全体
    }
    //@FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    //"focusable"の外側に"focusedValue(\.将棋盤フォーカス値, _)"を呼ぶ。
}
