import SwiftUI

struct ブックマークメニュー: View {
    @EnvironmentObject var モデル: アプリモデル
    @State private var ブックマーク: 局面モデル? = nil
    private var 現在の局面とブックマークは同じ: Bool { モデル.局面 == self.ブックマーク }
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    if let ブックマーク {
                        局面プレビュー(ブックマーク)
                    } else {
                        局面プレビュー(.初期セット)
                            .foregroundStyle(.quaternary)
                    }
                    Button {
                        guard let ブックマーク else { return }
                        モデル.任意の局面を現在の局面として適用する(ブックマーク)
                    } label: {
                        Label("復元", systemImage: "square.and.arrow.down")
                            .font(.body.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                    .disabled(self.現在の局面とブックマークは同じ)
                    .disabled(self.ブックマーク == nil)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .contextMenu { self.デバッグ用削除ボタン() }
            }
            Section {
                Button {
                    withAnimation {
                        モデル.現在の局面をブックマークする()
                        self.ブックマーク = .ブックマークを読み込む()
                    }
                } label: {
                    Label("現在の局面をブックマーク", systemImage: "bookmark")
                        .font(.body.weight(.semibold))
                }
                .disabled(self.現在の局面とブックマークは同じ)
            }
            Label("ブックマークに保存できる局面は1つだけです", systemImage: "1.circle")
        }
        .navigationTitle("ブックマーク")
        .onAppear { self.ブックマーク = .ブックマークを読み込む() }
    }
    private func デバッグ用削除ボタン() -> some View {
        Button("削除") {
            ICloudデータ.remove(key: "ブックマーク")
            self.ブックマーク = nil
        }
    }
}
