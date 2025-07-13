import SwiftUI

struct ReportHistoryView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("上报历史")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .leading], 20)
                .padding(.bottom, 10)

            if nowPlayingVM.reportHistory.isEmpty {
                emptyHistoryView
            } else {
                historyListView
            }
        }
        .background(Color(.windowBackgroundColor))
        .navigationTitle("上报历史")
    }

    private var historyListView: some View {
        List {
            Section(header: historyHeader) {
                ForEach(nowPlayingVM.reportHistory.prefix(100)) { report in
                    ReportRow(report: report)
                }
            }
        }
        .listStyle(.inset)
    }

    private var historyHeader: some View {
        HStack {
            Text("时间").frame(maxWidth: .infinity, alignment: .leading)
            Text("曲名").frame(maxWidth: .infinity, alignment: .leading)
            Text("艺术家").frame(maxWidth: .infinity, alignment: .leading)
            Text("状态").frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.headline)
        .padding(.horizontal)
    }

    private var emptyHistoryView: some View {
        VStack {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("暂无上报记录")
                .font(.title2)
                .padding(.top)
            Text("当有新的播放信息上报后，这里将显示历史记录。")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReportRow: View {
    let report: MusicData

    var body: some View {
        HStack {
            Text(report.timestamp ?? "N/A")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(report.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(report.artist)
                .frame(maxWidth: .infinity, alignment: .leading)
            statusView
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var statusView: some View {
        HStack(spacing: 5) {
            Image(systemName: report.result == "success" ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(report.result == "success" ? .green : .red)
            Text(report.result == "success" ? "成功" : "失败")
                .foregroundColor(report.result == "success" ? .green : .red)
        }
        .onTapGesture {
            if report.result != "success", let errorMessage = report.errorMessage {
                // 在这里可以实现点击查看详细错误信息的功能
            }
        }
    }
}

struct HoverText: View {
    let text: String
    @State private var isHovered = false

    var body: some View {
        Text(text)
            .background(isHovered ? Color.yellow.opacity(0.3) : Color.clear)
            .onHover { hovering in
                isHovered = hovering
            }
            .popover(isPresented: $isHovered) {
                Text(text)
                    .padding()
            }
    }
}
