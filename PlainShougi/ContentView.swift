
import SwiftUI


struct ContentView: View {
    
    @EnvironmentObject var 配置: 配置Model
    
    var body: some View {
        VStack {
            盤外(陣営: .玉)
            
            VStack(spacing: 0) {
                枠線()
                
                ForEach( 0 ..< 9 ) { 行 in
                    HStack(spacing: 0) {
                        枠線()
                        
                        ForEach( 0 ..< 9 ) { 列 in
                            let ここ = 行 * 9 + 列
                            
                            マス(位置: ここ)
                            
                            枠線()
                        }
                    }
                    
                    枠線()
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
    
    @EnvironmentObject var 配置: 配置Model
    
    var 位置: Int
    
    var body: some View {
        if let 兵士: 兵 = 配置.盤上[位置] {
            コマ(名: 兵士.職名, 余白なし: true)
                .rotationEffect(反転(兵士.陣営 == .玉))
                .onDrag {
                    配置.持ち上げる(位置)
                } preview: {
                    コマ(名: 兵士.職名)
                        .border(.primary)
                        .rotationEffect(反転(兵士.陣営 == .玉))
                        .onAppear { 振動() }
                }
                .onDrop(of: [.text], isTargeted: nil) { _ in
                    配置.移動(ここへ: 位置)
                }
                .onTapGesture(count: 2) {
                    配置.裏返す(位置)
                }
        } else {
            背景()
                .onDrop(of: [.text], isTargeted: nil) { _ in
                    配置.移動(ここへ: 位置)
                }
        }
    }
}


struct コマ: View {
    
    var 名: 種類
    
    var 余白なし: Bool = false
    
    var 数: Int = 1
    
    var 表記: String {
        if 数 > 1 {
            return 名.rawValue + 数.description
        } else {
            return 名.rawValue
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
    
    @EnvironmentObject var 配置: 配置Model
    
    var 陣営: 王か玉か
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(種類.allCases) { 職名 in
                let 人数 = 配置.手駒[陣営]!.filter{$0 == 職名}.count
                if 人数 > 0 {
                    コマ(名: 職名, 余白なし: true, 数: 人数)
                        .onDrag{
                            配置.持ち上げる(兵(陣営,職名))
                        } preview: {
                            コマ(名: 職名)
                                .border(.primary)
                                .rotationEffect(反転(陣営 == .玉))
                                .onAppear { 振動() }
                        }
                        .onTapGesture(count: 3) {
                            let ひとつ = 配置.手駒[陣営]!.firstIndex(of:職名)!
                            配置.手駒[陣営]!.remove(at: ひとつ)
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


struct 枠線: View {
    @AppStorage("枠を非表示") var 枠を非表示: Bool = false
    
    var body: some View {
        Divider()
            .opacity(枠を非表示 ? 0 : 1)
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
    
    static let 配置 = 配置Model()
    
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 400, height: 400))
            .environmentObject(配置)
            .task {
                配置.手駒[.玉] = [.歩,.歩,.金]
                配置.手駒[.王] = [.歩,.銀]
            }
        
        ContentView()
            .previewLayout(.fixed(width: 300, height: 600))
            .environmentObject(配置)
    }
}
