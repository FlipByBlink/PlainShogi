import SwiftUI

//struct 📣ADSheet: ViewModifier {
//    @EnvironmentObject var model: 🛒InAppPurchaseModel
//    @State private var app: 📣ADTargetApp = .pickUpAppWithout(.ONESELF)
//    @State private var showSheet: Bool = false
//    func body(content: Content) -> some View {
//        content
//            .sheet(isPresented: self.$showSheet) { 📣ADView(self.app) }
//            .onAppear { if self.model.checkToShowADSheet() { self.showSheet = true } }
//    }
//}

struct 📣ADView: View {
    @EnvironmentObject var model: 🛒InAppPurchaseModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) var dismiss
    @State private var disableDismiss: Bool = true
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    @State private var countDown: Int
    private var targetApp: 📣ADTargetApp
    @State private var showMenu: Bool = false
    var body: some View {
        NavigationStack { self.appADContent() }
            .presentationDetents([.height(640)])
#if os(iOS)
            .onChange(of: self.scenePhase) { if $0 == .background { self.dismiss() } }
            .onChange(of: self.model.purchased) { if $0 { self.disableDismiss = false } }
#else
            .onChange(of: self.scenePhase) { _, newValue in if newValue == .background { self.dismiss() } }
            .onChange(of: self.model.purchased) { _, newValue in if newValue { self.disableDismiss = false } }
#endif
            .interactiveDismissDisabled(self.disableDismiss)
            .onReceive(self.timer) { _ in
                if self.countDown > 1 {
                    self.countDown -= 1
                } else {
                    self.disableDismiss = false
                }
            }
#if os(iOS)
            .overlay(alignment: .top) { self.header() }
#endif
    }
    init(_ app: 📣ADTargetApp, second: Int) {
        self.targetApp = app
        self._countDown = State(initialValue: second)
    }
}

private extension 📣ADView {
    private func header() -> some View {
        HStack {
            if !self.showMenu {
                self.dismissButton()
                Spacer()
                self.menuLink()
            }
        }
        .font(.title3)
        .padding(.horizontal, 4)
        .animation(.default, value: self.disableDismiss)
        .animation(.default, value: self.showMenu)
    }
    private func appADContent() -> some View {
        Group {
            if self.verticalSizeClass == .compact {
                self.horizontalLayout()
            } else {
                self.verticalLayout()
            }
        }
        .modifier(Self.PurchasedEffect())
        .navigationTitle(.init("AD", tableName: "🌐AD&InAppPurchase"))
#if os(visionOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { self.dismissButton() }
            ToolbarItem(placement: .topBarTrailing) { self.menuLink() }
        }
#endif
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: self.$showMenu) { 🛒InAppPurchaseMenu() }
    }
    private func verticalLayout() -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)
            self.mockImage()
            Spacer(minLength: 0)
            self.appIcon()
            self.appName()
            Spacer(minLength: 0)
            self.appDescription()
            Spacer(minLength: 0)
            self.appStoreBadge()
            Spacer(minLength: 0)
        }
        .padding()
    }
    private func horizontalLayout() -> some View {
        HStack(spacing: 16) {
            self.mockImage()
            VStack(spacing: 12) {
                Spacer()
                self.appIcon()
                self.appName()
                self.appDescription()
                Spacer()
                self.appStoreBadge()
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding()
    }
    private func mockImage() -> some View {
        Link(destination: self.targetApp.url) {
            Image(self.targetApp.mockImageName)
                .resizable()
                .scaledToFit()
        }
        .accessibilityHidden(true)
        .disabled(self.model.purchased)
        .modifier(Self.HoverEffectDisabledForVisionOS())
    }
    private func appIcon() -> some View {
        Link(destination: self.targetApp.url) {
            HStack(spacing: 16) {
                Image(self.targetApp.iconImageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                if self.targetApp.isHealthKitApp {
                    Image(.appleHealthBadge)
                }
            }
        }
        .accessibilityHidden(true)
        .disabled(self.model.purchased)
        .modifier(Self.HoverEffectDisabledForVisionOS())
    }
    private func appName() -> some View {
        Link(destination: self.targetApp.url) {
            Text(self.targetApp.localizationKey, tableName: "🌐ADAppName")
                .font(.headline)
        }
        .buttonStyle(.plain)
        .accessibilityHidden(true)
        .disabled(self.model.purchased)
        .modifier(Self.HoverEffectDisabledForVisionOS())
    }
    private func appDescription() -> some View {
        Text(self.targetApp.localizationKey, tableName: "🌐ADAppDescription")
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .modifier(Self.HoverEffectDisabledForVisionOS())
    }
    private func appStoreBadge() -> some View {
        Link(destination: self.targetApp.url) {
            HStack(spacing: 6) {
                Image(.appstoreBadge)
                Image(systemName: "hand.point.up.left")
            }
            .foregroundColor(.primary)
            .padding(8)
        }
        .accessibilityLabel(Text("Open App Store page", tableName: "🌐AD&InAppPurchase"))
        .disabled(self.model.purchased)
    }
    private func menuLink() -> some View {
        Button {
            self.showMenu = true
        } label: {
#if os(visionOS)
            Image(systemName: "questionmark")
#else
            Image(systemName: "questionmark.circle")
                .padding(12)
#endif
        }
#if os(iOS)
        .tint(.primary)
#endif
        .accessibilityLabel(.init("About AD", tableName: "🌐AD&InAppPurchase"))
    }
    private func dismissButton() -> some View {
        Group {
            if self.disableDismiss {
                Image(systemName: "\(self.countDown).circle")
                    .foregroundStyle(.tertiary)
#if os(visionOS)
                    .font(.largeTitle.weight(.light))
                    .padding(.horizontal, 12)
#else
                    .padding(12)
#endif
            } else {
                Button {
                    self.dismiss()
#if os(iOS)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                } label: {
#if os(visionOS)
                    Image(systemName: "xmark")
#else
                    Image(systemName: "xmark.circle.fill")
                        .fontWeight(.medium)
                        .padding(12)
#endif
                }
                .keyboardShortcut(.cancelAction)
#if os(iOS)
                .tint(.primary)
#endif
                .accessibilityLabel(.init("Dismiss", tableName: "🌐AD&InAppPurchase"))
            }
        }
    }
    private struct PurchasedEffect: ViewModifier {
        @EnvironmentObject var model: 🛒InAppPurchaseModel
        func body(content: Content) -> some View {
            if self.model.purchased {
                content
                    .blur(radius: 6)
                    .overlay {
                        Image(systemName: "trash.square.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(5))
                            .shadow(radius: 8)
                    }
            } else {
                content
            }
        }
    }
    private struct HoverEffectDisabledForVisionOS: ViewModifier {
        func body(content: Content) -> some View {
#if os(visionOS)
            content.hoverEffectDisabled()
#else
            content
#endif
        }
    }
}
