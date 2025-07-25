import Foundation
import SwiftUI
import Combine

struct MediaInfo: Codable {
    let artist: String?
    let title: String?
    let album: String?
    let duration: Double?
    let elapsedTime: Double?
    let playing: Bool?
    let bundleIdentifier: String?
    let playbackRate: Double?
    let artworkMimeType: String?
    let artworkData: String?
}

class NowPlayingViewModel: ObservableObject {
    @Published var artist: String = "未知艺术家"
    @Published var title: String = "未知标题"
    @Published var album: String = "未知专辑"
    @Published var duration: String = "未知时长"
    @Published var artwork: NSImage? = nil
    @Published var source: String = "未知来源"
    @Published var reportHistory: [MusicData] = []

    private var timer: DispatchSourceTimer?
    private var settings: Settings
    private var previousTitle: String = ""
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600)
        return formatter
    }()
    
    init(settings: Settings) {
        self.settings = settings
        startMonitoring()
    }

    func updateSettings(_ newSettings: Settings) {
        self.settings = newSettings
    }
    
    deinit {
        timer?.cancel()
    }
    
    func startMonitoring() {
        let queue = DispatchQueue(label: "com.yourapp.nowplaying", qos: .background)
        let dispatchTimer = DispatchSource.makeTimerSource(queue: queue)
        dispatchTimer.schedule(deadline: .now(), repeating: 5.0)
        dispatchTimer.setEventHandler { [weak self] in
            self?.fetchNowPlayingInfo()
        }
        dispatchTimer.resume()
        self.timer = dispatchTimer
    }
    
    func fetchNowPlayingInfo() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let bundle = Bundle.main.bundlePath
            let perlScriptPath = "\(bundle)/Contents/Resources/mediaremote-adapter.pl"
            let frameworkPath = "\(bundle)/Contents/Frameworks/MediaRemoteAdapter.framework"
            
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: perlScriptPath) || !fileManager.fileExists(atPath: frameworkPath) {
                return
            }
            
            let task = Process()
            task.launchPath = "/usr/bin/perl"
            task.arguments = [perlScriptPath, frameworkPath, "get"]
            let pipe = Pipe()
            task.standardOutput = pipe
            
            do {
                try task.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                task.waitUntilExit()

                let decoder = JSONDecoder()
                if let mediaInfo = try? decoder.decode(MediaInfo.self, from: data) {
                    if let bundleIdentifier = mediaInfo.bundleIdentifier, self.settings.blacklist.contains(bundleIdentifier) {
                        return
                    }
                    DispatchQueue.main.async {
                        self.artist = mediaInfo.artist ?? "未知艺术家"
                        self.title = mediaInfo.title ?? "未知标题"
                        self.album = mediaInfo.album ?? "未知专辑"
                        self.source = mediaInfo.bundleIdentifier ?? "未知来源"
                        if let duration = mediaInfo.duration {
                            let formatter = DateComponentsFormatter()
                            formatter.allowedUnits = [.minute, .second]
                            formatter.unitsStyle = .positional
                            formatter.zeroFormattingBehavior = .pad
                            self.duration = formatter.string(from: TimeInterval(duration)) ?? "未知时长"
                        } else {
                            self.duration = "未知时长"
                        }
                        if let artworkBase64 = mediaInfo.artworkData,
                           let artworkData = Data(base64Encoded: artworkBase64) {
                            self.artwork = NSImage(data: artworkData)
                        } else {
                            self.artwork = nil
                        }

                        self.sendMusicUpdate()
                    }
                }
            } catch {
                NSLog("Failed to run perl script: \(error)")
            }
        }
    }
    
    private func sendMusicUpdate() {
        guard settings.isReportingEnabled, title != previousTitle && title != "未知标题" else {
            return
        }
        
        previousTitle = title
        
        let artworkBase64: String
        if let artwork = artwork,
           let tiffData = artwork.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let jpegData = bitmapImage.representation(using: .jpeg, properties: [:]) {
            artworkBase64 = jpegData.base64EncodedString()
        } else {
            artworkBase64 = ""
        }
        
        let initialMusicData = MusicData(
            artist: artist,
            title: title,
            album: album,
            duration: duration,
            artwork: artworkBase64,
            timestamp: timeFormatter.string(from: Date()),
            result: nil,
            errorMessage: nil,
            source: source
        )
        
        Task {
            let musicData = initialMusicData
            var result: MusicData
            do {
                try await NetworkService.shared.sendMusicActivity(settings: settings, musicData: musicData)
                result = MusicData(
                    artist: musicData.artist,
                    title: musicData.title,
                    album: musicData.album,
                    duration: musicData.duration,
                    artwork: musicData.artwork,
                    timestamp: musicData.timestamp,
                    result: "success",
                    errorMessage: nil,
                    source: musicData.source
                )
            } catch {
                print("发送音乐更新失败: \(error)")
                result = MusicData(
                    artist: musicData.artist,
                    title: musicData.title,
                    album: musicData.album,
                    duration: musicData.duration,
                    artwork: musicData.artwork,
                    timestamp: musicData.timestamp,
                    result: "failed",
                    errorMessage: error.localizedDescription,
                    source: musicData.source
                )
            }
            
            await MainActor.run {
                self.reportHistory.insert(result, at: 0)
                if self.reportHistory.count > 100 {
                    self.reportHistory.removeLast()
                }
            }
        }
    }
}
