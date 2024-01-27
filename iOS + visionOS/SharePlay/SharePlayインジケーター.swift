import SwiftUI
import GroupActivities

enum SharePlayインジケーター {
    struct IOS: View {
        var body: some View {
#if os(iOS)
            SharePlayインジケーター.ボタン()
#else
            EmptyView()
#endif
        }
    }
    struct VisionOS: View {
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
#if os(visionOS)
            if モデル.グループセッション?.state == .joined {
                SharePlayインジケーター.ボタン()
            }
#else
            EmptyView()
#endif
        }
    }
}

private extension SharePlayインジケーター {
    private struct ボタン: View {
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
                            Label("SharePlayできます", systemImage: "shareplay")
                        }
                    }
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                }
                .accessibilityLabel("SharePlayメニュー")
#if os(iOS)
                .modifier(SharePlayインジケーター.ボタンスタイル())
                .buttonBorderShape(.capsule)
                .padding(.top, 固定値.SharePlayインジケーター上部パディング)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .foregroundStyle(self.SharePlay中 ? .primary : .secondary)
#endif
            }
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
