import SwiftUI
import GroupActivities

struct SharePlay環境構築: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .animation(.default, value: self.groupStateObserver.isEligibleForGroupSession)
            .animation(.default, value: モデル.グループセッション?.state)
            .task { await モデル.新規GroupSessionを受信したら設定する() }
            .modifier(Self.参加完了通知バナー())
            .modifier(Self.SharePlay設定未完了ローディング())
    }
}

private extension SharePlay環境構築 {
    private struct SharePlay設定未完了ローディング: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            content
                .overlay {
                    if モデル.グループセッション != nil, モデル.局面.駒が1つも無い {
                        ProgressView()
                    }
                }
        }
    }
    private struct 参加完了通知バナー: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        @State private var 参加完了バナーを表示: Bool = false
        func body(content: Content) -> some View {
            content
                .onChange(of: モデル.グループセッション != nil) {
                    if $0 {
                        withAnimation(.default.speed(2)) {
                            self.参加完了バナーを表示 = true
                        }
                    }
                }
                .overlay {
                    if self.参加完了バナーを表示 {
                        Label("アクティビティに参加しました", systemImage: "checkmark")
                            .font(.headline)
                            .padding(12)
                            .border(.primary)
                            .background(.background)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.default.speed(0.33)) {
                                        self.参加完了バナーを表示 = false
                                    }
                                }
                            }
                    }
                }
        }
    }
}
