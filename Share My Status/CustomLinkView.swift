import SwiftUI

struct CustomLinkView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel
    @State private var baseUrl: String = ""
    @State private var redirectUrl: String = ""
    @State private var displayFormat: String = "{artist}的{title}"
    @State private var customizedUrl: String = ""
    @State private var previewText: String = ""
    
    private var isValidBaseUrl: Bool {
        LinkUtility.isValidBaseUrl(baseUrl)
    }
    
    private var isValidRedirectUrl: Bool {
        LinkUtility.isValidRedirectUrl(redirectUrl)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("链接定制工具")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("基础链接")
                        .font(.headline)
                    TextField("输入基础链接 (https://lark.mjclouds.com/link?u=...)", text: $baseUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: baseUrl) { _ in
                            updateCustomizedUrl()
                        }
                    if !baseUrl.isEmpty && !isValidBaseUrl {
                        Text("基础链接必须以 https://lark.mjclouds.com/link?u= 开头")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("点击后跳转链接 (可选)")
                        .font(.headline)
                    TextField("输入跳转链接 (必须以 http:// 或 https:// 开头)", text: $redirectUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: redirectUrl) { _ in
                            updateCustomizedUrl()
                        }
                    if !redirectUrl.isEmpty && !isValidRedirectUrl {
                        Text("跳转链接必须以 http:// 或 https:// 开头")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("显示文本格式")
                        .font(.headline)
                    TextField("输入显示文本格式", text: $displayFormat)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: displayFormat) { _ in
                            updateCustomizedUrl()
                        }
                    Text("支持的占位符: {artist}, {title}, {album}")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览效果")
                        .font(.headline)

                    if !nowPlayingVM.title.isEmpty && !nowPlayingVM.artist.isEmpty {
                        HStack {
                            Text("🎵")
                            Text(previewText)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    } else {
                        Text("播放音乐后将在此处显示预览效果")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("定制链接")
                        .font(.headline)
                    TextField("定制链接将显示在这里", text: $customizedUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                    
                    HStack {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(customizedUrl, forType: .string)
                        }) {
                            Label("复制链接", systemImage: "doc.on.doc")
                        }
                        .disabled(customizedUrl.isEmpty)
                        
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(customizedUrl, forType: .string)
                            
                            if let url = URL(string: customizedUrl) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Label("复制并打开", systemImage: "arrow.up.forward.app")
                        }
                        .disabled(customizedUrl.isEmpty)
                        
                        Spacer()
                        
                        Button(action: {
                            clearFields()
                        }) {
                            Label("清空", systemImage: "trash")
                        }
                        .disabled(baseUrl.isEmpty && redirectUrl.isEmpty && displayFormat == "{artist}的{title}")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            updatePreview()
        }
        .onChange(of: nowPlayingVM.title) { _ in
            updatePreview()
        }
        .onChange(of: nowPlayingVM.artist) { _ in
            updatePreview()
        }
        .onChange(of: nowPlayingVM.album) { _ in
            updatePreview()
        }
    }
    
    private func updateCustomizedUrl() {
        guard isValidBaseUrl else {
            customizedUrl = ""
            return
        }
        
        if let url = LinkUtility.createCustomizedUrl(baseUrl: baseUrl, redirectUrl: redirectUrl.isEmpty ? nil : redirectUrl, displayFormat: displayFormat) {
            customizedUrl = url
        } else {
            customizedUrl = ""
        }
        
        updatePreview()
    }
    
    private func updatePreview() {
        previewText = LinkUtility.formatDisplayText(format: displayFormat, artist: nowPlayingVM.artist, title: nowPlayingVM.title, album: nowPlayingVM.album)
    }
    
    private func clearFields() {
        baseUrl = ""
        redirectUrl = ""
        displayFormat = "{artist}的{title}"
        customizedUrl = ""
        updatePreview()
    }
}