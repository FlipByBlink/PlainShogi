import GroupActivities
import SwiftUI

struct 🄶roupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var 値 = GroupActivityMetadata()
        値.title = .init(localized: "将棋盤を共有")
        値.type = .generic
        値.previewImage = UIImage(named: "previewImage")!.cgImage
        値.supportsContinuationOnTV = false
        return 値
    }
}

extension 🄶roupActivity: Transferable {
    static func アクティビティを起動する() {
        Task {
            do {
                let アクティビティ = Self()
                switch await アクティビティ.prepareForActivation() {
                    case .activationPreferred:
                        print("アクティビティ.prepareForActivation: activationPreferred")
                        let 結果 = try await アクティビティ.activate()
                        if 結果 == false { throw Self.アクティビティエラー.activation失敗 }
                    case .activationDisabled:
                        print("アクティビティ.prepareForActivation: activationDisabled")
                    case .cancelled:
                        print("アクティビティ.prepareForActivation: cancelled")
                    @unknown default:
                        throw Self.アクティビティエラー.unknown
                }
            } catch {
                print("🚨 activation 失敗: \(error)")
                assertionFailure()
            }
        }
    }
    enum アクティビティエラー: Error {
        case activation失敗, unknown
    }
}
