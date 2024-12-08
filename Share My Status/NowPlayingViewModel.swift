import Foundation
import SwiftUI
import Combine

class NowPlayingViewModel: ObservableObject {
    @Published var artist: String = "未知艺术家"
    @Published var title: String = "未知标题"
    @Published var album: String = "未知专辑"
    @Published var duration: String = "未知时长"
    @Published var artwork: NSImage? = nil
    @Published var reportHistory: [MusicData] = []

    private var timer: DispatchSourceTimer?
    private var settings: Settings
    private var previousTitle: String = ""
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600) // 设置为东八区
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
        // 使用DispatchSourceTimer替代Timer，提供更好的性能和控制
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

            guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
                NSLog("无法加载 MediaRemote 框架")
                return
            }

            guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else {
                NSLog("无法获取 MRMediaRemoteGetNowPlayingInfo 函数指针")
                return
            }
            typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
            let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

            MRMediaRemoteGetNowPlayingInfo(DispatchQueue.global(qos: .background)) { [weak self] information in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    if let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
                        self.artist = artist
                    }
                    if let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
                        self.title = title
                    }
                    if let album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String {
                        self.album = album
                    }
                    if let duration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? String {
                        self.duration = duration
                    }
                    if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                        self.artwork = NSImage(data: artworkData)
                    }

                    self.sendMusicUpdate()
                }
            }
        }
    }
    
    private func sendMusicUpdate() {
        guard title != previousTitle && title != "未知标题" else {
            return
        }
//        print("DEBUG: 当前标题: \(title)")
        
        previousTitle = title
        
        // 将 NSImage 转换为 Base64 字符串
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
            errorMessage: nil
        )
        
        Task {
            let musicData = initialMusicData
            let result: MusicData
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
                    errorMessage: nil
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
                    errorMessage: error.localizedDescription
                )
            }
            
            // 添加到上报历史
            await MainActor.run {
                self.reportHistory.insert(result, at: 0)
                if self.reportHistory.count > 100 {
                    self.reportHistory.removeLast()
                }
            }
        }
    }
} 
