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

struct SharePlayインジケーター: View {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    private var SharePlay中: Bool {
        [.waiting, .joined].contains(モデル.グループセッション?.state)
    }
    private var 参加人数: String { モデル.参加人数?.description ?? "0" }
    var body: some View {
        if self.groupStateObserver.isEligibleForGroupSession {
            Button {
                モデル.表示中のシート = .SharePlayガイド
            } label: {
                Group {
                    if self.SharePlay中 {
                        Label("現在、\(self.参加人数)人でSharePlay中", systemImage: "shareplay")
                            .animation(.default, value: self.参加人数)
                    } else {
                        Label("現在、SharePlayしていません", systemImage: "shareplay.slash")
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            }
            .accessibilityLabel("SharePlayメニュー")
            .modifier(Self.ボタンスタイル())
            .buttonBorderShape(.capsule)
            .padding(.top, 固定値.SharePlayインジケーター上部パディング)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .foregroundStyle(self.SharePlay中 ? .primary : .secondary)
        }
    }
    private struct ボタンスタイル: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            if モデル.グループセッション != nil {
                content
                    .buttonStyle(.automatic)
                    .font(.subheadline.weight(.light))
            } else {
                content
                    .buttonStyle(.bordered)
                    .font(.caption.weight(.light))
            }
        }
    }
}
