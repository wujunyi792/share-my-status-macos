//
//  Share_My_StatusApp.swift
//  Share My Status
//
//  Created by 吴骏逸 on 2024/12/5.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.windows.forEach { window in
            window.delegate = self
        }
    }
    
    func showMainWindow() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.center()
        }
    }
}

@main
struct Share_My_StatusApp: App {
    @StateObject private var settings = Settings()
    @StateObject private var nowPlayingVM: NowPlayingViewModel
    @State private var showMainWindow = true
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var latestReport: MusicData? {
        return nowPlayingVM.reportHistory.first
    }
    
    init() {
        let settingsInstance = Settings()
        _settings = StateObject(wrappedValue: settingsInstance)
        _nowPlayingVM = StateObject(wrappedValue: NowPlayingViewModel(settings: settingsInstance))
    }
    
    var body: some Scene {
        WindowGroup {
            if showMainWindow {
                ContentView(nowPlayingVM: nowPlayingVM)
                    .environmentObject(settings)
                    .onAppear {
                        NSApplication.shared.setActivationPolicy(.regular)
                        DispatchQueue.main.async {
                            NSApp.windows.forEach { window in
                                window.delegate = appDelegate
                            }
                        }
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 500, height: 400)
        
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 8) {
                Text("当前播放")
                    .font(.headline)
                
                HStack {
                    if let artwork = nowPlayingVM.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(nowPlayingVM.title)
                            .font(.system(size: 14, weight: .medium))
                        Text(nowPlayingVM.artist)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                if let latestReport {
                    VStack(alignment: .leading) {
                        Text("最新上报结果")
                            .font(.headline)
                        Text("时间: \(latestReport.timestamp ?? "未知")")
                        Text("结果: \(latestReport.result ?? "未知")")
                            .foregroundColor(latestReport.result == "failed" ? .red : .green)
                    }
                }
                
                Divider()
                
                Button("显示主窗口") {
                    showMainWindow = true
                    appDelegate.showMainWindow()
                }
                
                Divider()
            }
            .padding()
            .frame(width: 300)
        } label: {
            Image(systemName: "music.note")
        }
        .menuBarExtraStyle(.window)
    }
}
