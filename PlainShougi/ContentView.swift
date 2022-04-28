
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var 将棋: 将棋Model
    
    var body: some View {
        GeometryReader { 📐 in
            let マスの大きさ: CGFloat = {
                if 📐.size.width/9 < 📐.size.height/11 {
                    return 📐.size.width/9
                } else {
                    return (📐.size.height-4*4-16*2)/11
                }
            }()
            
            VStack {
                Spacer()
                
                盤外(陣営: .玉)
                    .frame(height: マスの大きさ, alignment: .center)
                    .padding(4)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    ForEach( 0 ..< 9 ) { 行 in
                        HStack(spacing: 0) {
                            Divider()
                            
                            ForEach( 0 ..< 9 ) { 列 in
                                マス(位置: 行*9+列)
                                
                                Divider()
                            }
                        }
                        
                        Divider()
                    }
                }
                .frame(width: マスの大きさ*9,
                       height: マスの大きさ*9,
                       alignment: .center)
                .border(.primary)
                
                盤外(陣営: .王)
                    .frame(height: マスの大きさ, alignment: .center)
                    .padding(4)
                
                Spacer()
            }
        }
        .padding(16)
    }
}


struct マス: View {
    @EnvironmentObject var 将棋: 将棋Model
    
    var 位置: Int
    
    var body: some View {
        if let 兵員: 兵 = 将棋.盤上[位置] {
            コマ(兵員.職名, 余白なし: true)
                .rotationEffect(反転(兵員.陣営 == .玉))
                .onDrag {
                    将棋.持ち上げる(位置)
                } preview: {
                    コマ(兵員.職名)
                        .border(.primary)
                        .rotationEffect(反転(兵員.陣営 == .玉))
                        .onAppear { 振動() }
                }
                .onDrop(of: [.text], isTargeted: nil) { 📨 in
                    将棋.移動(位置, 📨)
                }
                .onTapGesture(count: 2) {
                    将棋.裏返す(位置)
                }
        } else {
            Color(uiColor: .systemBackground)
                .onDrop(of: [.text], isTargeted: nil) { 📨 in
                    将棋.移動(位置, 📨)
                }
        }
    }
}


struct コマ: View {
    var 職名: 種類
    
    var 余白なし: Bool
    
    var 数: Int
    
    @AppStorage("English表記") var English表記: Bool = false
    
    var 表記: String {
        let 字 = English表記 ? 職名.english : 職名.rawValue
        
        if 数 > 1 {
            return 字 + 数.description
        } else {
            return 字
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
    
    init(_ ｼｮｸﾒｲ:種類, _ ｶｽﾞ:Int = 1, 余白なし ﾖﾊｸﾅｼ:Bool = false) {
        職名 = ｼｮｸﾒｲ
        数 = ｶｽﾞ
        余白なし = ﾖﾊｸﾅｼ
    }
}


struct 盤外: View {
    @EnvironmentObject var 将棋: 将棋Model
    
    var 陣営: 王か玉か
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(種類.allCases) { 種類毎 in
                let 数 = 将棋.手駒[陣営]!.filter{$0 == 種類毎}.count
                if 数 > 0 {
                    コマ(種類毎, 数, 余白なし: true)
                        .onDrag{
                            将棋.持ち上げる(兵(陣営,種類毎))
                        } preview: {
                            コマ(種類毎)
                                .border(.primary)
                                .rotationEffect(反転(陣営 == .玉))
                                .onAppear { 振動() }
                        }
                        .onTapGesture(count: 3) {
                            let ひとつ = 将棋.手駒[陣営]!.firstIndex(of:種類毎)!
                            将棋.手駒[陣営]!.remove(at: ひとつ)
                        }
                } else {
                    EmptyView()
                }
            }
            
            Spacer()
        }
        .rotationEffect(反転(陣営 == .玉))
    }
}


func 反転(_ 玉かどうか: Bool) -> Angle {
    if 玉かどうか {
        return .degrees(180)
    } else {
        return .zero
    }
}


func 振動() {
    UISelectionFeedbackGenerator().selectionChanged()
}








struct ContentView_Previews: PreviewProvider {
    static let 将棋 = 将棋Model()
    
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 400, height: 400))
            .environmentObject(将棋)
            .task {
                将棋.手駒[.玉] = [.歩,.歩,.金]
                将棋.手駒[.王] = [.歩,.銀]
            }
        
        ContentView()
            .previewLayout(.fixed(width: 300, height: 600))
            .environmentObject(将棋)
    }
}
