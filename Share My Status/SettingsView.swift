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
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Key")
                            .bold()
                        Text("用于验证您的身份的密钥")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("请输入您的 API Key", text: $tempAPIKey)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Endpoint URL")
                            .bold()
                        Text("接收播放状态更新的服务器地址")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("请输入服务器地址", text: $tempEndpointURL)
                            .textFieldStyle(.roundedBorder)
                        if !urlValidationMessage.isEmpty {
                            Text(urlValidationMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Toggle(isOn: $tempIsReportingEnabled) {
                        VStack(alignment: .leading) {
                            Text("开启上报")
                                .bold()
                            Text("将当前播放的音乐信息上报给服务器")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Button(action: saveSettings) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("保存设置")
                            }
                        }
                        .disabled(tempEndpointURL.isEmpty || tempAPIKey.isEmpty)
                        
                        Button(action: resetSettings) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("重置")
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    if showSaveSuccess {
                        Text("设置已保存")
                            .font(.caption)
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                }
                .padding()
            } header: {
                Text("API 配置")
                    .font(.headline)
                    .padding(.bottom, 8)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("黑名单应用程序")
                        .bold()
                    Text("来自这些应用程序的播放信息将不会被上报。每行一个 Bundle ID。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: tempBlacklistBinding)
                        .frame(height: 100)
                        .border(Color.gray, width: 0.5)
                        .cornerRadius(5)
                    Button("从已安装的应用选择") {
                        showingAppPicker = true
                    }
                }
                .padding()
            } header: {
                Text("黑名单配置")
                    .font(.headline)
                    .padding(.bottom, 8)
            }
        }
        .frame(width: 400)
        .onAppear {
            tempAPIKey = settings.apiKey
            tempEndpointURL = settings.endpointURL
            tempIsReportingEnabled = settings.isReportingEnabled
            tempBlacklistArray = settings.blacklist
        }
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView(blacklist: $tempBlacklistArray)
        }
    }
    
    private func validateURL(_ url: String) {
        if url.isEmpty {
            urlValidationMessage = "URL 不能为空"
        } else if let url = URL(string: url) {
            if url.scheme?.lowercased() != "https" {
                urlValidationMessage = "URL 必须使用 HTTPS 协议"
            } else {
                urlValidationMessage = ""
            }
        } else {
            urlValidationMessage = "无效的 URL 格式"
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
        
        // 3秒后隐藏成功消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSaveSuccess = false
            }
        }
    }
    
    private func resetSettings() {
        tempAPIKey = settings.apiKey
        tempEndpointURL = settings.endpointURL
        tempIsReportingEnabled = settings.isReportingEnabled
        tempBlacklistArray = settings.blacklist
        urlValidationMessage = ""
    }
}

#Preview {
    SettingsView(settings: Settings())
}