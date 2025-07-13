import SwiftUI

struct ReportHistoryView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel

    var body: some View {
        VStack(alignment: .leading) {


            if nowPlayingVM.reportHistory.isEmpty {
                emptyHistoryView
            } else {
                historyListView
            }
        }
    }

    private var historyListView: some View {
        List {
            Section(header: historyHeader) {
                ForEach(nowPlayingVM.reportHistory.prefix(100)) { report in
                    ReportRow(report: report)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .frame(maxHeight: 300)
    }

    private var historyHeader: some View {
        HStack {
            Text("时间").frame(width: 80, alignment: .center)
            Text("曲名").frame(maxWidth: .infinity, alignment: .center)
            Text("艺术家").frame(maxWidth: .infinity, alignment: .center)
            Text("来源").frame(maxWidth: .infinity, alignment: .center)
            Text("状态").frame(width: 80, alignment: .center)
        }
        .padding(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 12))
        .font(.headline.bold())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    }
    

    private var emptyHistoryView: some View {
        VStack {
            Image(systemName: "tray.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            Text("暂无上报记录")
                .font(.title3)
            Text("当有新的播放信息上报后，这里将显示历史记录。")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ReportRow: View {
    let report: MusicData

    var body: some View {
        HStack {
            Text(report.timestamp ?? "N/A")
                .frame(width: 80, alignment: .center)
                .lineLimit(1)
            Text(report.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
            Text(report.artist)
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
            Text(report.source ?? "N/A")
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)
            statusView
                .frame(width: 80, alignment: .center)
        }
        .padding(.vertical, 2)
        .font(.system(size: 13))
        .foregroundColor(.primary.opacity(0.9))
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
