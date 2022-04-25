
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var 将棋: 将棋Model
    
    var body: some View {
        VStack {
            盤外(陣営: .玉)
            
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
            .aspectRatio(1, contentMode: .fit)
            .border(.primary)
            
            盤外(陣営: .王)
        }
        .padding()
    }
}


struct マス: View {
    @EnvironmentObject var 将棋: 将棋Model
    
    var 位置: Int
    
    var body: some View {
        if let 兵士: 兵 = 将棋.盤上[位置] {
            コマ(名: 兵士.職名, 余白なし: true)
                .rotationEffect(反転(兵士.陣営 == .玉))
                .onDrag {
                    将棋.持ち上げる(位置)
                } preview: {
                    コマ(名: 兵士.職名)
                        .border(.primary)
                        .rotationEffect(反転(兵士.陣営 == .玉))
                        .onAppear { 振動() }
                }
                .onDrop(of: [.text], isTargeted: nil) { 📨 in
                    将棋.移動(位置, 📨)
                }
                .onTapGesture(count: 2) {
                    将棋.裏返す(位置)
                }
        } else {
            背景()
                .onDrop(of: [.text], isTargeted: nil) { 📨 in
                    将棋.移動(位置, 📨)
                }
        }
    }
}


struct コマ: View {
    var 名: 種類
    
    var 余白なし: Bool = false
    
    var 数: Int = 1
    
    @AppStorage("English表記") var English表記: Bool = false
    
    var 表記: String {
        let 字 = English表記 ? 名.english : 名.rawValue
        
        if 数 > 1 {
            return 字 + 数.description
        } else {
            return 字
        }
    }
    
    var body: some View {
        
        ZStack {
            背景()
            
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
}


struct 盤外: View {
    @EnvironmentObject var 将棋: 将棋Model
    
    var 陣営: 王か玉か
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(種類.allCases) { ｼｭﾙｲ in
                let 人数 = 将棋.手駒[陣営]!.filter{$0 == ｼｭﾙｲ}.count
                if 人数 > 0 {
                    コマ(名: ｼｭﾙｲ, 余白なし: true, 数: 人数)
                        .onDrag{
                            将棋.持ち上げる(兵(陣営,ｼｭﾙｲ))
                        } preview: {
                            コマ(名: ｼｭﾙｲ)
                                .border(.primary)
                                .rotationEffect(反転(陣営 == .玉))
                                .onAppear { 振動() }
                        }
                        .onTapGesture(count: 3) {
                            let ひとつ = 将棋.手駒[陣営]!.firstIndex(of:ｼｭﾙｲ)!
                            将棋.手駒[陣営]!.remove(at: ひとつ)
                        }
                } else {
                    EmptyView()
                }
            }
            
            Spacer()
        }
        .frame(height: 48, alignment: .center)
        .padding()
        .rotationEffect(反転(陣営 == .玉))
    }
}


struct 背景: View {
    var body: some View {
        Rectangle()
            .foregroundColor(Color(uiColor: .systemBackground))
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
