
import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { 📐 in
            VStack {
                Spacer()
                
                盤外(陣営: .玉側)
                    .frame(height: マスのサイズ(📐))
                    .padding(4)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    ForEach( 0 ..< 9 ) { 行 in
                        HStack(spacing: 0) {
                            Divider()
                            
                            ForEach( 0 ..< 9 ) { 列 in
                                マス(位置: 行 * 9 + 列)
                                
                                Divider()
                            }
                        }
                        
                        Divider()
                    }
                }
                .border(.primary)
                .frame(width: マスのサイズ(📐) * 9,
                       height: マスのサイズ(📐) * 9)
                
                盤外(陣営: .王側)
                    .frame(height: マスのサイズ(📐))
                    .padding(4)
                
                Spacer()
            }
        }
        .padding(16)
    }
    
    func マスのサイズ(_ 📐: GeometryProxy) -> CGFloat {
        if 📐.size.width/9 < 📐.size.height/11 {
            return 📐.size.width/9
        } else {
            return (📐.size.height-4*4-16*2)/11
        }
    }
}


struct マス: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 位置: Int
    
    var body: some View {
        if let 駒 = 📱.駒の配置[位置] {
            コマ(駒.職名, 余白なし: true)
                .rotationEffect(下向き(駒.陣営 == .玉側))
                .onDrag {
                    📱.盤上の駒を持ち上げる(位置)
                } preview: {
                    コマ(駒.職名)
                        .environmentObject(📱)
                        .border(.primary)
                        .rotationEffect(下向き(駒.陣営 == .玉側))
                        .onAppear { 振動フィードバック() }
                }
                .onDrop(of: [.utf8PlainText], isTargeted: nil) { 📦 in
                    📱.駒をここに置く(位置, 📦)
                }
                .onTapGesture(count: 2) {
                    📱.駒を裏返す(位置)
                }
        } else {
            Color(uiColor: .systemBackground)
                .onDrop(of: [.utf8PlainText], isTargeted: nil) { 📦 in
                    📱.駒をここに置く(位置, 📦)
                }
        }
    }
}


struct コマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 職名: 駒の種類
    
    var 余白なし: Bool
    
    var 手駒の数: Int
    
    var 表記: String {
        let 一文字 = 📱.🚩English表記 ? 職名.English表記 : 職名.rawValue
        
        if 手駒の数 > 1 {
            return 一文字 + 手駒の数.description
        } else {
            return 一文字
        }
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            
            if 余白なし {
                Text(表記)
            } else {
                Text(表記)
                    .padding()
            }
        }
        .minimumScaleFactor(0.1)
        .accessibilityHidden(true)
    }
    
    init(_ ｼｮｸﾒｲ:駒の種類, _ ｶｽﾞ:Int = 1, 余白なし ﾖﾊｸﾅｼ:Bool = false) {
        職名 = ｼｮｸﾒｲ
        手駒の数 = ｶｽﾞ
        余白なし = ﾖﾊｸﾅｼ
    }
}


struct 盤外: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 陣営: 王側か玉側か
    
    var body: some View {
        HStack {
//            Spacer()
            
            ForEach(駒の種類.allCases) { 職名 in
                盤外のコマ(陣営, 職名)
            }
//            ForEach(駒の種類.allCases) { 職名 in
//                let 駒の数 = 📱.手駒[陣営]?[職名] ?? 0
//                if 駒の数 > 0 {
//                    コマ(職名, 駒の数, 余白なし: true)
//                        .onDrag{
//                            📱.手駒を持ち上げる(将棋駒(陣営,職名))
//                        } preview: {
//                            コマ(職名)
//                                .environmentObject(📱)
//                                .border(.primary)
//                                .rotationEffect(下向き(陣営 == .玉側))
//                                .onAppear { 振動フィードバック() }
//                        }
//                        .onTapGesture(count: 3) {
//                            📱.手駒から減らす(陣営, 職名)
//                            振動フィードバック()
//                        }
//                } else {
//                    EmptyView()
//                }
//            }
            
//            Spacer()
        }
        .rotationEffect(下向き(陣営 == .玉側))
    }
}


struct 盤外のコマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 陣営: 王側か玉側か
    
    var 職名: 駒の種類
    
    var 手駒の数: Int {
        📱.この手駒の数(陣営, 職名)
    }
    
    var 表記: String {
        let 🪧 = 📱.🚩English表記 ? 職名.English表記 : 職名.rawValue
        
        if 手駒の数 >= 2 {
            return 🪧 + 手駒の数.description
        } else {
            return 🪧
        }
    }
    
    var body: some View {
        if 手駒の数 == 0 {
            EmptyView()
        } else {
            ZStack {
                Rectangle()
                    .foregroundStyle(.background)
                
                Text(表記)
                    .minimumScaleFactor(0.1)
                    .accessibilityHidden(true)
                    .onDrag{
                        📱.手駒を持ち上げる(将棋駒(陣営,職名))
                    } preview: {
                        コマ(職名)
                            .environmentObject(📱)
                            .border(.primary)
                            .rotationEffect(下向き(陣営 == .玉側))
                            .onAppear { 振動フィードバック() }
                    }
                    .onTapGesture(count: 3) {
                        📱.手駒から減らす(陣営, 職名)
                        振動フィードバック()
                    }
            }
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


func 下向き(_ 玉側かどうか: Bool) -> Angle {
    if 玉側かどうか {
        return .degrees(180)
    } else {
        return .zero
    }
}


func 振動フィードバック() {
    UISelectionFeedbackGenerator().selectionChanged()
}








struct ContentView_Previews: PreviewProvider {
    static let 📱 = 📱AppModel()
    
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 400, height: 400))
            .environmentObject(📱)
            .task {
                📱.手駒[.王側]?[.歩] = 2
                📱.手駒[.王側]?[.金] = 1
                📱.手駒[.玉側]?[.角] = 1
                📱.手駒[.玉側]?[.歩] = 1
            }
        
        ContentView()
            .previewLayout(.fixed(width: 200, height: 500))
            .environmentObject(📱)
    }
}
