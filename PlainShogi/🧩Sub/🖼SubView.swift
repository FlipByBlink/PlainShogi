import SwiftUI

struct 駒を消すボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
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
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation {
                📱.🚩駒を整理中 = false
                💥フィードバック.成功()
            }
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                .padding(10)
        }
        .tint(.secondary)
        .accessibilityLabel("Done")
    }
}

struct 手駒編集ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    @State private var 手駒の数を編集中: Bool = false
    var body: some View {
        if 📱.🚩駒を整理中 {
            Button {
                self.手駒の数を編集中 = true
                💥フィードバック.軽め()
            } label: {
                Image(systemName: "plusminus")
                    .padding(8)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            }
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .modifier(コマの向きを調整(self.陣営, 📱.🚩上下反転))
            .sheet(isPresented: self.$手駒の数を編集中) {
                手駒編集シート(self.陣営)
                    .onDisappear { self.手駒の数を編集中 = false }
            }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

private struct 手駒編集シート: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.dismiss) private var dismiss
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
                        self.dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .grayscale(1)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct このコマが操作直後なら強調表示: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.legibilityWeight) private var legibilityWeight
    private let 画面上での左上からの位置: Int
    private var 🚩条件: Bool {
        📱.この盤駒は操作直後(self.画面上での左上からの位置)
        &&
        📱.🚩直近操作強調表示機能オフ == false
    }
    func body(content: Content) -> some View {
        if self.🚩条件 {
            switch self.legibilityWeight {
                case .bold:
                    content.border(.primary, width: 🗄️固定値.枠線の太さ)
                default:
                    content.font(🗄️固定値.駒フォント.bold())
            }
        } else {
            content
        }
    }
    init(_ ｶﾞﾒﾝｼﾞｮｳﾉｲﾁ: Int) {
        self.画面上での左上からの位置 = ｶﾞﾒﾝｼﾞｮｳﾉｲﾁ
    }
}

struct 筋View: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    let 幅: CGFloat
    private var 上下反転: Bool { 📱.🚩上下反転 }
    private let 字 = ["９","８","７","６","５","４","３","２","１"]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(self.上下反転 ? self.字.reversed() : self.字, id: \.self) {
                Text($0)
                    .minimumScaleFactor(0.1)
                    .font(🗄️固定値.段筋フォント)
                    .padding(self.上下反転 ? .top : .bottom, 1)
                    .frame(width: self.幅, height: self.幅)
                    .padding(.horizontal, self.幅 / 2)
            }
        }
        .padding(self.上下反転 ? .leading : .trailing, self.幅)
    }
}

struct 段View: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
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
                    .font(🗄️固定値.段筋フォント)
                    .padding(self.上下反転 ? .trailing : .leading, 4)
                    .frame(width: self.高さ, height: self.高さ)
                    .padding(.vertical, self.高さ / 2)
            }
        }
    }
}
