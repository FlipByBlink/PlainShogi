
import SwiftUI

struct 移動直後に目立たせるための枠線: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 位置: Int
    
    var body: some View {
        if 📱.🚩移動直後の駒を目立たせる {
            if 📱.移動直後の駒の位置 == 位置 {
                Rectangle().stroke(style: .init(dash: [3,3]))
            }
        }
    }
    
    init(_ ｲﾁ: Int) {
        位置 = ｲﾁ
    }
}


struct 駒を消すボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 位置: Int
    
    var body: some View {
        if 📱.駒を整理中 {
            GeometryReader { 📐 in
                Button {
                    withAnimation {
                        📱.駒の配置.removeValue(forKey: 位置)
                        振動フィードバック()
                    }
                } label: {
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, .background)
                            .tint(.primary)
                            .frame(width: 📐.size.width * 2/5,
                                   height: 📐.size.height * 2/5)
                    }
                }
            }
        }
    }
    
    init(_ ｲﾁ: Int) {
        位置 = ｲﾁ
    }
}


struct 整理完了ボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        Button {
            withAnimation {
                📱.駒を整理中 = false
                振動フィードバック()
            }
        } label: {
            Image(systemName: "checkmark")
                .foregroundColor(.primary)
                .padding(32)
        }
        .accessibilityLabel("DONE")
    }
}


struct 手駒調整Button: View {
    @EnvironmentObject var 📱: 📱AppModel
    @Environment(\.dismiss) var 🔙: DismissAction
    var 陣営: 王側か玉側か
    
    @State private var 手駒の数を増減中: Bool = false
    
    var body: some View {
        if 📱.駒を整理中 {
            Button {
                手駒の数を増減中 = true
            } label: {
                Label("手駒の数を増減する", systemImage: "plusminus")
                    .minimumScaleFactor(0.1)
                    .labelStyle(.iconOnly)
                    .padding()
            }
            .tint(.primary)
            .sheet(isPresented: $手駒の数を増減中) {
                手駒調整Sheet(陣営)
                    .onDisappear {
                        手駒の数を増減中 = false
                    }
            }
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) {
        陣営 = ｼﾞﾝｴｲ
    }
}

struct 手駒調整Sheet: View {
    @EnvironmentObject var 📱: 📱AppModel
    @Environment(\.dismiss) var 🔙: DismissAction
    var 陣営: 王側か玉側か
    
    var body: some View {
        NavigationView {
            List {
                ForEach(駒の種類.allCases) { 職名 in
                    Stepper {
                        HStack {
                            Spacer()
                            
                            Text(📱.この持ち駒の表記(陣営, 職名))
                                .font(.title)
                            
                            Spacer()
                            
                            Text(📱.この持ち駒の数(陣営, 職名).description)
                                .font(.title3)
                                .monospacedDigit()
                            
                            Spacer()
                        }
                        .padding(4)
                    } onIncrement: {
                        📱.手駒[陣営]?.一個増やす(職名)
                    } onDecrement: {
                        📱.手駒[陣営]?.一個減らす(職名)
                    }
                }
            }
            .navigationTitle(陣営.rawValue)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        🔙.callAsFunction()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                            .grayscale(1.0)
                            .padding(8)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) {
        陣営 = ｼﾞﾝｴｲ
    }
}




//struct SubView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
