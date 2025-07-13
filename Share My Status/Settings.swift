import Foundation

class Settings: ObservableObject {
    @Published var apiKey: String {
        didSet {
            print("apiKey 已更新为: \(apiKey)")
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }
    
    @Published var endpointURL: String {
        didSet {
            print("endpointURL 已更新为: \(endpointURL)")
            UserDefaults.standard.set(endpointURL, forKey: "endpointURL")
        }
    }

    @Published var isReportingEnabled: Bool {
        didSet {
            print("isReportingEnabled 已更新为: \(isReportingEnabled)")
            UserDefaults.standard.set(isReportingEnabled, forKey: "isReportingEnabled")
        }
    }
    
    @Published var blacklist: [String] {
        didSet {
            print("blacklist 已更新为: \(blacklist)")
            UserDefaults.standard.set(blacklist, forKey: "blacklist")
        }
    }
    
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.endpointURL = UserDefaults.standard.string(forKey: "endpointURL") ?? ""
        self.isReportingEnabled = UserDefaults.standard.object(forKey: "isReportingEnabled") as? Bool ?? true
        self.blacklist = UserDefaults.standard.stringArray(forKey: "blacklist") ?? ["com.apple.Safari", "com.google.Chrome", "com.mozilla.firefox", "com.microsoft.Edge", "com.operasoftware.Opera", "com.brave.Browser", "com.vivaldi.Vivaldi"]
    }
}
