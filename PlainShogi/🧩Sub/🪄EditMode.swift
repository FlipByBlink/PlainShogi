import SwiftUI

struct 🪄手駒編集ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 陣営: 王側か玉側か
    @AppStorage("太字") private var 太字: Bool = false
    var body: some View {
        if 📱.編集中 {
            Button {
                📱.シートを表示 = .手駒編集(self.陣営)
            } label: {
                Image(systemName: "plusminus")
                    .font(.system(size: self.マスの大きさ * 0.45,
                                  weight: self.太字 ? .semibold : .light))
                    .padding(.horizontal, 12)
            }
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .rotationEffect(📱.こちら側のボタンは下向き(self.陣営) ? .degrees(180) : .zero)
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 🪄編集モード用ⓧマーク: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    @AppStorage("太字") private var 太字: Bool = false
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                if 📱.編集中, case .盤駒(_) = 場所 {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.primary, .background)
                        .font(.body.weight(self.太字 ? .medium : .light))
                        .minimumScaleFactor(0.1)
                        .padding(2)
                        .frame(width: self.マスの大きさ / 2,
                               height: self.マスの大きさ / 2)
                }
            }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

struct 🪄編集完了ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.編集中 = false }
            💥フィードバック.成功()
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                .padding(10)
        }
        .tint(.secondary)
        .accessibilityLabel("Done")
    }
}

struct 手駒編集メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    var body: some View {
        List {
            ForEach(駒の種類.allCases) { 職名 in
                Stepper {
                    HStack(spacing: 16) {
                        Text(📱.手駒編集シートの駒の表記(職名, self.陣営))
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
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}
