import SwiftUI

struct ReportHistoryView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel
    @State private var showingErrorDetail = false
    @State private var selectedError: String = ""

    var body: some View {
        Group {
            if nowPlayingVM.reportHistory.isEmpty {
                emptyHistoryView
            } else {
                historyListView
            }
        }
        .alert("错误详情", isPresented: $showingErrorDetail) {
            Button("确定") { }
        } message: {
            Text(selectedError)
        }
    }

    private var historyListView: some View {
        VStack(spacing: 0) {
            historyHeader
            List {
                ForEach(nowPlayingVM.reportHistory.prefix(100)) { report in
                    ReportRow(report: report, showingErrorDetail: $showingErrorDetail, selectedError: $selectedError)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var historyHeader: some View {
        HStack {
            Text("时间").frame(width: 80, alignment: .center)
            Text("曲名").frame(maxWidth: .infinity, alignment: .center)
            Text("艺术家").frame(maxWidth: .infinity, alignment: .center)
            Text("来源").frame(maxWidth: .infinity, alignment: .center)
            Text("状态").frame(width: 80, alignment: .center)
        }
        .padding(EdgeInsets(top: 0, leading: 14, bottom: 8, trailing: 20))
        .font(.title2.bold())
    
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
    @Binding var showingErrorDetail: Bool
    @Binding var selectedError: String

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
        .font(.system(size: 15))
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
                selectedError = errorMessage
                showingErrorDetail = true
            }
        }
    }
}
