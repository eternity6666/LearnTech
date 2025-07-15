//
//  Untitled.swift
//  Apple
//
//  Created by Y1616 on 2025/7/7.
//

import SwiftUI
import SwiftCommon

struct Sticker250707Demo: View {
    @State
    private var config: Sticker250707.Config = .init(
        firstLine: "呼和浩特",
        secondLine: "欢迎你"
    )
    
    var body: some View {
        VStack {
            Sticker250707(config: config)
            Button {
                output()
            } label: {
                Text("导出")
            }
        }
        .padding()
        .task {
            Task { @MainActor in
                while (true) {
                    if (Task.isCancelled) {
                        return
                    }
                    var newConfig = self.config
                    newConfig.progress = newConfig.progress + 0.01 >= 1 ? 0 : newConfig.progress + 0.01
                    self.config = newConfig
                    try? await Task.sleep(for: .milliseconds(16))
                }
            }
        }
    }
    
    func output() {
        Task {
            if let dirUrl = TopBottomViewModel.dirUrl(title: "Sticker250707") {
                await outputPNG(url: dirUrl, text: "谢谢你", size: .init(width: 750, height: 750))
                await outputPNG(url: dirUrl, text: "你若喜欢 给个赞吧", size: .init(width: 750, height: 560))
                DataSet.country.forEach { (first, second) in
                    Task {
                        let url = dirUrl.appendingPathComponent("\(first)")
                        try? TopBottomViewModel.createDirIfNeed(url)
                        await outputPNG(url: url, text: first, size: .init(width: 500, height: 500))
                        await outputPNG(url: url, text: first, size: .init(width: 750, height: 400))
                        
                        let stickListUrl = url.appendingPathComponent("stickerList")
                        try? TopBottomViewModel.createDirIfNeed(stickListUrl)
                        for title in second {
                            await outputGIF(url: stickListUrl, text: title)
                        }
                    }
                }
            }
        }
    }
    
    func outputGIF(
        url: URL,
        text: String
    ) async {
        let fileUrl = url.appendingPathComponent(text, conformingTo: .gif)
        let isSuccess = OutputImg.outputGif(
            config: .init(outputPath: fileUrl)
        ) { progress in
            Sticker250707(config: .init(firstLine: text, secondLine: "欢迎你", progress: progress))
        }
        let fileUrlStr = fileUrl.absoluteString
        print("[outputGIF]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
    }
    
    private func outputPNG(
        url: URL,
        text: String,
        size: CGSize
    ) async {
        let fileUrl = url.appendingPathComponent("\(text)_\(size.width / 100)x\(size.height / 100).png")
        let isSuccess = OutputImg.outputPNG(url: fileUrl) {
            Sticker250707(
                config: .init(
                    firstLine: text,
                    size: size,
                    fontSize: size.width / 5
                )
            )
        }
        let fileUrlStr = fileUrl.absoluteString
        print("[outputPNG]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
    }
}

struct Sticker250707: View {
    let config: Config
    
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    let widthAndHeight = max(config.size.width, config.size.height) * 1.5
                    SliceView(config: config)
                        .rotationEffect(.degrees(45))
                        .rotationEffect(.degrees(90 * config.progress))
                        .frame(width: widthAndHeight, height: widthAndHeight)
                }
            VStack(spacing: 20) {
                Text(config.firstLine)
                    .font(.starLoveSweety(config.fontSize))
                    .foregroundStyle(.black)
                if !config.secondLine.isEmpty {
                    Text(config.secondLine)
                        .font(.starLoveSweety(config.fontSize * 2 / 3))
                        .foregroundStyle(.white)
                }
            }
            .minimumScaleFactor(0.01)
            .lineLimit(1)
            .padding()
        }
        .frame(width: config.size.width, height: config.size.height)
        .clipped()
        .padding()
    }
    
    struct Config {
        var bgColor1: Color = Color.orange
        var bgColor2: Color = Color.yellow
        var firstLine: String = ""
        var secondLine: String = ""
        var numberOfSlices = 16
        var size: CGSize = .init(width: 240, height: 240)
        var fontSize: CGFloat = 50
        var progress: CGFloat = 0
    }
    
    struct SliceView: View {
        let config: Config
        
        var numberOfSlices: Int {
            config.numberOfSlices
        }
        
        var body: some View {
            GeometryReader { geometry in
                ForEach(0 ..< numberOfSlices, id: \.self) { sliceIndex in
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let radius = min(geometry.size.width, geometry.size.height) / 2
                        
                        let startAngle = Angle(degrees: Double(sliceIndex) * (360 / Double(numberOfSlices)))
                        let endAngle = Angle(degrees: Double(sliceIndex + 1) * (360 / Double(numberOfSlices)))
                        
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    .fill(sliceIndex % 2 == 0 ? config.bgColor1 : config.bgColor2)
                }
            }
        }
    }
}

#Preview(body: {
    Sticker250707Demo()
})
