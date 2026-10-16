import SwiftUI

struct ℹ️AboutAppMenu: View {
    var body: some View {
        List {
            🖼️IconAndName()
            🏬AppStoreLink()
            👤PrivacyPolicyLink()
            📓SourceCodeLink()
        }
        .navigationTitle(Text("About App", tableName: "🌐AboutApp"))
    }
}

private struct 🖼️IconAndName: View {
    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 8) {
                Image(.aboutAppIcon)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                VStack(spacing: 6) {
                    Text(🗒️StaticInfo.appName)
                        .font(.system(.headline))
                        .tracking(1.5)
                        .opacity(0.75)
                    Text(🗒️StaticInfo.appSubTitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .lineLimit(2)
                .minimumScaleFactor(0.1)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 16)
        }
    }
}

private struct 🏬AppStoreLink: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        Section {
            Button {
                self.openURL(🗒️StaticInfo.appStoreProductURL)
            } label: {
                LabeledContent {
                    Image(systemName: "arrow.up.forward.app")
                } label: {
                    Label(String(localized: "Open App Store page", table: "🌐AboutApp"),
                          systemImage: "link")
                }
            }
        }
    }
}

private struct 👤PrivacyPolicyLink: View {
    var body: some View {
        Section {
            NavigationLink {
                ScrollView {
                    Text(🗒️StaticInfo.privacyPolicyDescription)
                        .padding()
                }
                .navigationTitle(Text("Privacy Policy", tableName: "🌐AboutApp"))
            } label: {
                Label(String(localized: "Privacy Policy", table: "🌐AboutApp"),
                      systemImage: "person.text.rectangle")
            }
        }
    }
}

private struct 📓SourceCodeLink: View {
    var body: some View {
        NavigationLink {
            List {
                ForEach(🗒️StaticInfo.SourceCodeCategory.allCases) { Self.CodeSection($0) }
                self.bundleMainInfoDictionary()
            }
            .navigationTitle(Text("Source code", tableName: "🌐AboutApp"))
        } label: {
            Label(String(localized: "Source code", table: "🌐AboutApp"),
                  systemImage: "doc.plaintext")
        }
    }
    private struct CodeSection: View {
        private var category: 🗒️StaticInfo.SourceCodeCategory
        private var url: URL {
            Bundle.main.bundleURL.appendingPathComponent("📁SourceCode")
        }
        var body: some View {
            Section {
                ForEach(self.category.fileNames, id: \.self) { ⓕileName in
                    if let ⓒode = try? String(contentsOf: self.url.appendingPathComponent(ⓕileName), encoding: .utf8) {
                        NavigationLink(ⓕileName) { self.sourceCodeView(ⓒode, ⓕileName) }
                    } else {
                        Text(verbatim: "🐛")
                    }
                }
                if self.category.fileNames.isEmpty { Text(verbatim: "🐛") }
            } header: {
                Text(self.category.rawValue)
                    .textCase(.none)
            }
        }
        init(_ category: 🗒️StaticInfo.SourceCodeCategory) {
            self.category = category
        }
        private func sourceCodeView(_ ⓣext: String, _ ⓣitle: String) -> some View {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(ⓣext)
                        .font(.footnote.monospaced())
                        .padding()
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .navigationBarTitle(LocalizedStringKey(ⓣitle))
        }
    }
    private func bundleMainInfoDictionary() -> some View {
        Section {
            NavigationLink(String("Bundle.main.infoDictionary")) {
                List {
                    if let ⓓictionary = Bundle.main.infoDictionary {
                        ForEach(ⓓictionary.map({$0.key}), id: \.self) {
                            LabeledContent($0, value: String(describing: ⓓictionary[$0] ?? "🐛"))
                        }
                    }
                }
                .navigationBarTitle(Text(verbatim: "Bundle.main.infoDictionary"))
            }
        }
    }
}
