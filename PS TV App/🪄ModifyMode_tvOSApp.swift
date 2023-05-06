import SwiftUI

struct 🪄手駒増減シート表示ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 陣営: 王側か玉側か
    @AppStorage("太字") private var 太字: Bool = false
    var body: some View {
        if 📱.増減モード中 {
            Button {
                📱.シートを表示 = .手駒増減(self.陣営)
            } label: {
                Image(systemName: "plusminus")
                    .font(.system(size: self.マスの大きさ * 0.66,
                                  weight: self.太字 ? .semibold : .regular))
                    .padding(8)
                    .rotationEffect(📱.こちら側のボタンは下向き(self.陣営) ? .degrees(180) : .zero)
            }
            .padding(8)
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .buttonStyle(.plain)
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 🪄増減モード用ⓧマーク: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 場所: 駒の場所
    @AppStorage("太字") private var 太字: Bool = false
    private var 増減モード中の盤上の駒: Bool {
        guard 📱.増減モード中, case .盤駒(_) = self.場所 else { return false }
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
                        .padding(8)
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

struct 🪄増減モード完了ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        if 📱.増減モード中 {
            VStack {
                Spacer()
                Button {
                    withAnimation {
                        📱.増減モードを終了する()
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .focusSection()
        }
    }
}

struct 🪄手駒増減メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    var body: some View {
        NavigationStack {
            List {
                ForEach(駒の種類.allCases) { 職名 in
                    HStack {
                        Spacer()
                        Button {
                            📱.増減モードでこの手駒を一個減らす(self.陣営, 職名)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .imageScale(.small)
                        }
                        .buttonStyle(.plain)
                        HStack {
                            Text(📱.手駒増減メニューの駒の表記(職名, self.陣営))
                                .font(.title2.weight(.semibold))
                            Spacer(minLength: 0)
                            Text(📱.局面.この手駒の数(self.陣営, 職名).description)
                                .font(.title3.weight(.light))
                                .monospacedDigit()
                        }
                        .frame(width: 128)
                        .padding(.horizontal, 96)
                        Button {
                            📱.増減モードでこの手駒を一個増やす(self.陣営, 職名)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .imageScale(.small)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
            }
            .navigationTitle(self.陣営 == .王側 ? "王側の手駒" : "玉側の手駒")
        }
        .background {
            Rectangle()
                .foregroundStyle(.background)
                .ignoresSafeArea()
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}
