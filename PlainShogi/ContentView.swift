
import SwiftUI

struct ContentView: View {
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
                
                盤外(陣営: .玉側)
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
                
                盤外(陣営: .王側)
                    .frame(height: マスの大きさ, alignment: .center)
                    .padding(4)
                
                Spacer()
            }
        }
        .padding(16)
    }
}


struct マス: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var 位置: Int
    
    var body: some View {
        if let 兵員: 兵 = 📱.駒の配置[位置] {
            コマ(兵員.職名, 余白なし: true)
                .rotationEffect(反転(兵員.陣営 == .玉側))
                .onDrag {
                    📱.盤上の駒を持ち上げる(位置)
                } preview: {
                    コマ(兵員.職名)
                        .environmentObject(📱)
                        .border(.primary)
                        .rotationEffect(反転(兵員.陣営 == .玉側))
                        .onAppear { 振動() }
                }
                .onDrop(of: [.text], isTargeted: nil) { 📨 in
                    📱.駒を動かす(位置, 📨)
                }
                .onTapGesture(count: 2) {
                    📱.駒を裏返す(位置)
                }
        } else {
            Color(uiColor: .systemBackground)
                .onDrop(of: [.text], isTargeted: nil) { 📨 in
                    📱.駒を動かす(位置, 📨)
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
        let 字 = 📱.🚩English表記 ? 職名.english : 職名.rawValue
        
        if 手駒の数 > 1 {
            return 字 + 手駒の数.description
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
            Spacer()
            
            ForEach(駒の種類.allCases) { 職名 in
                let 駒数 = 📱.手駒[陣営]!.filter{$0 == 職名}.count
                if 駒数 > 0 {
                    コマ(職名, 駒数, 余白なし: true)
                        .onDrag{
                            📱.手駒を持ち上げる(兵(陣営,職名))
                        } preview: {
                            コマ(職名)
                                .border(.primary)
                                .rotationEffect(反転(陣営 == .玉側))
                                .onAppear { 振動() }
                        }
                        .onTapGesture(count: 3) {
                            let ひとつ = 📱.手駒[陣営]!.firstIndex(of:職名)!
                            📱.手駒[陣営]!.remove(at: ひとつ)
                        }
                } else {
                    EmptyView()
                }
            }
            
            Spacer()
        }
        .rotationEffect(反転(陣営 == .玉側))
    }
}


func 反転(_ 玉側かどうか: Bool) -> Angle {
    if 玉側かどうか {
        return .degrees(180)
    } else {
        return .zero
    }
}


func 振動() {
    UISelectionFeedbackGenerator().selectionChanged()
}








struct ContentView_Previews: PreviewProvider {
    static let 📱 = 📱AppModel()
    
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 400, height: 400))
            .environmentObject(📱)
            .task {
                📱.手駒[.玉側] = [.歩,.歩,.金]
                📱.手駒[.王側] = [.歩,.銀]
            }
        
        ContentView()
            .previewLayout(.fixed(width: 300, height: 600))
            .environmentObject(📱)
    }
}
