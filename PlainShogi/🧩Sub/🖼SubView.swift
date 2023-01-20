import SwiftUI

struct 🛠盤面初期化ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.盤面を初期化する() }
            📱.🚩メニューを表示 = false
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
    }
}

struct 🛠直近操作強調表示クリアボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.直近操作の強調表示をクリア() }
        } label: {
            Label("操作直後の強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(📱.局面.直近の操作 == .なし)
        .disabled(📱.🚩直近操作強調表示機能オフ)
    }
}

struct 🛠盤面整理開始ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
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

struct 🛠一手戻すボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 一手前の局面: 局面モデル? {
        局面モデル.履歴.last(where: { $0.更新日時 != 📱.局面.更新日時 })
    }
    var body: some View {
        if let 一手前の局面 {
            Button {
                📱.一手戻す(一手前の局面)
            } label: {
                Label("一手戻す", systemImage: "arrow.backward.to.line")
            }
        }
    }
}

struct 駒を消すボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 位置: Int
    var body: some View {
        if 📱.🚩駒を整理中 {
            GeometryReader { 📐 in
                Button {
                    withAnimation { 📱.編集モードでこの盤駒を消す(self.位置) }
                } label: {
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, .background)
                            .tint(.primary)
                            .font(.body.weight(.light))
                            .frame(width: 📐.size.width * 4 / 9,
                                   height: 📐.size.height * 4 / 9)
                    }
                }
            }
        }
    }
    init(_ ｲﾁ: Int) { self.位置 = ｲﾁ }
}

struct 整理完了ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
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

struct 手駒編集ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    @State private var 手駒の数を編集中: Bool = false
    var body: some View {
        if 📱.🚩駒を整理中 {
            Button {
                self.手駒の数を編集中 = true
                振動フィードバック()
            } label: {
                Image(systemName: "plusminus")
                    .minimumScaleFactor(0.1)
                    .padding()
            }
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .sheet(isPresented: self.$手駒の数を編集中) {
                手駒編集シート(self.陣営)
                    .onDisappear { self.手駒の数を編集中 = false }
            }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 手駒編集シート: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @Environment(\.dismiss) var 🔙dismissAction: DismissAction
    private var 陣営: 王側か玉側か
    var body: some View {
        NavigationView {
            List {
                ForEach(駒の種類.allCases) { 職名 in
                    Stepper {
                        HStack(spacing: 16) {
                            Text(📱.この手駒の表記(self.陣営, 職名))
                                .font(.title)
                            Text(📱.局面.この手駒の数(self.陣営, 職名).description)
                                .font(.title3)
                                .monospacedDigit()
                        }
                        .padding(.leading)
                        .padding(.vertical, 8)
                    } onIncrement: {
                        📱.編集モードでこの手駒を一個増やす(self.陣営, 職名)
                    } onDecrement: {
                        📱.編集モードでこの手駒を一個減らす(self.陣営, 職名)
                    }
                    .padding(.trailing)
                }
            }
            .listStyle(.plain)
            .navigationTitle(self.陣営 == .王側 ? "王側の手駒" : "玉側の手駒")
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
        .navigationViewStyle(.stack)
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 初回起動時に駒の動かし方の説明バナー: ViewModifier {
    @AppStorage("起動回数") var 起動回数: Int = 0
    @State private var 🚩駒操作説明バナーを表示: Bool = false
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.起動回数 += 1
                if self.起動回数 == 1 {
                    self.🚩駒操作説明バナーを表示 = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.🚩駒操作説明バナーを表示 = false
                    }
                }
            }
            .overlay(alignment: .top) {
                if self.🚩駒操作説明バナーを表示 {
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる。", systemImage: "hand.point.up.left")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding()
                        .onTapGesture {
                            self.🚩駒操作説明バナーを表示 = false
                        }
                }
            }
            .animation(.default.speed(0.33), value: self.🚩駒操作説明バナーを表示)
    }
}

struct このコマが操作直後なら強調表示: ViewModifier {
    @EnvironmentObject var 📱: 📱アプリモデル
    @Environment(\.legibilityWeight) var ⓛegibilityWeight
    private let 画面上での左上からの位置: Int
    private var 🚩条件: Bool {
        📱.この盤駒は操作直後(self.画面上での左上からの位置)
        &&
        📱.🚩直近操作強調表示機能オフ == false
    }
    func body(content: Content) -> some View {
        if self.🚩条件 {
            switch self.ⓛegibilityWeight {
                case .bold:
                    content.border(.primary, width: 枠線の太さ)
                default:
                    content.font(駒フォント.bold())
            }
        } else {
            content
        }
    }
    init(_ ｶﾞﾒﾝｼﾞｮｳﾉｲﾁ: Int) {
        self.画面上での左上からの位置 = ｶﾞﾒﾝｼﾞｮｳﾉｲﾁ
    }
}

var 枠線の太さ: CGFloat {
    switch UIDevice.current.userInterfaceIdiom {
        case .phone: return 1.0
        case .pad: return 1.33
        default: return 1.0
    }
}

struct 筋表示: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    let 幅: CGFloat
    private var 上下反転: Bool { 📱.🚩上下反転 }
    var body: some View {
        HStack(spacing: 0) {
            let 字 = ["９","８","７","６","５","４","３","２","１"]
            ForEach(self.上下反転 ? 字.reversed() : 字, id: \.self) { 列 in
                Text(列)
                    .minimumScaleFactor(0.1)
                    .font(段筋フォント)
                    .padding(self.上下反転 ? .top : .bottom, 1)
                    .frame(width: 幅, height: 幅)
                    .padding(.horizontal, 幅 / 2)
            }
        }
        .padding(self.上下反転 ? .leading : .trailing, 幅)
    }
}

struct 段表示: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    let 高さ: CGFloat
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private var 字: [String] {
        📱.🚩English表記 ? ["１","２","３","４","５","６","７","８","９"] : ["一","二","三","四","五","六","七","八","九"]
    }
    var body: some View {
        VStack(spacing: 0) {
            ForEach(self.上下反転 ? 字.reversed() : 字, id: \.self) { 行 in
                Text(行.description)
                    .minimumScaleFactor(0.1)
                    .font(段筋フォント)
                    .padding(self.上下反転 ? .trailing : .leading, 4)
                    .frame(width: 高さ, height: 高さ)
                    .padding(.vertical, 高さ / 2)
            }
        }
    }
}
