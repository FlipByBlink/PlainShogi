
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        GeometryReader { 画面 in
            let マスの大きさ = マスの大きさを計算する(画面)
            
            VStack(spacing: 0) {
                盤外(.玉側, マスの大きさ)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    ForEach( 0 ..< 9 ) { 行 in
                        HStack(spacing: 0) {
                            Divider()
                            
                            ForEach( 0 ..< 9 ) { 列 in
                                盤上のコマもしくはマス(位置: 行 * 9 + 列)
                                
                                Divider()
                            }
                        }
                        
                        Divider()
                    }
                }
                .border(.primary)
                .frame(width: マスの大きさ * 9, height: マスの大きさ * 9)
                
                盤外(.王側, マスの大きさ)
            }
        }
        .padding()
    }
    
    func マスの大きさを計算する(_ 画面: GeometryProxy) -> CGFloat {
        if 画面.size.width/9 < 画面.size.height/11 {
            return 画面.size.width/9
        } else {
            return 画面.size.height/11
        }
    }
}


struct 盤上のコマもしくはマス: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var ドラッグ中 = false
    var 位置: Int
    
    var body: some View {
        GeometryReader { 📐 in
            if let 駒 = 📱.駒の配置[位置] {
                コマ(📱.この盤上の駒の表記(駒), $ドラッグ中)
                    .rotationEffect(下向き(駒.陣営 == .玉側))
                    .overlay { 駒を消すボタン(位置) }
                    .onTapGesture(count: 2) { 📱.駒の配置[位置]?.裏返す() }
                    .accessibilityHidden(true)
                    .onDrag {
                        📱.この盤上の駒をドラッグし始める(位置)
                    } preview: {
                        コマのプレビュー(駒.陣営, 📱.この盤上の駒の表記(駒))
                            .frame(height: 📐.size.height + 8)
                            .onAppear { ドラッグ中 = true }
                    }
            } else { // ==== マス ====
                Rectangle().foregroundStyle(.background)
            }
        }
        .onDrop(of: [.utf8PlainText], delegate: 📬盤上ドロップ(📱, 位置))
    }
}


struct 盤外: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 陣営: 王側か玉側か
    var コマの大きさ: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle().foregroundStyle(.background)
            
            HStack(spacing: 0) {
                ForEach(駒の種類.allCases) { 職名 in
                    盤外のコマ(陣営, 職名)
                }
            }
            .frame(height: コマの大きさ)
        }
        .overlay(alignment: .bottomLeading) { 手駒調整ボタン(陣営) }
        .rotationEffect(下向き(陣営 == .玉側))
        .onDrop(of: [UTType.utf8PlainText], delegate: 📬盤外ドロップ(📱, 陣営))
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｵｵｷｻ: CGFloat) {
        陣営 = ｼﾞﾝｴｲ
        コマの大きさ = ｵｵｷｻ
    }
}


struct 盤外のコマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    @State private var ドラッグ中 = false
    var 陣営: 王側か玉側か
    var 職名: 駒の種類
    var 持ち駒の表記: String { 📱.この持ち駒の表記(陣営, 職名) }
    var 持ち駒の数: Int { 📱.この持ち駒の数(陣営, 職名) }
    var 持ち駒の数の表記: String {
        持ち駒の数 >= 2 ? 持ち駒の数.description : ""
    }
    
    var body: some View {
        if 持ち駒の数 == 0 {
            EmptyView()
        } else {
            GeometryReader { 📐 in
                ZStack {
                    Color.clear
                    
                    コマ(持ち駒の表記 + 持ち駒の数の表記, $ドラッグ中)
                        .frame(maxWidth: 📐.size.height * 1.5)
                }
                .onDrag{
                    📱.この持ち駒をドラッグし始める(陣営, 職名)
                } preview: {
                    コマのプレビュー(陣営, 持ち駒の表記)
                        .frame(height: 📐.size.height + 8)
                        .onAppear { ドラッグ中 = true }
                }
            }
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


struct コマ: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 表記: String
    @Binding var ドラッグ中: Bool
    
    var body: some View {
        ZStack {
            Rectangle().foregroundStyle(.background)
            
            Text(表記)
                .minimumScaleFactor(0.1)
                .opacity(ドラッグ中 ? 0.25 : 1.0)
                .rotationEffect(.degrees(📱.🚩駒を整理中 ? 20 : 0))
                .onChange(of: ドラッグ中) { ⓝewValue in
                    if ⓝewValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeIn(duration: 1.5)) {
                                ドラッグ中 = false
                            }
                        }
                    }
                }
        }
    }
    
    init(_ ﾋｮｳｷ: String, _ ドラッグ中: Binding<Bool>) {
        表記 = ﾋｮｳｷ
        _ドラッグ中 = ドラッグ中
    }
}


struct コマのプレビュー: View {
    var 陣営: 王側か玉側か
    var 表記: String
    
    var body: some View {
        ZStack {
            Rectangle().foregroundStyle(.background)
            
            Text(表記)
                .minimumScaleFactor(0.1)
                .padding(4)
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
    玉側かどうか ? .degrees(180) : .zero
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
