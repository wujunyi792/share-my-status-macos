import SwiftUI
import AppKit

struct AppInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
}

class ApplicationScanner: ObservableObject {
    @Published var runningApplications: [AppInfo] = []

    func scan() {
        DispatchQueue.global(qos: .userInitiated).async {
            var applications: [AppInfo] = []
            let fileManager = FileManager.default
            
            let applicationDirectoryURLs = fileManager.urls(for: .applicationDirectory, in: .allDomainsMask)

            for url in applicationDirectoryURLs {
                guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil) else { continue }
                
                for case let fileURL as URL in enumerator {
                    if fileURL.pathExtension == "app" {
                        if let bundle = Bundle(url: fileURL), let bundleId = bundle.bundleIdentifier {
                            if !applications.contains(where: { $0.bundleIdentifier == bundleId }) {
                                let name = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? fileURL.deletingPathExtension().lastPathComponent
                                let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
                                let appInfo = AppInfo(name: name, bundleIdentifier: bundleId, icon: icon)
                                applications.append(appInfo)
                            }
                        }
                        enumerator.skipDescendants()
                    }
                }
            }
            
            let sortedApps = applications.sorted { $0.name.lowercased() < $1.name.lowercased() }
            
            DispatchQueue.main.async {
                self.runningApplications = sortedApps
            }
        }
    }
}

struct AppPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var scanner = ApplicationScanner()
    @Binding var blacklist: [String]
    @State private var searchText = ""

    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return scanner.runningApplications
        } else {
            return scanner.runningApplications.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.bundleIdentifier.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            Text("选择要加入黑名单的应用")
                .font(.title)
                .padding()

            TextField("搜索应用...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            List(filteredApps) { app in
                HStack {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .cornerRadius(4)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 32, height: 32)
                            .cornerRadius(4)
                    }
                    VStack(alignment: .leading) {
                        Text(app.name).font(.headline)
                        Text(app.bundleIdentifier).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    if blacklist.contains(app.bundleIdentifier) {
                        Button("移除") {
                            blacklist.removeAll { $0 == app.bundleIdentifier }
                        }
                    } else {
                        Button("添加") {
                            blacklist.append(app.bundleIdentifier)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .onAppear {
                scanner.scan()
            }

            HStack {
                Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .frame(width: 500, height: 600)
    }
}