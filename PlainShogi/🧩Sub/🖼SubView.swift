
import SwiftUI

struct ð ç¤é¢åæåãã¿ã³: View {
    @EnvironmentObject var ð±: ð±AppModel
    
    var body: some View {
        Button {
            ð±.ç¤é¢ãåæåãã()
            ð±.ð©ã¡ãã¥ã¼ãè¡¨ç¤º = false
        } label: {
            Label("ç¤é¢ãåæåãã", systemImage: "arrow.counterclockwise")
        }
    }
}


struct ð ç¤é¢æ´çéå§ãã¿ã³: View {
    @EnvironmentObject var ð±: ð±AppModel
    
    var body: some View {
        Button {
            withAnimation { ð±.ð©é§ãæ´çä¸­ = true }
            ð±.ð©ã¡ãã¥ã¼ãè¡¨ç¤º = false
            æ¯åãã£ã¼ãããã¯()
        } label: {
            Label("é§ãæ¶ãããå¢ãããããã", systemImage: "wand.and.rays")
        }
    }
}


struct é§ãæ¶ããã¿ã³: View {
    @EnvironmentObject var ð±: ð±AppModel
    var ä½ç½®: Int
    
    var body: some View {
        if ð±.ð©é§ãæ´çä¸­ {
            GeometryReader { ð in
                Button {
                    withAnimation {
                        ð±.é§ã®éç½®.removeValue(forKey: ä½ç½®)
                        æ¯åãã£ã¼ãããã¯()
                    }
                } label: {
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, .background)
                            .tint(.primary)
                            .frame(width: ð.size.width * 2/5,
                                   height: ð.size.height * 2/5)
                    }
                }
            }
        }
    }
    
    init(_ ï½²ï¾: Int) { ä½ç½® = ï½²ï¾ }
}


struct æ´çå®äºãã¿ã³: View {
    @EnvironmentObject var ð±: ð±AppModel
    
    var body: some View {
        Button {
            withAnimation {
                ð±.ð©é§ãæ´çä¸­ = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .padding(24)
        }
        .tint(.secondary)
        .accessibilityLabel("Done")
    }
}


struct æé§èª¿æ´ãã¿ã³: View {
    @EnvironmentObject var ð±: ð±AppModel
    var é£å¶: çå´ãçå´ã
    @State private var æé§ã®æ°ãå¢æ¸ä¸­: Bool = false
    
    var body: some View {
        if ð±.ð©é§ãæ´çä¸­ {
            Button {
                æé§ã®æ°ãå¢æ¸ä¸­ = true
                æ¯åãã£ã¼ãããã¯()
            } label: {
                Image(systemName: "plusminus")
                    .minimumScaleFactor(0.1)
                    .padding()
            }
            .accessibilityLabel("æé§ãæ´çãã")
            .tint(.primary)
            .sheet(isPresented: $æé§ã®æ°ãå¢æ¸ä¸­) {
                æé§èª¿æ´ã·ã¼ã(é£å¶)
                    .onDisappear { æé§ã®æ°ãå¢æ¸ä¸­ = false }
            }
        }
    }
    
    init(_ ï½¼ï¾ï¾ï½´ï½²: çå´ãçå´ã) { é£å¶ = ï½¼ï¾ï¾ï½´ï½² }
}

struct æé§èª¿æ´ã·ã¼ã: View {
    @EnvironmentObject var ð±: ð±AppModel
    @Environment(\.dismiss) var ð: DismissAction
    var é£å¶: çå´ãçå´ã
    var ã¿ã¤ãã«: String {
        switch (é£å¶,ð±.ð©Englishè¡¨è¨) {
            case (.çå´, false): return "çå´ã®æé§"
            case (.çå´, true): return "â Pieces"
            case (.çå´, false): return "çå´ã®æé§"
            case (.çå´, true): return "â Pieces"
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(é§ã®ç¨®é¡.allCases) { è·å in
                    Stepper {
                        HStack {
                            Spacer()
                            
                            Text(ð±.ãã®æã¡é§ã®è¡¨è¨(é£å¶, è·å))
                                .font(.title)
                            
                            Spacer()
                            
                            Text(ð±.ãã®æã¡é§ã®æ°(é£å¶, è·å).description)
                                .font(.title3)
                                .monospacedDigit()
                        }
                        .padding()
                    } onIncrement: {
                        ð±.æé§[é£å¶]?.ä¸åå¢ãã(è·å)
                    } onDecrement: {
                        ð±.æé§[é£å¶]?.ä¸åæ¸ãã(è·å)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(ã¿ã¤ãã«)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        ð.callAsFunction()
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
    
    init(_ ï½¼ï¾ï¾ï½´ï½²: çå´ãçå´ã) { é£å¶ = ï½¼ï¾ï¾ï½´ï½² }
}



//==== ä¸åº¦å®è£ããããªãªã¼ã¹ä¿çã«ãããç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ããæ©è½ã ====
//struct ç§»åç´å¾ãã¼ã¯: View {
//    @EnvironmentObject var ð±: ð±AppModel
//    var ä½ç½®: Int
//
//    var body: some View {
//        if ð±.ð©ç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ãã {
//            if ð±.ç§»åç´å¾ã®é§ã®ä½ç½® == ä½ç½® {
//                GeometryReader { ð in
//                    ZStack(alignment: .bottomTrailing) {
//                        Color.clear
//
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .symbolRenderingMode(.palette)
//                            .foregroundStyle(.primary, .background)
//                            .frame(width: ð.size.width * 1/3,
//                                   height: ð.size.height * 1/3)
//                    }
//                }
//            }
//        }
//    }
//
//    init(_ ï½²ï¾: Int) {
//        ä½ç½® = ï½²ï¾
//    }
//}
//
//.overlay() { ç§»åç´å¾ãã¼ã¯(ä½ç½®) }
//
//@AppStorage("ç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ãã") var ð©ç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ãã: Bool = false
//
//@Published var ç§»åç´å¾ã®é§ã®ä½ç½®: Int?
//
//Toggle(isOn: ð±.$ð©ç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ãã) {
//    Label("ç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ãã", systemImage: "app.badge.checkmark")
//}
//
//Text("ç§»åç´å¾ã®é§ã«ãã¼ã¯ãä»ãããã¼ã¯ã¯ç©ºç½ã®ãã¹ãã¿ãããããã¨ã§ä¸æ¦ éè¡¨ç¤ºã«ãããã¨ãã§ãã¾ãã")
