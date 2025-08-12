import SwiftUI

struct CustomLinkView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel
    @State private var baseUrl: String = ""
    @State private var redirectUrl: String = ""
    @State private var displayFormat: String = "{artist}的{title}"
    @State private var customizedUrl: String = ""
    @State private var previewText: String = ""
    
    private var isValidBaseUrl: Bool {
        return LinkUtility.isValidBaseUrl(baseUrl)
    }
    
    private var isValidRedirectUrl: Bool {
        return LinkUtility.isValidRedirectUrl(redirectUrl)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("飞书链接定制工具")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("本工具可以帮助你创建包含音乐信息的定制链接。设置完成后，系统会自动生成一个链接，粘贴进飞书个性签名后会看到你设置的文字内容，点击可以跳转到指定网址。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("基础链接")
                        .font(.headline)
                    Text("基础链接可以通过飞书机器人获取")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    TextField("输入基础链接 (支持任何https://或http://开头的链接，且包含u参数)", text: $baseUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: baseUrl) { newValue in
                            parseUrlAndUpdateFields(newValue)
                            updateCustomizedUrl()
                        }
                    if !baseUrl.isEmpty && !isValidBaseUrl {
                        Text("基础链接必须以 https:// 或 http:// 开头，并且包含 u 参数。")
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
                            updatePreview()
                        }
                    
                    // 占位符快捷插入按钮
                    HStack(spacing: 8) {
                        Text("快捷插入:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("艺术家") {
                            insertPlaceholder("{artist}")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("标题") {
                            insertPlaceholder("{title}")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("专辑") {
                            insertPlaceholder("{album}")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    Text("支持的占位符: {artist}, {title}, {album}")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览效果")
                        .font(.headline)
                    Text("实时预览当前设置下链接会显示的文字内容。需要先播放音乐才能看到效果。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

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
                    Text("系统根据你的设置自动生成的完整链接。包含所有参数，可以直接复制到飞书个性签名使用。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
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
    
    private func insertPlaceholder(_ placeholder: String) {
        // 获取当前光标位置并插入占位符
        displayFormat += placeholder
        updateCustomizedUrl()
        updatePreview()
    }
    
    private func parseUrlAndUpdateFields(_ url: String) {
        guard !url.isEmpty else { return }
        
        // 尝试解析URL中的r和m参数
        if let urlComponents = URLComponents(string: url) {
            let queryItems = urlComponents.queryItems ?? []
            
            // 查找r参数 (redirect)
            if let rValue = queryItems.first(where: { $0.name == "r" })?.value,
               let decodedR = rValue.removingPercentEncoding {
                redirectUrl = decodedR
            }
            
            // 查找m参数 (mark)
            if let mValue = queryItems.first(where: { $0.name == "m" })?.value,
               let decodedM = mValue.removingPercentEncoding {
                displayFormat = decodedM
            }
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