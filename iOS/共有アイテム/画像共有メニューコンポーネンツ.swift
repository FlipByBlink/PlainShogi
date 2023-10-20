import SwiftUI

struct 画像共有メニューコンポーネンツ: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        if let 画像 = 画像書き出し.画像を取得() {
            画像
                .resizable()
                .frame(width: 240, height: 240)
                .shadow(radius: 3)
                .padding()
            ShareLink(item: 画像,
                      preview: .init("盤面画像", icon: 画像)) {
                Label("共有", systemImage: "square.and.arrow.up")
            }
            Button {
                //TODO: 実装
            } label: {
                Label("写真アプリに保存", systemImage: "photo.badge.arrow.down")
            }
        }
    }
}
