
import SwiftUI

struct 🛠メニューボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        if 📱.🚩駒を整理中 {
            整理完了ボタン()
        } else {
            Menu {
                🛠盤面初期化ボタン()
                🛠盤面整理開始ボタン()
            } label: {
                Text("…")
                    .padding()
            } primaryAction: {
                📱.🚩メニューを表示 = true
                振動フィードバック()
            }
            .padding()
            .tint(.primary)
            .accessibilityLabel("Open menu")
        }
    }
}

struct 🛠AppMenu: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("長押しで駒を持ち上げ、そのままスライドさせて移動する", systemImage: "hand.draw")
                        .padding(.vertical, 8)
                    
                    Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                        .padding(.vertical, 8)
                } header: { Text("あそび方") }
                .foregroundStyle(.primary)
                
                Section {
                    Toggle(isOn: 📱.$🚩English表記) {
                        Label("English表記に変更する", systemImage: "p.square")
                    }
                } header: { Text("オプション") }
                
                Section {
                    🛠盤面初期化ボタン()
                    🛠盤面整理開始ボタン()
                }
                
                細かな使い方セクション()
                テキスト書き出し読み込みセクション()
                
                📣ADMenu()
                📄InformationMenu()
            }
            .navigationTitle("Plain将棋盤")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        📱.🚩メニューを表示 = false
                        振動フィードバック()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                            .grayscale(1.0)
                            .padding(8)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
        .onDisappear { 📱.🚩メニューを表示 = false }
    }
}


struct 細かな使い方セクション: View {
    var body: some View {
        NavigationLink {
            List {
                VStack {
                    Text("メニューボタン( … ←これ)を長押しすると「初期化ボタン」や「整理ボタン」を呼び出せます。")
                        .minimumScaleFactor(0.1)
                    
                    Image("MenuLongPress")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .border(.primary)
                        .padding()
                }
                .padding()
                
                Section {
                    HStack {
                        Text("DynamicTypeに対応しているので、OSの設定に合わせて駒の字の大きさを変えたり太文字にしたりできます。")
                        
                        VStack {
                            ForEach(DynamicTypeSize.allCases, id: \.self) { 📏 in
                                Text("歩")
                                    .dynamicTypeSize(📏)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("細かな使い方")
        } label: {
            Label("細かな使い方", systemImage: "magazine")
        }
    }
}


struct テキスト書き出し読み込みセクション: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        NavigationLink {
            List {
                Section {
                    Label("駒を他のアプリへドラッグして盤面をテキストとして書き出す", systemImage: "square.and.arrow.up")
                    テキスト書き出し読み込みプレビュー("TextExport", 画像の枚数: 3)
                }
                
                Section {
                    Label("他のアプリからテキストを盤上にドロップして盤面を読み込む", systemImage: "square.and.arrow.down")
                    テキスト書き出し読み込みプレビュー("TextImport", 画像の枚数: 5)
                }
                
                Section {
                    Text(📱.現在の盤面をテキストに変換する())
                        .padding()
                        .accessibilityLabel("テキスト")
                        .textSelection(.enabled)
                } header: {
                    Text("テキスト書き出し例")
                }
            }
            .navigationTitle("テキスト機能")
        } label: {
            Label("テキスト書き出し/読み込み機能", systemImage: "square.and.arrow.up.on.square")
        }
    }
}

//TODO: TimelineView検討
//TODO: Taskとかも検討
struct テキスト書き出し読み込みプレビュー: View {
    var NameSpace: String
    var 画像の枚数: Int
    @State private var 🏷FileName: Int = 0
    
    var body: some View {
        Image(NameSpace + "/" + 🏷FileName.description)
            .resizable()
            .scaledToFit()
            .cornerRadius(6)
            .onAppear {
                🏷FileName = 1
            }
            .onChange(of: 🏷FileName) { newValue in
                if newValue == 画像の枚数 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        🏷FileName = 1
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeInOut) {
                            🏷FileName += 1
                        }
                    }
                }
            }
            
    }
    
    init (_ NameSpace: String, 画像の枚数: Int) {
        self.NameSpace = NameSpace
        self.画像の枚数 = 画像の枚数
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        List {
            テキスト書き出し読み込みプレビュー("TextExport", 画像の枚数: 3)
            
            テキスト書き出し読み込みプレビュー("TextImport", 画像の枚数: 5)
        }
    }
}
