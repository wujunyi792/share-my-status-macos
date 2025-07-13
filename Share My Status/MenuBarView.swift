import SwiftUI

struct MenuBarView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel
    @ObservedObject var settings: Settings
    var appDelegate: AppDelegate

    private var latestReport: MusicData? {
        return nowPlayingVM.reportHistory.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            nowPlayingSection
            Divider()
            latestReportSection
            Divider()
            controlsSection
        }
        .padding(12)
        .frame(width: 320)
    }

    private var nowPlayingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("当前播放")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)

            HStack(spacing: 10) {
                if let artwork = nowPlayingVM.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Material.regular)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundColor(.secondary)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(nowPlayingVM.title.isEmpty ? "-" : nowPlayingVM.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Text(nowPlayingVM.artist.isEmpty ? "-" : nowPlayingVM.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    private var latestReportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最新上报结果")
                .font(.system(size: 16, weight: .bold))

            if let latestReport = latestReport {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("时间:")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(latestReport.timestamp ?? "未知")
                            .font(.system(size: 14))
                    }
                    HStack {
                        Text("结果:")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(latestReport.result ?? "未知")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(latestReport.result == "failed" ? .red : Color(nsColor: .systemGreen))
                    }
                }
            } else {
                Text("暂无上报记录")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 10) {
            Toggle(isOn: $settings.isReportingEnabled) {
                Text("开启音乐上报")
                    .font(.system(size: 14))
            }
            .toggleStyle(.switch)

            Button(action: {
                appDelegate.showMainWindow()
            }) {
                HStack {
                    Image(systemName: "display")
                    Text("显示主窗口")
                }
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
}