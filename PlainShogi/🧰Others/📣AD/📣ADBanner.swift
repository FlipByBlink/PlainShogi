
import SwiftUI

struct 📣ADBanner: View {
    @EnvironmentObject var 🛒: 🛒StoreModel
    @State private var 🚩ShowBanner = false
    @AppStorage("🄻aunchCount") var 🄻aunchCount: Int = 0
    
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
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.title)
                                    .offset(y: -26)
                                    .shadow(radius: 1.5)
                                    .padding()
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .foregroundStyle(.background)
                                .shadow(color: .secondary, radius: 3, y: 0.5)
                        }
                        .padding(14)
                        .transition(.move(edge: .bottom))
                        .frame(minWidth: 250)
                }
            }
        }
        .animation(.easeOut.speed(1.5), value: 🚩ShowBanner)
        .animation(.easeOut.speed(1.5), value: 🛒.🚩Purchased)
        .onAppear {
            🄻aunchCount += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if 🄻aunchCount > 5 { 🚩ShowBanner = true }
            }
        }
    }
}
