import SwiftUI

struct ReportHistoryView: View {
    @ObservedObject var nowPlayingVM: NowPlayingViewModel
    let titles = ["时间", "专辑", "曲名", "艺术家", "上报结果"]

    var body: some View {
        List {
            // 表头
            HStack {
                ForEach(titles, id: \.self) { title in
                    Text(title)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }

            // 表格内容
            ForEach(nowPlayingVM.reportHistory.prefix(100), id: \.self) { report in
                HStack {
                    Group {
                        HoverText(text: report.timestamp ?? "未知")
                        HoverText(text: report.album)
                        HoverText(text: report.title)
                        HoverText(text: report.artist)
                        if report.result == "failed" {
                            HoverText(text: report.errorMessage ?? "未知错误")
                                .foregroundColor(.red)
                        } else {
                            HoverText(text: report.result ?? "未知")
                                .foregroundColor(.green)
                        }
                    }
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("上报历史")
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
