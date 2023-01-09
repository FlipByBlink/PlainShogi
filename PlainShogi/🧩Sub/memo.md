
Error: 📦.loadItem
---------------------------------------------
> [Pasteboard] Could not retrieve data representation of type public.utf8-plain-text. Error: Error Domain=NSCocoaErrorDomain Code=4099 "The connection to service created from an endpoint was invalidated from this process." UserInfo={NSDebugDescription=The connection to service created from an endpoint was invalidated from this process.}
> Error Domain=NSItemProviderErrorDomain Code=-1000 "Data transfer has been cancelled." UserInfo={NSLocalizedDescription=Data transfer has been cancelled.}


Error: 📦.loadItem
---------------------------
> Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type public.text" UserInfo={NSLocalizedDescription=Cannot load representation of type public.text, NSUnderlyingError=0x283f97de0 {Error Domain=PBErrorDomain Code=0 "Cannot load representation of type public.utf8-plain-text" UserInfo={NSLocalizedDescription=Cannot load representation of type public.utf8-plain-text, NSUnderlyingError=0x283f945a0 {Error Domain=NSCocoaErrorDomain Code=4097 "connection to service with pid 68717 created from an endpoint" UserInfo={NSDebugDescription=connection to service with pid 68717 created from an endpoint}}}}}
 
 
MacOS(Desiened for iPad)で駒移動ができない不具合
--------------------------------------------------
> 2022-07-04 19:41:05.721240+0900 将棋盤[11108:591202] Cannot find representation conforming to type com.apple.UIKit.private.drag-suggested-name
> 2022-07-04 19:41:05.723046+0900 将棋盤[11108:591259] [DragAndDrop] UIDragging: dataForItemIndex:0 type:com.apple.UIKit.private.drag-suggested-name got error: Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type com.apple.UIKit.private.drag-suggested-name" UserInfo={NSLocalizedDescription=Cannot load representation of type com.apple.UIKit.private.drag-suggested-name}
> アプリ外部からのアイテムです


以前の駒の種類の実装。参考資料として一応残している
-------------------------------------------
//enum 駒の種類: String, CaseIterable, Identifiable {
//    case 歩
//    case 角
//    case 飛
//    case 香
//    case 桂
//    case 銀
//    case 金
//    case 王
//    case 玉
//
//    case と
//    case 馬
//    case 龍
//    case 杏 //成香
//    case 圭 //成桂
//    case 全 //成銀
//
//    var id: String { self.rawValue }
//
//    var 裏側: Self? {
//        switch self {
//        case .歩: return .と
//        case .と: return .歩
//        case .角: return .馬
//        case .馬: return .角
//        case .飛: return .龍
//        case .龍: return .飛
//        case .香: return .杏
//        case .杏: return .香
//        case .桂: return .圭
//        case .圭: return .桂
//        case .銀: return .全
//        case .全: return .銀
//        default: return nil
//        }
//    }
//
//    var 生駒: Self {
//        switch self {
//        case .と: return .歩
//        case .馬: return .角
//        case .龍: return .飛
//        case .杏: return .香
//        case .圭: return .桂
//        case .全: return .銀
//        default: return self
//        }
//    }
//
//    var English表記: String {
//        switch self {
//        case .歩: return "P"
//        case .と: return "+P"
//        case .角: return "B"
//        case .馬: return "+B"
//        case .飛: return "R"
//        case .龍: return "+R"
//        case .香: return "L"
//        case .杏: return "+L"
//        case .桂: return "N"
//        case .圭: return "+N"
//        case .銀: return "S"
//        case .全: return "+S"
//        case .金: return "G"
//        case .王: return "K"
//        case .玉: return "K"
//        }
//    }
//
//    var Englishプレーンテキスト: String {
//        switch self {
//        case .歩: return "Ｐ"
//        case .と: return "ｐ"
//        case .角: return "Ｂ"
//        case .馬: return "ｂ"
//        case .飛: return "Ｒ"
//        case .龍: return "ｒ"
//        case .香: return "Ｌ"
//        case .杏: return "ｌ"
//        case .桂: return "Ｎ"
//        case .圭: return "ｎ"
//        case .銀: return "Ｓ"
//        case .全: return "ｓ"
//        case .金: return "Ｇ"
//        case .王: return "Ｋ"
//        case .玉: return "Ｋ"
//        }
//    }
//}


一度実装したがリリース保留にした「移動直後の駒にマークを付ける機能」
--------------------------------------------------------
//struct 移動直後マーク: View {
//    @EnvironmentObject var 📱: 📱AppModel
//    var 位置: Int
//
//    var body: some View {
//        if 📱.🚩移動直後の駒にマークを付ける {
//            if 📱.移動直後の駒の位置 == 位置 {
//                GeometryReader { 📐 in
//                    ZStack(alignment: .bottomTrailing) {
//                        Color.clear
//
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .symbolRenderingMode(.palette)
//                            .foregroundStyle(.primary, .background)
//                            .frame(width: 📐.size.width * 1/3,
//                                   height: 📐.size.height * 1/3)
//                    }
//                }
//            }
//        }
//    }
//
//    init(_ ｲﾁ: Int) {
//        位置 = ｲﾁ
//    }
//}
//
//.overlay() { 移動直後マーク(位置) }
//
//@AppStorage("移動直後の駒にマークを付ける") var 🚩移動直後の駒にマークを付ける: Bool = false
//
//@Published var 移動直後の駒の位置: Int?
//
//Toggle(isOn: 📱.$🚩移動直後の駒にマークを付ける) {
//    Label("移動直後の駒にマークを付ける", systemImage: "app.badge.checkmark")
//}
//
//Text("移動直後の駒にマークを付いたマークは空白のマスをタップすることで一旦 非表示にすることができます。")
