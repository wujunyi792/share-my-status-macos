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

    private var tempBlacklistBinding: Binding<String> {
        Binding<String>(
            get: { self.tempBlacklistArray.joined(separator: "\n") },
            set: { self.tempBlacklistArray = $0.split(whereSeparator: \.isNewline).map(String.init) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                apiConfigSection
                blacklistSection
                Spacer()
                actionButtons
            }
            .padding(30)
        }
        .frame(minWidth: 480, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
        .navigationTitle("设置")
        .onAppear(perform: loadSettings)
        .onChange(of: tempEndpointURL, perform: validateURL)
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView(blacklist: $tempBlacklistArray)
        }
    }

    private var apiConfigSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("API 配置")
                .font(.headline)
                .padding(.bottom, -10)

            VStack(alignment: .leading, spacing: 5) {
                Text("API Key")
                    .font(.callout)
                    .foregroundColor(.secondary)
                TextField("请输入您的 API Key", text: $tempAPIKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Endpoint URL (HTTPS)")
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

            VStack(alignment: .leading, spacing: 4) {
                Toggle(isOn: $tempIsReportingEnabled) {
                    Text("开启音乐状态上报")
                        .font(.body)
                }
                .toggleStyle(.switch)
                .controlSize(.large)
                Text("当开启时，应用会自动将您正在播放的音乐信息上报到指定的服务器。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 24)
            }
        }
    }

    private var blacklistSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("黑名单配置")
                    .font(.headline)
                Spacer()
                Button {
                    showingAppPicker = true
                } label: {
                    Label("从已安装的应用选择", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
            }

            Text("来自这些应用程序的播放信息将不会被上报。每行一个 Bundle ID。")
                .font(.caption)
                .foregroundColor(.secondary)

            TextEditor(text: tempBlacklistBinding)
                .frame(minHeight: 100, maxHeight: 200)
                .border(Color.gray.opacity(0.2), width: 1)
                .cornerRadius(5)
                .font(Font.system(.body).monospaced())
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button(action: resetSettings) {
                    Text("重置")
                        .frame(minWidth: 80)
                        .padding()
                }
                .buttonStyle(.bordered)

                Button(action: saveSettings) {
                    Text("保存")
                        .frame(minWidth: 80)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(tempEndpointURL.isEmpty || tempAPIKey.isEmpty || !urlValidationMessage.isEmpty)
            }

            if showSaveSuccess {
                Text("设置已成功保存。")
                    .foregroundColor(.green)
                    .font(.caption)
                    .transition(.opacity)
                    .padding(.top, 5)
            }
        }
    }

    private func loadSettings() {
        tempAPIKey = settings.apiKey
        tempEndpointURL = settings.endpointURL
        tempIsReportingEnabled = settings.isReportingEnabled
        tempBlacklistArray = settings.blacklist
        validateURL(tempEndpointURL)
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
        settings.isReportingEnabled = tempIsReportingEnabled
        settings.blacklist = tempBlacklistArray

        withAnimation {
            showSaveSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }

    private func resetSettings() {
        loadSettings()
    }
}

#Preview {
    SettingsView(settings: Settings())
}