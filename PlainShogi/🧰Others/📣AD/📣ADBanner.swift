
import SwiftUI

struct 📣ADBanner: View {
    @EnvironmentObject var 🛒: 🛒StoreModel
    @State private var 🚩ShowBanner = true
    
    var body: some View {
        Group {
            if 🛒.🚩ADisActive {
                if 🚩ShowBanner {
                    📣ADView()
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                🚩ShowBanner = false
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
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
                        .frame(minWidth: 300, maxHeight: 250, alignment: .bottom)
                }
            }
        }
        .animation(.easeOut.speed(0.5), value: 🚩ShowBanner)
        .animation(.easeOut.speed(0.5), value: 🛒.🚩Purchased)
    }
}
