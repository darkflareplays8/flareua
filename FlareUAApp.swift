import SwiftUI
import Foundation

let flareHost = "flareua.pages.dev"
let flareURL = "https://\(flareHost)"

struct UserAgent: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ua: String
    var category: String
    var isCustom: Bool

    init(id: UUID = UUID(), name: String, ua: String, category: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.ua = ua
        self.category = category
        self.isCustom = isCustom
    }
}

let presetUserAgents: [UserAgent] = [
    UserAgent(name: "Chrome (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36", category: "Browsers"),
    UserAgent(name: "Chrome (Mac)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36", category: "Browsers"),
    UserAgent(name: "Chrome (Android)", ua: "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36", category: "Browsers"),
    UserAgent(name: "Safari (iPhone)", ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1", category: "Browsers"),
    UserAgent(name: "Safari (iPad)", ua: "Mozilla/5.0 (iPad; CPU OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1", category: "Browsers"),
    UserAgent(name: "Safari (Mac)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", category: "Browsers"),
    UserAgent(name: "Firefox (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:125.0) Gecko/20100101 Firefox/125.0", category: "Browsers"),
    UserAgent(name: "Firefox (Mac)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 14.4; rv:125.0) Gecko/20100101 Firefox/125.0", category: "Browsers"),
    UserAgent(name: "Edge (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0", category: "Browsers"),
    UserAgent(name: "Internet Explorer 11", ua: "Mozilla/5.0 (Windows NT 10.0; Trident/7.0; rv:11.0) like Gecko", category: "Browsers"),
    UserAgent(name: "Windows Phone", ua: "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)", category: "Browsers"),
    UserAgent(name: "BlackBerry", ua: "Mozilla/5.0 (BlackBerry; U; BlackBerry 9900; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.346 Mobile Safari/534.11+", category: "Browsers"),
    UserAgent(name: "Googlebot", ua: "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)", category: "Crawlers"),
    UserAgent(name: "Bingbot", ua: "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)", category: "Crawlers"),
    UserAgent(name: "GPTBot (OpenAI)", ua: "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.0; +https://openai.com/gptbot)", category: "Crawlers"),
    UserAgent(name: "DuckDuckBot", ua: "DuckDuckBot/1.0; (+http://duckduckgo.com/duckduckbot.html)", category: "Crawlers"),
    UserAgent(name: "Roblox Client", ua: "Roblox/WinInet", category: "Games"),
    UserAgent(name: "Roblox Mobile", ua: "ROBLOX Mobile/2.600 CFNetwork/1494.0.7 Darwin/23.4.0", category: "Games"),
    UserAgent(name: "Roblox Studio", ua: "RobloxStudio/WinInet", category: "Games"),
    UserAgent(name: "Minecraft (Java)", ua: "Minecraft Java/1.20.4", category: "Games"),
    UserAgent(name: "Minecraft (Bedrock)", ua: "libhttpclient/1.0.0.0", category: "Games"),
    UserAgent(name: "Steam", ua: "Valve/Steam HTTP Client 1.0 (tenfoot)", category: "Games"),
    UserAgent(name: "Discord", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) discord/1.0.9163 Chrome/120.0.6099.291 Electron/28.2.10 Safari/537.36", category: "Games"),
    UserAgent(name: "Epic Games Launcher", ua: "EpicGamesLauncher/13.2.0-25892386+++Portal+Release-Live", category: "Games"),
    UserAgent(name: "Fortnite", ua: "Fortnite/++Fortnite+Release-25.10-CL-26931287 Windows/10.0.22621.1.768.64bit", category: "Games"),
    UserAgent(name: "PlayStation 5", ua: "Mozilla/5.0 (PlayStation 5 4.01) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15", category: "Games"),
    UserAgent(name: "Xbox One", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586", category: "Games"),
    UserAgent(name: "Nintendo Switch", ua: "Mozilla/5.0 (Nintendo Switch; WifiWebAuthApplet) AppleWebKit/609.4 (KHTML, like Gecko) NF/6.0.2.21.3 NintendoBrowser/5.1.0.22023", category: "Games"),
]

class FlareUAStore: ObservableObject {
    @Published var customAgents: [UserAgent] = []
    @Published var activeAgent: UserAgent? = nil
    @Published var isProxyInstalled: Bool = false

    private let customKey = "flareua_custom"
    private let activeKey = "flareua_active"
    private let installedKey = "flareua_installed"

    init() {
        load()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: customKey),
           let decoded = try? JSONDecoder().decode([UserAgent].self, from: data) {
            customAgents = decoded
        }
        if let data = UserDefaults.standard.data(forKey: activeKey),
           let decoded = try? JSONDecoder().decode(UserAgent.self, from: data) {
            activeAgent = decoded
        }
        isProxyInstalled = UserDefaults.standard.bool(forKey: installedKey)
    }

    func save() {
        if let data = try? JSONEncoder().encode(customAgents) {
            UserDefaults.standard.set(data, forKey: customKey)
        }
        if let data = try? JSONEncoder().encode(activeAgent) {
            UserDefaults.standard.set(data, forKey: activeKey)
        }
        UserDefaults.standard.set(isProxyInstalled, forKey: installedKey)
    }

    func setActive(_ agent: UserAgent?) {
        activeAgent = agent
        save()
    }

    func addCustom(_ agent: UserAgent) {
        customAgents.append(agent)
        save()
    }

    func deleteCustom(_ agent: UserAgent) {
        customAgents.removeAll { $0.id == agent.id }
        if activeAgent?.id == agent.id { activeAgent = nil }
        save()
    }

    func generateMobileConfig() -> String {
        return """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.proxies.managed</string>
            <key>PayloadUUID</key>
            <string>B2C3D4E5-F6A7-8901-BCDE-F12345678901</string>
            <key>PayloadIdentifier</key>
            <string>com.flareua.proxy.managed</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>HTTPEnable</key>
            <integer>1</integer>
            <key>HTTPProxy</key>
            <string>\(flareHost)</string>
            <key>HTTPPort</key>
            <integer>443</integer>
            <key>HTTPSEnable</key>
            <integer>1</integer>
            <key>HTTPSProxy</key>
            <string>\(flareHost)</string>
            <key>HTTPSPort</key>
            <integer>443</integer>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>FlareUA Proxy</string>
    <key>PayloadIdentifier</key>
    <string>com.flareua.profile</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>C3D4E5F6-A7B8-9012-CDEF-123456789012</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadDescription</key>
    <string>Routes HTTP/HTTPS traffic through FlareUA for User-Agent rewriting.</string>
    <key>PayloadOrganization</key>
    <string>FlareUA</string>
</dict>
</plist>
"""
    }
}

struct ContentView: View {
    @StateObject var store = FlareUAStore()
    @State var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "shield.fill") }
                .tag(0)
            BrowseView()
                .tabItem { Label("Agents", systemImage: "list.bullet") }
                .tag(1)
            CustomView()
                .tabItem { Label("Custom", systemImage: "plus.circle.fill") }
                .tag(2)
            SettingsView()
                .tabItem { Label("About", systemImage: "info.circle.fill") }
                .tag(3)
        }
        .accentColor(.orange)
        .environmentObject(store)
    }
}

