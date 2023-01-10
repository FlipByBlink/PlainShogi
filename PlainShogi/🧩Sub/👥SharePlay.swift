import Foundation
import GroupActivities
import UIKit
import SwiftUI

struct 🄶roupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var ⓜetadata = GroupActivityMetadata()
        ⓜetadata.title = NSLocalizedString("共有将棋盤", comment: "アクティビティタイトル")
        ⓜetadata.type = .generic
        ⓜetadata.previewImage = UIImage(systemName: "questionmark.square.dashed")!.cgImage
        return ⓜetadata
    }
    
    static func アクティビティを開始する() {
        Task {
            do {
                let ⓐctivity = Self()
                switch await ⓐctivity.prepareForActivation() {
                    case .activationPreferred:
                        print("ⓐctivity.prepareForActivation: activationPreferred")
                        let 結果 = try await ⓐctivity.activate()
                        if !結果 {
                            throw 🚨エラー.activation失敗
                        }
                    case .activationDisabled:
                        print("ⓐctivity.prepareForActivation: activationDisabled")
                    case .cancelled:
                        print("ⓐctivity.prepareForActivation: cancelled")
                    @unknown default:
                        throw 🚨エラー.unknown
                }
            } catch {
                print("🚨 activation 失敗: \(error)")
                assertionFailure()
            }
            enum 🚨エラー: Error {
                case activation失敗, unknown
            }
        }
    }
}

struct SharePlay開始誘導ボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    private var 🚩表示条件: Bool {
        self.ⓖroupStateObserver.isEligibleForGroupSession
        &&
        📱.ⓖroupSession == nil
    }
    var body: some View {
        if self.🚩表示条件 {
            Section {
                Button {
                    🄶roupActivity.アクティビティを開始する()
                } label: {
                    Label("SharePlayを開始する", systemImage: "shareplay")
                        .font(.body.weight(.semibold))
                        .padding(.vertical, 8)
                }
            } header: {
                Text("SharePlay")
            } footer: {
                Text("現在、友達と繋がっているようです。アクティビティを作成して、将棋盤を共有することができます。")
            }
        }
    }
}

struct SharePlay紹介リンク: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationLink {
            List {
                Section {
                    SharePlay開始誘導ボタン()
                }
                Section {
                    Text("SharePlayとは、、、")
                } header: {
                    Text("SharePlayとは")
                        .textCase(.none)
                }
                🅂haringControllerボタン()
                Section {
                    Text("placeholder")
                } header: {
                    Text("注意事項")
                }
            }
            .navigationTitle("SharePlayについて")
        } label: {
            Label("SharePlayについて", systemImage: "shareplay")
        }
    }
}

struct 🅂haringControllerボタン: View {
    @State private var 🚩SharingControllerを表示: Bool = false
    @State private var 🚩GroupActivity準備完了: Bool = false
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        Section {
            Button {
                🚩SharingControllerを表示 = true
            } label: {
                Label("友達に「FaceTime」で通話をかけるか、もしくは「メッセージ」で連絡する", systemImage: "person.badge.plus")
            }
            .disabled(self.ⓖroupStateObserver.isEligibleForGroupSession)
        } header: {
            Text("SharePlayの準備をする")
        }
        .sheet(isPresented: $🚩SharingControllerを表示) {
            🅂haringControllerView($🚩GroupActivity準備完了)
        }
        .onChange(of: ⓖroupStateObserver.isEligibleForGroupSession) { ⓝewValue in
            if ⓝewValue {
                if 🚩GroupActivity準備完了 {
                    🄶roupActivity.アクティビティを開始する()
                    🚩GroupActivity準備完了 = false
                }
            }
        }
    }
    struct 🅂haringControllerView: UIViewControllerRepresentable {
        private let ⓖroupActivitySharingController: GroupActivitySharingController
        @Binding var 🚩GroupActivity準備完了: Bool
        func makeUIViewController(context: Context) -> GroupActivitySharingController {
            Task {
                switch await self.ⓖroupActivitySharingController.result {
                    case .success:
                        print("🖨️ groupActivitySharingController.result: success")
                        self.🚩GroupActivity準備完了 = true
                    case .cancelled:
                        print("🖨️ groupActivitySharingController.result: cancelled")
                    @unknown default:
                        assertionFailure()
                }
            }
            return ⓖroupActivitySharingController
        }
        func updateUIViewController(_ ⓒontroller: GroupActivitySharingController, context: Context) {
            print("🖨️ updateUIViewController/context", context)
        }
        init?(_ 🚩GroupActivity準備完了: Binding<Bool>) {
            do {
                self.ⓖroupActivitySharingController = try GroupActivitySharingController(🄶roupActivity())
            } catch {
                print("🚨", #line, error.localizedDescription)
                return nil
            }
            self._🚩GroupActivity準備完了 = 🚩GroupActivity準備完了
        }
    }
}
