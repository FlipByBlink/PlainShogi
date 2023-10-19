import SwiftUI

struct テキスト共有メニューコンポーネンツ: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Text(モデル.現在の盤面をテキストに変換する())
            .textSelection(.enabled)
            .padding()
        Button {
        } label: {
            Label("プレーンテキストとして「コピー」", systemImage: "doc.on.doc")
        }
        ShareLink(item: モデル.現在の盤面をテキストに変換する()) {
            Label("プレーンテキストとして「共有」", systemImage: "square.and.arrow.up")
        }
        Button {
            モデル.テキストを局面としてペースト()
            モデル.表示中のシート = nil
        } label: {
            Label("プレーンテキストを「貼り付け」して読み込む", systemImage: "doc.on.clipboard")
        }
        Button {
        } label: {
            Label("テキストファイルを書き出す", systemImage: "doc.plaintext")
        }
        //.fileExporter(isPresented: .constant(false),
        //              item: モデル.現在の盤面をテキストに変換する()) { result in
        //}
        Button {
        } label: {
            Label("テキストファイルを読み込む", systemImage: "doc.plaintext")
        }
        .fileImporter(isPresented: .constant(false),
                      allowedContentTypes: [.plainText]) { result in
        }
        ドラッグアンドドロップ共有メニューリンク()
    }
}

struct 画像共有メニューコンポーネンツ: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        if let 画像 = 画像書き出し.画像を取得() {
            画像
                .resizable()
                .frame(width: 240, height: 240)
                .shadow(radius: 3)
                .padding()
            Button {
            } label: {
                Label("画像を「共有」", systemImage: "square.and.arrow.up")
            }
            Button {
            } label: {
                Label("画像を「写真アプリに保存」", systemImage: "photo.badge.arrow.down")
            }
        }
    }
}
