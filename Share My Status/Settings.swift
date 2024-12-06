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
    
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.endpointURL = UserDefaults.standard.string(forKey: "endpointURL") ?? ""
    }
} 
