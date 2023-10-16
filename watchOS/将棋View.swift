import SwiftUI

struct 将棋View: View {
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            盤面のみ()
        }
        .modifier(レイアウト.推定())
        .modifier(成駒確認アラート())
        .modifier(アニメーション())
    }
}

//Apple Watch の画面比率は概ね9:11
private enum レイアウト {
    struct 推定: ViewModifier {
        func body(content: Content) -> some View {
            GeometryReader {
                content
                    .environment(\.マスの大きさ,
                                  min($0.size.width, $0.size.height) / 9)
            }
        }
    }
    static let 盤と手駒の隙間: CGFloat = 4
}

private struct 盤面のみ: View {
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
        .frame(width: self.マスの大きさ * 9,
               height: self.マスの大きさ * 9)
        .background {
            Rectangle()
                .strokeBorder(lineWidth: 1)
                .frame(width: self.マスの大きさ * 9 + 2,
                       height: self.マスの大きさ * 9 + 2)
        }
        .overlay(alignment: .top) {
            盤外(.対面)
                .alignmentGuide(.top) { _ in self.マスの大きさ + レイアウト.盤と手駒の隙間 }
        }
        .overlay(alignment: .bottom) {
            盤外(.手前)
                .alignmentGuide(.bottom) { _ in -レイアウト.盤と手駒の隙間 }
        }
    }
}

private struct 盤上のコマもしくはマス: View {
    @EnvironmentObject private var モデル: アプリモデル
    private var 画面上での左上からの位置: Int
    private var 元々の位置: Int {
        モデル.上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    private var 元々の場所: 駒の場所 { .盤駒(self.元々の位置) }
    var body: some View {
        Group {
            if モデル.局面.ここに駒がある(self.元々の場所) {
                コマの見た目(self.元々の場所)
            } else { // ==== マス ====
                Color.clear
                    .contentShape(Rectangle())
            }
        }
        .onTapGesture { モデル.この駒を選択する(self.元々の場所) }
    }
    init(_ 画面上での左上からの位置: Int) {
        self.画面上での左上からの位置 = 画面上での左上からの位置
    }
}

private struct 盤外: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 立場: 手前か対面か
    private var 陣営: 王側か玉側か { モデル.こちら側の陣営(self.立場) }
    private var 各駒: [駒の種類] {
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    private var 揃え方: Alignment {
        self.立場 == .手前 ? .trailing : .leading
    }
    var body: some View {
        ZStack(alignment: self.揃え方) {
            Color.clear
            HStack(spacing: 1) {
                if self.立場 == .対面 { 手駒増減シート表示ボタン(self.陣営) }
                ForEach(self.各駒) { 盤外のコマ(self.陣営, $0) }
                if self.立場 == .手前 { 手駒増減シート表示ボタン(self.陣営) }
            }
        }
        .frame(width:  self.マスの大きさ * 7, height: self.マスの大きさ)
        .contentShape(Rectangle())
        .onTapGesture { モデル.こちらの手駒エリアを選択する(self.陣営) }
        .padding(self.立場 == .手前 ? .leading : .trailing, self.マスの大きさ * 2)
        .overlay(alignment: .leading) { if self.立場 == .手前 { ツールボタン() } }
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か) { self.立場 = ﾀﾁﾊﾞ }
}

private struct 盤外のコマ: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    private var 数: Int { モデル.局面.この手駒の数(self.場所) }
    private var 自陣営の手駒の種類の数: Int {
        モデル.局面.この駒の陣営の手駒の種類の数(self.場所)
    }
    private var 幅比率: Double {
        switch self.自陣営の手駒の種類の数 {
            case 0 ..< 6:
                switch self.数 {
                    case 1: return 1
                    case 2...: return 1.15
                    default: assertionFailure(); return 1
                }
            case 6:
                switch self.数 {
                    case 1: return 0.9
                    case 2...: return 1.1
                    default: assertionFailure(); return 1
                }
            case 7, 8:
                switch self.数 {
                    case 1: return 0.7
                    case 2...: return 0.82
                    default: assertionFailure(); return 1
                }
            default:
                assertionFailure(); return 1
        }
    }
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .environment(\.マスの大きさ, self.マスの大きさ * self.幅比率)
                .frame(width: self.マスの大きさ * self.幅比率,
                       height: self.マスの大きさ)
                .onTapGesture { self.モデル.この駒を選択する(self.場所) }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        self.場所 = .手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

private struct コマの見た目: View { //操作処理などは呼び出し側で実装する
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
                .onChange(of: モデル.増減モード中) { _ in モデル.駒の選択を解除する() }
            }
            .contentShape(Rectangle())
            .border(.primary, width: self.この駒を選択中 ? 1.5 : 0)
            .animation(.default.speed(2), value: self.この駒を選択中)
            .modifier(増減モード用ⓧマーク(self.場所))
            .overlay {
                if self.太字オプション, self.この駒は操作直後 {
                    Rectangle().fill(.quaternary)
                }
            }
        } else {
            Text(verbatim: "BUG")
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
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

private struct アニメーション: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    @AppStorage("太字") private var 太字: Bool = false
    func body(content: Content) -> some View {
        content
            .animation(.default, value: モデル.english表記)
            .animation(.default, value: モデル.上下反転)
            .animation(.default, value: モデル.増減モード中)
            .animation(.default, value: self.太字)
    }
}

private struct テキスト: View {
    var 字: String
    var 強調: Bool = false
    var 下線: Bool = false
    @Environment(\.マスの大きさ) private var マスの大きさ
    @AppStorage("太字") private var 太字オプション: Bool = false
    private var サイズポイント: CGFloat { self.マスの大きさ * 0.75 }
    private var 太字: Bool { self.強調 || self.太字オプション }
    var body: some View {
        Text(字体.装飾(self.字,
                   フォント: .system(size: self.サイズポイント,
                                 weight: self.太字 ? .bold : .regular),
                   下線: self.下線))
        .minimumScaleFactor(0.6)
    }
}

private struct 増減モード用ⓧマーク: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    @AppStorage("太字") private var 太字: Bool = false
    private var 増減モード中の盤上の駒: Bool {
        guard モデル.増減モード中, case .盤駒(_) = self.場所 else { return false }
        return true
    }
    func body(content: Content) -> some View {
        content
            .mask {
                if self.増減モード中の盤上の駒 {
                    Circle()
                        .padding(.trailing, self.マスの大きさ / 2)
                        .padding(.bottom, self.マスの大きさ / 2)
                        .background(Color.white)
                        .compositingGroup()
                        .luminanceToAlpha()
                } else {
                    Rectangle()
                }
            }
            .overlay(alignment: .topLeading) {
                if self.増減モード中の盤上の駒 {
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

private struct 手駒増減シート表示ボタン: View {
    @EnvironmentObject private var モデル: アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 陣営: 王側か玉側か
    @AppStorage("太字") private var 太字: Bool = false
    var body: some View {
        if モデル.増減モード中 {
            Button {
                モデル.表示中のシート = .手駒増減(self.陣営)
            } label: {
                Image(systemName: "plusminus")
                    .font(.system(size: self.マスの大きさ * 0.8,
                                  weight: self.太字 ? .semibold : .regular))
                    .padding(.horizontal, 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .rotationEffect(モデル.こちら側のボタンは下向き(self.陣営) ? .degrees(180) : .zero)
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}
