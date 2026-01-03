import Combine
import SwiftUI
#if os(iOS) || os(visionOS)
import GroupActivities
#endif

@MainActor
class アプリモデル: スーパークラス, ObservableObject {
    
    @Published var 局面: 局面モデル = .前回の局面 ?? .初期セット
    
    @AppStorage("English表記") var english表記: Bool = false
    @AppStorage("直近操作強調表示機能オフ") var 直近操作強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 上下反転: Bool = false
    @AppStorage("セリフ体") var セリフ体: Bool = false
    @AppStorage("太字") var 太字: Bool = false
    @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
    
    @Published var 表示中のシート: シートカテゴリ? = nil
    @Published var 成駒確認アラートを表示: Bool = false
    @Published var 増減モード中: Bool = false
    @Published var 選択中の駒: 駒の場所 = .なし
    
    let フィードバック: フィードバックモデル = .init()
    
    
    override init() {
        super.init()
        
        ICloudデータ.addObserver(
            self,
            #selector(self.iCloudによる外部からの履歴変更を適用する(_:))
        )
        
        ICloudデータ.synchronize()
    }
    
    
#if os(iOS) || os(visionOS)
    // ↓ ドラッグ&ドロップ関連
    @Published var ドラッグ中の駒: ドラッグ対象 = .無し
    
    // ↓ SharePlay関連
    var サブスクリプションズ = Set<AnyCancellable>()
    var タスクス = Set<Task<Void, Never>>()
    @Published var グループセッション: GroupSession<🄶roupActivity>?
    var セッションメッセンジャー: GroupSessionMessenger?
    @Published var 参加人数: Int?
#endif
    
    
#if os(visionOS)
    @AppStorage("暗転モード") var 暗転モード: Bool = false
    @Published var 駒を持ち上げたのは自分: Bool = false
#endif
}
