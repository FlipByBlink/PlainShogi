
import SwiftUI
import StoreKit


struct 広告AD: View {
    @State private var 🄿resentAdBanner = false
    
    @State private var 🄿resentNote = false
    
    @AppStorage("🄻aunchCount") var 🄻aunchCount: Int = 0
    
    var 🚩AdBanner: Bool {
        ( 🄻aunchCount % 6 ) == 0
    }
    
    var 🆔: String {
        //FlipByBlink appIdentifier: 1444571751
        //FadeInAlarm appIdentifier: 1465336070
        if 🄻aunchCount % 2 == 1 {
            return "1444571751"
        } else {
            return "1465336070"
        }
    }
    
    
    var body: some View {
        VStack {
            Spacer()
            
            if 🄿resentAdBanner {
                HStack {
                    Button {
                        🄿resentNote = true
                    } label: {
                        Text("🌏セルフ広告")
                            .kerning(0.5)
                            .underline()
                            .foregroundStyle(.tertiary)
                            .grayscale(1)
                            .font(.body.weight(.heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    .alert("🌏セルフ広告について", isPresented: $🄿resentNote) {
                        Button("🌏了解しました") {
                            print("Pressed OK button.")
                        }
                    } message: {
                        Text("🌏広告説明文")
                    }
                    
                    Button {
                        🄿resentAdBanner = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                            .font(.body.weight(.heavy))
                            .grayscale(1)
                            .minimumScaleFactor(0.1)
                    }
                }
                .transition(.move(edge: .bottom))
                .padding(6)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(.systemBackground))
                        .opacity(0.7)
                }
                .padding(.bottom, 100)
            }
        }
        .animation(.easeIn, value: 🄿resentAdBanner)
        .appStoreOverlay(isPresented: $🄿resentAdBanner) {
            SKOverlay.AppConfiguration(appIdentifier: 🆔, position: .bottom)
        }
        .task {
            🄻aunchCount += 1
            if 🄻aunchCount % 6 == 0 {
                🄿resentAdBanner = true
            }
        }
    }
}




struct 広告AD_Previews: PreviewProvider {
    static var previews: some View {
        広告AD()
    }
}
