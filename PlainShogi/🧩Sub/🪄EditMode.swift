import SwiftUI

enum 編集モード: Equatable {
    case 盤面を編集中, 手駒を編集中(王側か玉側か)
}

struct 🪄手駒編集ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 陣営: 王側か玉側か
    @State private var 手駒シートを表示: Bool = false
    var body: some View {
        if 📱.編集状態 != nil {
            Button {
                self.手駒シートを表示 = true
                💥フィードバック.軽め()
            } label: {
                Image(systemName: "plusminus")
                    .font(.system(size: self.マスの大きさ * 0.4))
                    .padding(8)
            }
            .accessibilityLabel("手駒を整理する")
            .tint(.primary)
            .rotationEffect(📱.こちら側のボタンは下向き(self.陣営) ? .degrees(180) : .zero)
            .onChange(of: 📱.編集状態) {
                guard case .手駒を編集中(let 選択された陣営) = $0,
                      選択された陣営 == self.陣営 else { return }
                self.手駒シートを表示 = true
            }
            .sheet(isPresented: self.$手駒シートを表示) {
                手駒編集シート(self.陣営)
                    .onDisappear {
                        self.手駒シートを表示 = false
                        📱.編集状態 = .盤面を編集中
                    }
            }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

struct 🪄編集モード用ⓧマーク: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 場所: 駒の場所
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                if 📱.編集状態 != nil , case .盤駒(_) = 場所 {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.primary, .background)
                        .font(.body.weight(.light))
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
            withAnimation {
                📱.編集状態 = nil
                💥フィードバック.成功()
            }
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
