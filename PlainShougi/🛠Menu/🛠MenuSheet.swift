
import SwiftUI

struct 🛠MenuSheet: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    @AppStorage("English表記") var English表記: Bool = false
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("🌏駒を移動する", systemImage: "hand.draw")
                        .padding(.vertical, 8)
                    
                    Label("🌏駒を裏返す", systemImage: "rotate.right")
                        .padding(.vertical, 8)
                } header: {
                    Text("🌏あそび方")
                }
                .foregroundStyle(.primary)
                
                
                Button {
                    📱.はじめに戻す()
                    🔙.callAsFunction()
                } label: {
                    Label("🌏盤面を元に戻す", systemImage: "arrow.counterclockwise")
                }
                
                
                Section {
                    Toggle(isOn: $English表記) {
                        Label("🌏English表記に変更する", systemImage: "p.square")
                    }
                } header: {
                    Text("🌏オプション")
                }
                
                
                Section {
                    Group {
                        Label("🌏盤外の駒を削除する", systemImage: "trash")
                        
                        Label("🌏盤面を書き出す", systemImage: "square.and.arrow.up")
                        
                        Label("🌏盤面を読み込む", systemImage: "square.and.arrow.down")
                    }
                    .foregroundStyle(.secondary)
                } header: {
                    Text("🌏細かな使い方")
                }
                
                
                Section {
                    Text(📱.テキストに変換する())
                        .padding()
                        .accessibilityLabel("🌏プレーンテキスト")
                        .textSelection(.enabled)
                } header: {
                    Text("🌏テキスト書き出し例")
                }
                
                
                📣ADMenu()
                
                
                📄InformationMenu()
            }
            .navigationTitle("🌏Plain将棋盤")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        🔙.callAsFunction()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                            .grayscale(1.0)
                            .padding(8)
                    }
                    .accessibilityLabel("Dismiss") //"🌏閉じる"
                }
            }
        }
    }
}
