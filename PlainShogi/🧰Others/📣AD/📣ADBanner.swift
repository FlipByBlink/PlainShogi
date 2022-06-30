
import SwiftUI

struct 📣ADBanner: View {
    @EnvironmentObject var 🛒: 🛒StoreModel
    
    @State private var 🚩ShowBanner = false
    
    @AppStorage("🄻aunchCount") var 🄻aunchCount: Int = 0
    
    let 🅃iming: Int = 3
    
    var body: some View {
        Group {
            if 🛒.🚩Purchased {
                EmptyView()
            } else {
                if 🚩ShowBanner {
                    📣ADView()
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                🚩ShowBanner = false
                                UISelectionFeedbackGenerator().selectionChanged()
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .symbolRenderingMode(.hierarchical)
                                    .imageScale(.large)
                                    .background {
                                        Circle()
                                            .foregroundStyle(.background)
                                            .opacity(0.5)
                                    }
                                    .padding(6)
                                    .padding(.trailing, 2)
                            }
                            .tint(.pink)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .foregroundStyle(.background)
                                .shadow(radius: 3)
                        }
                        .padding()
                        .transition(.move(edge: .bottom))
                        .frame(minWidth: 300)
                }
            }
        }
        .animation(.easeOut.speed(1.5), value: 🚩ShowBanner)
        .animation(.easeOut.speed(1.5), value: 🛒.🚩Purchased)
        .onAppear {
            🄻aunchCount += 1
            
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                if 🄻aunchCount % 🅃iming == 0 {
                    🚩ShowBanner = true
                }
            }
        }
    }
}
