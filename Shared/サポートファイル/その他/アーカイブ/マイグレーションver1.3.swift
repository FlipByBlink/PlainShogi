//MARK: アーカイブ「マイグレーションver1.3からver1.4」

enum データ移行ver_1_3 {
    static var ローカルのデータがある: Bool {
        UserDefaults.standard.data(forKey: "履歴") != nil
    }
    static func ローカルのデータを削除する() {
        UserDefaults.standard.removeObject(forKey: "履歴")
    }
    static func ローカルの直近の局面を読み込む() -> 局面モデル {
        guard let ローカルデータ = UserDefaults.standard.data(forKey: "履歴") else {
            return .初期セット
        }
        do {
            let ローカルの履歴 = try JSONDecoder().decode([局面モデル].self, from: ローカルデータ)
            guard let 対象局面 = ローカルの履歴.last else { assertionFailure(); return .初期セット }
            return 対象局面
        } catch {
            assertionFailure(); return .初期セット
        }
    }
}

//===================================================================

class アプリモデル: ObservableObject {
    init() {
        ICloudデータ.addObserver(self, #selector(self.iCloudによる外部からの履歴変更を適用する(_:)))
        ICloudデータ.synchronize()
    }
    private static func 起動時の局面を読み込む() -> 局面モデル {
#if os(iOS)
        if データ移行ver_1_3.ローカルのデータがある {
            let 前回の局面 = データ移行ver_1_3.ローカルの直近の局面を読み込む()
            前回の局面.ver_1_3_の局面を履歴に追加する()
            データ移行ver_1_3.ローカルのデータを削除する()
            return 前回の局面
        } else {
            return 局面モデル.前回の局面 ?? .初期セット
        }
#else
        局面モデル.前回の局面 ?? .初期セット
#endif
    }
}
