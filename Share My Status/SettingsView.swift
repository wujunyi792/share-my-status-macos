import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @State private var tempAPIKey: String = ""
    @State private var tempEndpointURL: String = ""
    @State private var tempIsReportingEnabled: Bool = true
    @State private var tempBlacklistArray: [String] = []
    @State private var showSaveSuccess: Bool = false
    @State private var urlValidationMessage: String = ""
    @State private var showingAppPicker = false
    @State private var showingResetAlert = false
    @State private var showingRestoreDefaultAlert = false
    @State private var isBlacklistExpanded = true
    @State private var hasChanges: Bool = false

    private var tempBlacklistBinding: Binding<String> {
        Binding<String>(
            get: { self.tempBlacklistArray.joined(separator: "\n") },
            set: { self.tempBlacklistArray = $0.split(whereSeparator: \.isNewline).map(String.init) }
        )
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                apiConfigSection
                blacklistSection
            }
            .padding(40)

            if showSaveSuccess {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    Text("保存成功")
                        .font(.headline)
                }
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)
                .transition(.opacity)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear(perform: loadSettings)
        .onChange(of: tempEndpointURL) { newValue in validateURL(newValue) }
        .onChange(of: tempAPIKey) { _ in checkForChanges() }
        .onChange(of: tempEndpointURL) { _ in checkForChanges() }
        .onChange(of: tempBlacklistArray) { _ in checkForChanges() }
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView(blacklist: $tempBlacklistArray)
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 40)
        
        }
        .alert("确认撤销编辑？", isPresented: $showingResetAlert) {
            Button("撤销", role: .destructive, action: resetSettings)
            Button("取消", role: .cancel) { }
        }
        .alert("确认恢复默认值？", isPresented: $showingRestoreDefaultAlert) {
            Button("恢复", role: .destructive, action: restoreDefaultBlacklist)
            Button("取消", role: .cancel) { }
        } message: {
            Text("这将恢复系统的初始黑名单配置")
        }
    }

    private var apiConfigSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("API Key")
                        .font(.callout)
                        .foregroundColor(.primary.opacity(0.8))
                    .foregroundColor(.secondary)
                TextField("请输入您的 API Key", text: $tempAPIKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Endpoint URL (HTTPS)")
                    .foregroundColor(.primary.opacity(0.8))
                    .font(.callout)
                    .foregroundColor(.secondary)
                TextField("请输入服务器地址", text: $tempEndpointURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if !urlValidationMessage.isEmpty {
                    Text(urlValidationMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 10)
    } label: {
        Text("API 配置")
            .foregroundColor(.primary.opacity(0.9))
            .font(.headline)
    }
    }

    private var blacklistSection: some View {
        DisclosureGroup(isExpanded: $isBlacklistExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                Text("来自这些应用程序的播放信息将不会被上报")
                    .font(.system(size: 12))
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: tempBlacklistBinding)
                    .frame(height: 100)
                    .border(Color.gray.opacity(0.2), width: 1)
                    .cornerRadius(6)
                    .font(Font.system(.body).monospaced())
            }
            .padding(.vertical, 10)
        } label: {
            HStack {
                Text("黑名单配置")
                    .foregroundColor(.primary.opacity(0.9))
                    .font(.headline)
                    
                Spacer()
                Button {
                    showingRestoreDefaultAlert = true
                } label: {
                    Label("恢复默认值", systemImage: "arrow.clockwise")
                        .controlSize(.small)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button {
                    showingAppPicker = true
                } label: {
                    Label("从已安装的应用选择", systemImage: "plus.circle.fill")
                        .controlSize(.large)
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack {
            Button(action: {
                showingResetAlert = true
            }) {
                Text("撤销")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!hasChanges)
            .tint(.red)

            Button(action: saveSettings) {
                Text("保存")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(tempEndpointURL.isEmpty || tempAPIKey.isEmpty || !urlValidationMessage.isEmpty || !hasChanges)
        }
    }

    private func loadSettings() {
        tempAPIKey = settings.apiKey
        tempEndpointURL = settings.endpointURL
        tempBlacklistArray = settings.blacklist
        validateURL(tempEndpointURL)
        hasChanges = false
    }

    private func validateURL(_ url: String) {
        if url.isEmpty {
            urlValidationMessage = "URL 不能为空"
            return
        }
        guard let url = URL(string: url) else {
            urlValidationMessage = "无效的 URL 格式"
            return
        }
        if url.scheme?.lowercased() != "https" {
            urlValidationMessage = "URL 必须使用 HTTPS 协议"
        } else {
            urlValidationMessage = ""
        }
    }

    private func saveSettings() {
        settings.apiKey = tempAPIKey
        settings.endpointURL = tempEndpointURL
        settings.blacklist = tempBlacklistArray
        hasChanges = false

        withAnimation {
            showSaveSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }

    private func checkForChanges() {
        hasChanges = tempAPIKey != settings.apiKey ||
                    tempEndpointURL != settings.endpointURL ||
                    tempBlacklistArray != settings.blacklist
    }

    private func restoreDefaultBlacklist() {
        tempBlacklistArray = ["com.apple.Safari", "com.google.Chrome", "com.mozilla.firefox", "com.microsoft.Edge", "com.operasoftware.Opera", "com.brave.Browser", "com.vivaldi.Vivaldi"]
        checkForChanges()
    }

    private func resetSettings() {
        loadSettings()
    }
}

#Preview {
    SettingsView(settings: Settings())
}
