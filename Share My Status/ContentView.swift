//
//  ContentView.swift
//  Share My Status
//
//  Created by 吴骏逸 on 2024/12/5.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: Settings
    @ObservedObject var nowPlayingVM: NowPlayingViewModel
    @State private var selectedTab = 0

    init(nowPlayingVM: NowPlayingViewModel) {
        self.nowPlayingVM = nowPlayingVM
    }
    
    // Setup observer for tab selection notification
    private func setupTabSelectionObserver() {
        NotificationCenter.default.addObserver(forName: Notification.Name("SetSelectedTab"), object: nil, queue: .main) { notification in
            if let selectedTab = notification.userInfo?["selectedTab"] as? Int {
                self.selectedTab = selectedTab
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            TabView(selection: $selectedTab) {
                nowPlayingTab
                    .tabItem {
                        Label("正在播放", systemImage: "music.note")
                    }
                    .tag(0)

                CustomLinkView(nowPlayingVM: nowPlayingVM)
                    .tabItem {
                        Label("链接定制", systemImage: "link")
                    }
                    .tag(1)

                SettingsView(settings: settings)
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
                    .tag(2)

                ReportHistoryView(nowPlayingVM: nowPlayingVM)
                    .tabItem {
                        Label("上报历史", systemImage: "clock.fill")
                    }
                    .tag(3)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear {
            setupTabSelectionObserver()
        }
    }

    private var nowPlayingTab: some View {
        VStack {
            VStack(spacing: 15) {

                reportingControlsView

                if nowPlayingVM.title.isEmpty || nowPlayingVM.artist.isEmpty || nowPlayingVM.title == "未知标题" {
                    emptyStateView
                } else {
                    nowPlayingCard
                }
                appToolboxView
            }
            .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }

    private var nowPlayingCard: some View {
        HStack(spacing: 20) {
            artworkView
            
            VStack(alignment: .leading, spacing: 8) {
                Text(nowPlayingVM.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(nowPlayingVM.artist)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text(nowPlayingVM.album)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("时长: \(nowPlayingVM.duration)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Material.ultraThin)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var appToolboxView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("工具箱")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ToolItemView(
                    title: "飞书签名定制",
                    icon: "link.badge.plus",
                    color: .blue,
                    action: {
                        selectedTab = 1  // Switch to Link Customization tab
                    }
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Material.ultraThin)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.08), lineWidth: 0.5)
        )
    }

    private struct ToolItemView: View {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(color.opacity(0.15), lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: true)
        }
    }

    private var artworkView: some View {
        Group {
            if let artwork = nowPlayingVM.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(radius: 4)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "music.mic")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("当前没有播放音乐")
                .font(.title2)
                .fontWeight(.medium)
            Text("请在任何音乐应用中播放一首歌曲，这里将显示相关信息。")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Material.ultraThin)
        )
    }

    private var reportingControlsView: some View {
        HStack {
            Text("正在播放：")
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle(isOn: $settings.isReportingEnabled) {
                Text("开启音乐状态上报")
                    .font(.body)
            }
            .toggleStyle(.switch)
            .controlSize(.large)
        }
        .padding(.horizontal, 0)
    }
}

