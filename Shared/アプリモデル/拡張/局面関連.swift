import SwiftUI

extension アプリモデル {
    
    func この駒の表記(_ 場所: 駒の場所) -> String? {
        self.局面.この駒の表記(場所, self.english表記)
    }
    
    func 手駒増減メニューの駒の表記(_ 職名: 駒の種類, _ 陣営: 王側か玉側か) -> String {
        self.english表記 ? 職名.english生駒表記 : 職名.生駒表記(陣営)
    }
    
    func この駒のプレビュー表記(_ 場所: 駒の場所) -> String? {
        self.局面.この駒の職名表記(場所, self.english表記)
    }
    
    func この駒は操作直後なので強調表示(_ 場所: 駒の場所) -> Bool {
        (self.局面.直近の操作 == 場所) && !self.直近操作強調表示機能オフ
    }
    
    func この駒にはアンダーラインが必要(_ 場所: 駒の場所) -> Bool {
        self.局面.この駒にはアンダーラインが必要(場所, self.english表記)
    }
    
    func この駒は下向き(_ 場所: 駒の場所) -> Bool {
        (self.局面.この駒の陣営(場所) == .玉側) != self.上下反転
    }
    
    func こちら側のボタンは下向き(_ 陣営: 王側か玉側か) -> Bool {
        (陣営 == .玉側) != self.上下反転
    }
    
    func こちら側の陣営(_ 立場: 手前か対面か) -> 王側か玉側か {
        switch (立場, self.上下反転) {
            case (.手前, false): .王側
            case (.対面, false): .玉側
            case (.手前, true): .玉側
            case (.対面, true): .王側
        }
    }
    
    var 何も強調表示されていない: Bool {
        self.局面.直近の操作 == .なし && self.選択中の駒 == .なし
    }
    
    var 強調表示常時オフかつ駒が選択されていない: Bool {
        self.直近操作強調表示機能オフ && (self.選択中の駒 == .なし)
    }
    
    func 強調表示をクリア() {
        withAnimation {
            self.局面.直近操作情報を消す()
            self.選択中の駒の値を変更する(.なし)
        }
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.成功()
        self.表示中のシート = nil
    }
    
    func この駒を選択する(_ 今選択した場所: 駒の場所) {
        if !self.増減モード中 {
            switch self.選択中の駒 {
                case .なし:
                    if self.局面.ここに駒がある(今選択した場所) {
                        withAnimation(.default.speed(2.5)) {
                            self.選択中の駒の値を変更する(今選択した場所)
                        }
                        self.フィードバック.軽め()
                    }
                default:
                    if self.選択中の駒 == 今選択した場所 {
                        self.選択中の駒の値を変更する(.なし)
                    } else if self.局面.これとこれは同じ陣営(self.選択中の駒, 今選択した場所) {
                        self.選択中の駒の値を変更する(今選択した場所)
                        self.フィードバック.軽め()
                    } else {
                        switch 今選択した場所 {
                            case .盤駒(let 位置):
                                if !self.局面.ここからここへは移動不可(self.選択中の駒, .盤上(位置)) {
                                    self.盤上に駒を移動させる(.盤上(位置))
                                }
                            case .手駒(let 陣営, _):
                                self.こちらの手駒エリアを選択する(陣営)
                            default:
                                break
                        }
                    }
            }
        } else {
            switch 今選択した場所 {
                case .盤駒(_):
                    self.増減モードでこの盤駒を消す(今選択した場所)
                case .手駒(let 陣営, _):
                    self.表示中のシート = .手駒増減(陣営)
                    self.フィードバック.軽め()
                default:
                    break
            }
        }
    }
    
    func こちらの手駒エリアを選択する(_ 陣営: 王側か玉側か) {
        guard self.選択中の駒 != .なし else { return }
        withAnimation(.default.speed(2)) {
            if self.局面.ここからここへは移動不可(選択中の駒, .盤外(陣営)) {
                self.選択中の駒の値を変更する(.なし)
                self.フィードバック.軽め()
            } else {
                do {
                    try self.局面.駒を移動させる(選択中の駒, .盤外(陣営))
                    self.選択中の駒の値を変更する(.なし)
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    self.フィードバック.強め()
                } catch {
                    assertionFailure()
                }
            }
        }
    }
    
