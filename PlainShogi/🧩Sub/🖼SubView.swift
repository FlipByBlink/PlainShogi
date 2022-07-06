
import SwiftUI

struct 🛠盤面初期化ボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        Button {
            📱.盤面を初期化する()
            
            📱.🚩メニューを表示 = false
        } label: {
            Label("盤面を初期化する", systemImage: "arrow.counterclockwise")
        }
    }
}


struct 🛠盤面整理開始ボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        Button {
            withAnimation {
                📱.🚩駒を整理中 = true
            }
            
            📱.🚩メニューを表示 = false
        } label: {
            Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
        }
    }
}


struct 駒を消すボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 位置: Int
    
    var body: some View {
        if 📱.🚩駒を整理中 {
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
                📱.🚩駒を整理中 = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .padding(24)
        }
        .tint(.secondary)
        .accessibilityLabel("DONE")
    }
}


struct 手駒調整ボタン: View {
    @EnvironmentObject var 📱: 📱AppModel
    var 陣営: 王側か玉側か
    
    @State private var 手駒の数を増減中: Bool = false
    
    var body: some View {
        if 📱.🚩駒を整理中 {
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
                手駒調整シート(陣営)
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

struct 手駒調整シート: View {
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
                        .padding()
                    } onIncrement: {
                        📱.手駒[陣営]?.一個増やす(職名)
                    } onDecrement: {
                        📱.手駒[陣営]?.一個減らす(職名)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(陣営.rawValue)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        🔙.callAsFunction()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
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



//==== 一度実装したがリリース保留にした「移動直後の駒にマークを付ける機能」 ====
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
