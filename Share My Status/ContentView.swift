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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 播放信息标签页
            VStack(alignment: .leading, spacing: 10) {
                Text("当前播放信息")
                    .font(.headline)
                
                HStack {
                    if let artwork = nowPlayingVM.artwork {
                        Image(nsImage: artwork)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("艺术家: \(nowPlayingVM.artist)")
                        Text("标题: \(nowPlayingVM.title)")
                        Text("专辑: \(nowPlayingVM.album)")
                        Text("时长: \(nowPlayingVM.duration)")
                    }
                }
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("播放信息", systemImage: "music.note")
            }
            .tag(0)
            
            // 设置标签页
            SettingsView(settings: settings)
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
                .tag(1)

            // 上报历史标签页
            ReportHistoryView(nowPlayingVM: nowPlayingVM)
                .tabItem {
                    Label("上报历史", systemImage: "clock")
                }
                .tag(2)
        }
        .padding()
    }
}

