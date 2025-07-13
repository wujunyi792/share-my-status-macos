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
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
        }
        
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 400, height: 550))
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
        .defaultSize(width: 400, height: 500)
        
        MenuBarExtra {
            MenuBarView(nowPlayingVM: nowPlayingVM, settings: settings, appDelegate: appDelegate)
        } label: {
            Image(systemName: "music.note")
        }
        .menuBarExtraStyle(.window)
    }
}