    func 今移動した駒を成る() {
        if case .盤駒(let 位置) = self.局面.直近の操作 {
            self.この駒を裏返す(位置)
        }
    }
    
    var 成駒確認メッセージ: String {
        var 値: String
        guard case .盤駒(let 位置) = self.局面.直近の操作,
              let 職名 = self.局面.盤駒[位置]?.職名 else { return "⚠︎" }
        if self.english表記 {
            値 = 職名.english生駒表記 + " → " + (職名.english成駒表記 ?? "⚠︎")
        } else {
            値 = 職名.rawValue + " → " + (職名.成駒表記 ?? "⚠︎")
        }
#if os(visionOS)
        if self.グループセッション?.state == .joined {
            値 += "\n" + String(localized: "(このダイアログは相手には見えていません)")
        }
#endif
        return 値
    }
    
    func 盤面を初期化する() {
        withAnimation { self.局面.初期化する() }
        self.選択中の駒の値を変更する(.なし)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.エラー()
        self.表示中のシート = nil
    }
    
    func 駒の選択を解除する() {
        self.選択中の駒の値を変更する(.なし)
    }
    
    func 増減モードを開始する() {
        self.増減モード中 = true
        self.フィードバック.成功()
        self.表示中のシート = nil
    }
    
    func 増減モードを終了する() {
        self.増減モード中 = false
        self.フィードバック.成功()
    }
    
    func 増減モードでこの手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        guard self.局面.増減モードでこの手駒を増やすことが出来る(陣営, 職名) else { return }
        self.局面.増減モードでこの手駒を一個増やす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.軽め()
    }
    
    func 増減モードでこの手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        guard self.局面.増減モードでこの手駒を減らすことが出来る(陣営, 職名) else { return }
        self.局面.増減モードでこの手駒を一個減らす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.軽め()
    }
    
    func 一手戻す() {
        guard let 一手前の局面 = self.局面.一手前の局面 else { return }
        self.選択中の駒の値を変更する(.なし)
        self.局面.現在の局面として適用する(一手前の局面)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.成功()
        self.表示中のシート = nil
    }
    
    func 選択中の駒を裏返す() {
        guard case .盤駒(let 位置) = self.選択中の駒 else { return }
        self.選択中の駒の値を変更する(.なし)
        self.この駒を裏返す(位置)
        self.表示中のシート = nil
    }
    
    private func 盤上に駒を移動させる(_ 移動先: 駒の移動先パターン) {
        withAnimation(.default.speed(2)) {
            do {
                try self.局面.駒を移動させる(self.選択中の駒, 移動先)
                self.SharePlay中なら現在の局面を参加者に送信する()
                self.駒移動後の成駒について対応する(self.選択中の駒, 移動先)
                self.選択中の駒の値を変更する(.なし)
                self.フィードバック.強め()
            } catch {
                assertionFailure()
            }
        }
    }
    
    func 駒移動後の成駒について対応する(_ 出発場所: 駒の場所, _ 置いた場所: 駒の移動先パターン) {
        if case .盤上(let 位置) = 置いた場所 {
            if self.局面.この駒移動で成る事が可能(.盤駒(位置), 出発場所) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.成駒確認アラートを表示 = true
                }
            }
        }
    }
    
    func 選択中の駒の値を変更する(_ 変更後の値: 駒の場所) {
        self.選択中の駒 = 変更後の値
        self.SharePlay中なら現在の選択中の駒を参加者に送信する()
#if os(visionOS)
        self.駒を持ち上げたのは自分 = (変更後の値 != .なし)
#endif
    }
    
    private func この駒を裏返す(_ 位置: Int) {
        if self.局面.この駒は成る事ができる(位置) {
            self.局面.この駒を裏返す(位置)
            self.SharePlay中なら現在の局面を参加者に送信する()
            self.フィードバック.強め()
        }
    }
    
    private func 増減モードでこの盤駒を消す(_ 場所: 駒の場所) {
        guard case .盤駒(let 位置) = 場所 else { return }
        withAnimation(.default.speed(2)) {
            self.局面.増減モードでこの盤駒を消す(位置)
        }
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.軽め()
    }
}
