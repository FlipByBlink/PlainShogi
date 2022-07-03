
import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { 📐 in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                盤外(.玉側)
                    .frame(height: マス一辺の大きさ(📐))
                
                Spacer(minLength: 0)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    ForEach( 0 ..< 9 ) { 行 in
                        HStack(spacing: 0) {
                            Divider()
                            
                            ForEach( 0 ..< 9 ) { 列 in
                                コマもしくはマス(位置: 行*9+列)
                                
                                Divider()
                            }
                        }
                        
                        Divider()
                    }
                }
                .border(.primary)
                .frame(width: マス一辺の大きさ(📐) * 9,
                       height: マス一辺の大きさ(📐) * 9)
                
                Spacer(minLength: 0)
                
                盤外(.王側)
                    .frame(height: マス一辺の大きさ(📐))
                
                Spacer(minLength: 0)
            }
        }
        .padding()
    }
    
    func マス一辺の大きさ(_ 📐: GeometryProxy) -> CGFloat {
        if 📐.size.width/9 < 📐.size.height/11 {
            return 📐.size.width/9
        } else {
            return 📐.size.height/11
        }
    }
}


struct コマもしくはマス: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 位置: Int
    
    @State private var コマの透明度: Double = 1.0
    
    var body: some View {
        GeometryReader { 📐 in
            if let 駒 = 📱.駒の配置[位置] {
                ZStack { // ======== コマ ========
                    Rectangle()
                        .foregroundStyle(.background)
                    
                    Text(📱.この盤上の駒の表記(駒))
                        .minimumScaleFactor(0.1)
                        .rotationEffect(下向き(駒.陣営 == .玉側))
                        .accessibilityHidden(true)
                        .opacity(コマの透明度)
                }
                .onTapGesture(count: 2) {
                    📱.駒の配置[位置]?.裏返す()
                }
                .onDrag {
                    コマの透明度 = 0.25
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        withAnimation(.easeIn(duration: 1.5)) {
                            コマの透明度 = 1.0
                        }
                    }
                    
                    return 📱.この盤上の駒をドラッグする(位置)
                } preview: {
                    コマのプレビュー(駒.陣営, 📱.この盤上の駒の表記(駒))
                        .frame(height: 📐.size.height + 8)
                }
            } else { // ======== マス ========
                Rectangle()
                    .foregroundStyle(.background)
            }
        }
//        .onDrop(of: [.utf8PlainText], isTargeted: nil) { 📦 in
//            📱.駒をここにドロップする(位置, 📦)
//        }
        .onDrop(of: [.utf8PlainText], delegate: 📨DropDelegate(駒の配置: $📱.駒の配置, 📱: 📱))
    }
}


struct 📨DropDelegate: DropDelegate {
    @Binding var 駒の配置: [Int: 盤上の駒]
    
    var 📱: 📱AppModel
    
    func performDrop(info: DropInfo) -> Bool {
        //駒の配置 = 初期配置
        📱.盤面を初期化する()
        return true
    }
}

struct 盤外: View {
    var 陣営: 王側か玉側か
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(駒の種類.allCases) { 職名 in
                盤外のコマ(陣営, 職名)
            }
        }
        .rotationEffect(下向き(陣営 == .玉側))
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) {
        陣営 = ｼﾞﾝｴｲ
    }
}


struct 盤外のコマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 陣営: 王側か玉側か
    
    var 職名: 駒の種類
    
    var 持ち駒の表記: String { 📱.この持ち駒の表記(陣営, 職名) }
    
    var 持ち駒の数: Int { 📱.この持ち駒の数(陣営, 職名) }
    
    var 持ち駒の数の表記: String {
        if 持ち駒の数 >= 2 {
            return 持ち駒の数.description
        } else {
            return ""
        }
    }
    
    @State private var コマの透明度: Double = 1.0
    
    var body: some View {
        if 持ち駒の数 == 0 {
            EmptyView()
        } else {
            GeometryReader { 📐 in
                ZStack {
                    Color.clear
                    
                    Rectangle()
                        .foregroundStyle(.background)
                        .frame(maxWidth: 📐.size.height * 1.5)
                    
                    Text(持ち駒の表記 + 持ち駒の数の表記)
                        .minimumScaleFactor(0.1)
                        .opacity(コマの透明度)
                }
                .onTapGesture(count: 3) {
                    📱.手駒[陣営]?.一個減らす(職名)
                    振動フィードバック()
                }
                .onDrag{
                    コマの透明度 = 0.25
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        withAnimation(.easeIn(duration: 1.5)) {
                            コマの透明度 = 1.0
                        }
                    }
                    
                    return 📱.この持ち駒をドラッグする(陣営, 職名)
                } preview: {
                    コマのプレビュー(陣営, 持ち駒の表記)
                        .frame(height: 📐.size.height + 8)
                }
            }
            .accessibilityHidden(true)
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


struct コマのプレビュー: View {
    var 陣営: 王側か玉側か
    
    var 表記: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.background)
            
            Text(表記)
                .minimumScaleFactor(0.1)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .border(.primary)
        .rotationEffect(下向き(陣営 == .玉側))
        .onAppear { 振動フィードバック() }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ﾋｮｳｷ: String) {
        陣営 = ｼﾞﾝｴｲ
        表記 = ﾋｮｳｷ
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
                📱.手駒[.王側]?.配分 = [.歩: 2, .角: 1]
                📱.手駒[.玉側]?.配分 = [.歩: 1, .角: 1, .香: 1]
            }
        
        ContentView()
            .previewLayout(.fixed(width: 200, height: 300))
            .environmentObject(📱)
        
        ContentView()
            .previewLayout(.fixed(width: 400, height: 200))
            .environmentObject(📱)
    }
}
