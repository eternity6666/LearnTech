//
//  ScrollTextView.swift
//  Apple
//
//  Created by Y1616 on 2025/6/12.
//

import SwiftUI

extension String {
    func ifEmpty(_ block: @autoclosure () -> String) -> String {
        if self.isEmpty {
            return block()
        }
        return self
    }
}

@ViewBuilder
func SaveGIFButton(
    dirTitle: String,
    action: @escaping (URL) -> Void
) -> some View {
    Button {
        if let url = TopBottomViewModel.dirUrl(title: dirTitle.ifEmpty("\(Date.now.timeIntervalSince1970)")) {
            action(url)
        }
    } label: {
        Text("导出 GIF")
    }
}

struct ScrollTextView: View {
    @State
    private var textStr: String = ""
    private var textList: [String] {
        let list = textStr.split { char in
            ",，".contains(where: { char == $0})
        }.map({ String($0) })
        return !list.isEmpty ? list : [
            "太有石粒辣！！！",
            "干饭啦！干饭啦！",
            "太棒啦！太棒啦！",
            "有点东西！！！",
            "好的！好的！",
            "谢谢！谢谢！",
            "感谢！感谢！",
            "OK！！！",
            "下班了？下班啦！",
            "真可恶！真可恶！",
            "彳亍口巴",
            "干饭人！干饭魂！",
            "在吗？在吗？",
            "互联网太有意思了",
            "他急了！他急了！",
            "真行！真行！！"
        ]
    }
    private let frameCount: Int = 20
    @State
    private var frameIndex: Int = 0
    @State
    private var bgColor: Color = .init(red: 0.90, green: 0.90, blue: 0.90)
    private var progress: CGFloat {
        CGFloat(frameIndex) / CGFloat(frameCount)
    }
    private var delayTime: CGFloat {
        0.2 / Double(frameCount)
    }
    @State
    private var color: Color = .primary
    @State
    private var themeColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ColorPicker(selection: self.$color) {
                Text("颜色")
            }
            HStack {
                Text("个数\(self.textList.count)")
                let title = "就你会说"
                let subTitle = "就你会说！"
                SaveGIFButton(dirTitle: title) { url in
                    outputGIF(url)
                    outputPNG(url: url, text: title, size: .init(width: 500, height: 500))
                    outputPNG(url: url, text: subTitle, size: .init(width: 750, height: 400))
                    outputPNG(url: url, text: "谢谢你", size: .init(width: 750, height: 750))
                    outputPNG(url: url, text: "你若喜欢 给个赞吧", size: .init(width: 750, height: 560))
                }
            }
            Preview()
        }
        .onAppear {
            Task {
                while (true) {
                    if Task.isCancelled {
                        return
                    }
                    frameIndex = (frameIndex + 1) % frameCount
                    try? await Task.sleep(for: .seconds(delayTime))
                }
            }
        }
    }

    private func outputPNG(
        url: URL,
        text: String,
        size: CGSize
    ) {
        let fileUrl = url.appendingPathComponent("\(text).png")
        let isSuccess = OutputImg.outputPNG(url: fileUrl) {
            VStack {
                Text(text)
                    .foregroundStyle(self.themeColor)
            }
            .padding()
            .lineLimit(1)
            .minimumScaleFactor(0.01)
            .font(.youSheBiaoTiHei(max(size.width, size.height)))
            .frame(width: size.width, height: size.height)
            .background(self.themeColor.opacity(0.2))
        }
        let fileUrlStr = fileUrl.absoluteString
        print("[outputPNG]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
    }
    
    private func outputGIF(_ dirUrl: URL) {
        self.textList.forEach { text in
            let fileUrl = dirUrl.appendingPathComponent("\(text)", conformingTo: .gif)
            let config: OutputImg.GifConfig = .init(
                frameCount: self.frameCount,
                delayTime: self.delayTime,
                outputPath: fileUrl
            )
            let isSuccess = OutputImg.outputGif(config: config) { progress in
                PreviewItem(text: text, progress: progress)
            }
            let fileUrlStr = fileUrl.absoluteString
            print("[outputGIF]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
        }
    }
    
    @ViewBuilder
    private func Preview() -> some View {
        VStack {
            PreviewLine()
                .colorScheme(.light)
//            PreviewLine()
//                .colorScheme(.dark)
        }
    }

    @ViewBuilder
    private func PreviewLine() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(textList.indices, id: \.self) { textIndex in
                    let text = textList[textIndex]
                    PreviewItem(
                        text: text,
                        progress: self.progress
                    )
                    .scaleEffect(100 / 240)
                    .frame(width: 100, height: 100)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func PreviewItem(text: String, progress: CGFloat) -> some View {
        ScrollTextItemView(text: text, progress: progress, color: color)
            .background(self.bgColor)
    }
}

struct ScrollTextItemView: View {
    private let arrowWidth: CGFloat = 4
    private let spacing: CGFloat = 8
    private let itemHeight: CGFloat = 60
    private let count: Int = 5
    let text: String
    let progress: CGFloat
    let color: Color

    init(text: String, progress: CGFloat, color: Color = .primary) {
        self.text = text
        self.progress = progress
        self.color = color
    }

    private var list: Array<Int> {
        Array(repeating: 0, count: count)
    }
    private var totalLength: CGFloat {
        return CGFloat(count) * itemHeight + CGFloat(count - 1) * spacing
    }
    private var maxScrollLength: CGFloat {
        return CGFloat(count - 4) * itemHeight + CGFloat(count - 4) * spacing
    }

    var body: some View {
        Sticker(progress: progress)
    }
    
    private func offset(progress: CGFloat) -> CGFloat {
        return -progress * maxScrollLength
    }
    
    @ViewBuilder
    private func Sticker(progress: CGFloat) -> some View {
        ZStack {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(list.indices, id: \.self) { index in
                    HStack(spacing: 0) {
                        Item()
                        Spacer()
                    }
                }
            }
            .padding(.leading, 8)
            .offset(y: offset(progress: progress))
        }
        .frame(width: 240, height: 240)
        .clipped(antialiased: true)
    }
    
    @ViewBuilder
    private func Item() -> some View {
        Text(text)
            .padding(.horizontal, 8)
            .padding(.leading, arrowWidth)
            .frame(height: itemHeight)
            .background {
                background
            }
            .font(.system(size: 24))
            .foregroundStyle(color)
            .bold()
    }
    
    private var background: some View {
        ZStack {
            Color.white
                .frame(width: 2 * arrowWidth * sqrt(2), height: 2 * arrowWidth * sqrt(2))
                .clipShape(.rect(cornerRadii: .init(bottomLeading: 4)))
                .rotationEffect(.degrees(45))
                .frame(maxWidth: .infinity, alignment: .leading)
            Color.white
                .clipShape(.rect(cornerRadius: 8))
                .padding(.leading, arrowWidth)
        }
    }
}

#Preview {
    ScrollTextView()
    // 12
}