struct HomeView: View {
    @EnvironmentObject var store: FlareUAStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 8) {
                            Image(systemName: store.activeAgent != nil ? "shield.fill" : "shield.slash.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                            Text(store.activeAgent != nil ? "Active" : "Inactive")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            if let agent = store.activeAgent {
                                Text(agent.name)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.85))
                            } else {
                                Text("No agent selected")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(30)
                    }
                    .padding(.horizontal)

                    if let agent = store.activeAgent {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current UA String")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            Text(agent.ua)
                                .font(.system(size: 11, design: .monospaced))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }

                        Button(role: .destructive) {
                            store.setActive(nil)
                        } label: {
                            Label("Deactivate", systemImage: "xmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }

                    if !store.isProxyInstalled {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("Proxy profile not installed")
                                .font(.subheadline.bold())
                            Text("Go to About tab to install")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("FlareUA")
        }
    }
}

struct BrowseView: View {
    @EnvironmentObject var store: FlareUAStore
    @State var search = ""

    let categories = ["Browsers", "Crawlers", "Games"]

    var filteredPresets: [UserAgent] {
        if search.isEmpty { return presetUserAgents }
        return presetUserAgents.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.category.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationView {
            List {
                if !store.customAgents.isEmpty {
                    Section("Custom") {
                        ForEach(store.customAgents.filter {
                            search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)
                        }) { agent in
                            UARow(agent: agent)
                        }
                    }
                }
                ForEach(categories, id: \.self) { cat in
                    let items = filteredPresets.filter { $0.category == cat }
                    if !items.isEmpty {
                        Section(cat) {
                            ForEach(items) { agent in
                                UARow(agent: agent)
                            }
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Search agents...")
            .navigationTitle("Agents")
        }
    }
}

struct UARow: View {
    @EnvironmentObject var store: FlareUAStore
    let agent: UserAgent

    var isActive: Bool { store.activeAgent?.id == agent.id }

    var categoryIcon: String {
        switch agent.category {
        case "Crawlers": return "ant.fill"
        case "Games": return "gamecontroller.fill"
        default: return "globe"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: categoryIcon)
                .foregroundColor(.orange)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(agent.name)
                    .font(.subheadline.bold())
                Text(agent.ua)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            store.setActive(isActive ? nil : agent)
        }
        .swipeActions(edge: .trailing) {
            if agent.isCustom {
                Button(role: .destructive) {
                    store.deleteCustom(agent)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct CustomView: View {
    @EnvironmentObject var store: FlareUAStore
    @State var name = ""
    @State var ua = ""
    @State var showSaved = false

    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !ua.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("e.g. My Custom Browser", text: $name)
                }
                Section("User-Agent String") {
                    TextEditor(text: $ua)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(minHeight: 100)
                }
                Section {
                    Button {
                        let agent = UserAgent(name: name.trimmingCharacters(in: .whitespaces),
                                             ua: ua.trimmingCharacters(in: .whitespaces),
                                             category: "Custom",
                                             isCustom: true)
                        store.addCustom(agent)
                        name = ""
                        ua = ""
                        showSaved = true
                    } label: {
                        Label("Save Agent", systemImage: "plus.circle.fill")
                    }
                    .disabled(!canSave)
                }
                Section("Quick Fill") {
                    Button("Paste from clipboard") {
                        ua = UIPasteboard.general.string ?? ua
                    }
                    Button("Clear") {
                        name = ""
                        ua = ""
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Custom Agent")
            .alert("Agent Saved", isPresented: $showSaved) {
                Button("OK") {}
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: FlareUAStore
    @State var showInstallError = false
    @State var installErrorMsg = ""

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Proxy Profile"), footer: Text("Installs a system-wide proxy profile that routes all HTTP/HTTPS traffic through FlareUA.")) {
                    Button {
                        installMobileConfig()
                    } label: {
                        Label("Install Proxy Profile", systemImage: "arrow.down.circle.fill")
                            .foregroundColor(.orange)
                    }

                    Toggle("Profile installed", isOn: Binding(
                        get: { store.isProxyInstalled },
                        set: { store.isProxyInstalled = $0; store.save() }
                    ))
                }

                Section("About") {
                    LabeledContent("App", value: "FlareUA")
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Proxy", value: flareHost)
                }
            }
            .navigationTitle("About")
            .alert("Install Failed", isPresented: $showInstallError) {
                Button("OK") {}
            } message: {
                Text(installErrorMsg)
            }
        }
    }

    func installMobileConfig() {
        let config = store.generateMobileConfig()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("FlareUA.mobileconfig")

        do {
            try config.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
            installErrorMsg = "Failed to write profile: \(error.localizedDescription)"
            showInstallError = true
            return
        }

        UIApplication.shared.open(tempURL) { success in
            if success {
                DispatchQueue.main.async {
                    store.isProxyInstalled = true
                    store.save()
                }
            } else {
                DispatchQueue.main.async {
                    installErrorMsg = "iOS couldn't open the profile. Go to Settings > General > VPN & Device Management manually."
                    showInstallError = true
                }
            }
        }
    }
}

@main
struct FlareUAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
