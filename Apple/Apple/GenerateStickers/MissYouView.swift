//
//  MissYouView.swift
//  Apple
//
//  Created by Y1616 on 2025/6/17.
//

import SwiftUI
import SwiftCommon

struct MissYouViewDemo: View {
    var body: some View {
        VStack {
            MissYouView(config: self.config)
            PNG(text: "想你的风还是吹到了\n呼伦贝尔", size: .init(width: 750, height: 400), config: config)
                .scaleEffect(200 / 750)
                .frame(width: 200, height: 150)
            Button {
                output()
            } label: {
                Text("导出")
            }
        }
        .padding()
    }

    private var config: MissYouView.Config {
        [
            .init(
                titleColor: Color(245, 245, 245),
                titleBgColor: Color(55, 113, 187)
            )
//            .init(
//                titleColor: Color(47, 79, 79),
//                titleBgColor: Color(245, 245, 220)
//            ),
//            .init(
//                titleColor: Color(63, 112, 77),
//                titleBgColor: Color(176, 224, 230)
//            ),
//            .init(
//                titleColor: Color(255, 255, 255),
//                titleBgColor: Color(44, 62, 80)
//            ),
//            .init(
//                titleColor: Color(253, 253, 150),
//                titleBgColor: Color(85, 107, 47)
//            ),
        ].randomElement() ?? .init()
    }

    private func output() {
        Task {
            if let dirUrl = TopBottomViewModel.dirUrl(title: "想你的风表情包") {
                [
                    "想你的风吹到了这里",
                    "我在这里很想你"
                ].forEach { text in
                    let url = dirUrl.appendingPathComponent(text)
                    try? TopBottomViewModel.createDirIfNeed(url)
                    outputPNG(
                        url: url,
                        text: text,
                        size: .init(width: 60, height: 60),
                        config: config
                    )
                }
                DataSet.country.forEach { (first, second) in
                    let url = dirUrl.appendingPathComponent("\(first)")
                    try? TopBottomViewModel.createDirIfNeed(url)
                    let config = self.config
                    outputPNG(url: url, text: "想你的风吹到了\n\(first)", size: .init(width: 500, height: 500), config: config)
                    outputPNG(url: url, text: "想你的风吹到了\(first)", size: .init(width: 750, height: 400), config: config)
                    outputPNG(url: url, text: "谢谢你", size: .init(width: 750, height: 750), config: config)
                    outputPNG(url: url, text: "你若喜欢 给个赞吧", size: .init(width: 750, height: 560), config: config)
                    let stickListUrl = url.appendingPathComponent("stickerList")
                    try? TopBottomViewModel.createDirIfNeed(stickListUrl)
                    second.forEach { title in
                        outputPNG2(url: stickListUrl, text: "\(title)", config: config)
                    }
                }
            }
        }
    }
    
    private func outputPNG(
        url: URL,
        text: String,
        size: CGSize,
        config: MissYouView.Config
    ) {
        let fileUrl = url.appendingPathComponent("\(text).png")
        let isSuccess = OutputImg.outputPNG(url: fileUrl) {
            PNG(text: text, size: size, config: config)
        }
        let fileUrlStr = fileUrl.absoluteString
        print("[outputPNG]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
    }
    
    @ViewBuilder
    func PNG(text: String, size: CGSize, config: MissYouView.Config) -> some View {
        ZStack {
            self.config.titleBgColor
            let isTwoLine = text.contains("\n")
            Text(text)
                .fontDesign(.monospaced)
                .font(.system(size: max(size.width, size.height)))
                .lineLimit(isTwoLine ? 2 : 1)
                .foregroundStyle(self.config.titleColor)
                .minimumScaleFactor(0.01)
                .padding()
                .multilineTextAlignment(.center)
                .bold()
        }
        .border(self.config.titleColor, width: 2)
        .frame(width: size.width, height: size.height, alignment: .top)
    }
    
    private func outputPNG2(
        url: URL,
        text: String,
        config: MissYouView.Config
    ) {
        let fileUrl = url.appendingPathComponent("\(text).png")
        let isSuccess = OutputImg.outputPNG(url: fileUrl) {
            MissYouView(text: text, config: config)
        }
        let fileUrlStr = fileUrl.absoluteString
        print("[outputPNG2]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
    }
}

struct MissYouView: View {
    let text: String
    let config: Config
    
    init(text: String = "呼和浩特", config: Config = .init()) {
        self.text = text
        self.config = config
    }
    
    var body: some View {
        VStack(spacing: 0) {
            self.config.titleBgColor
                .frame(height: 60)
                .overlay {
                    HStack {
                        Text(config.textType ? "我在\(text)很想你" : "想你的风吹到了\(text)")
                            .fontDesign(.monospaced)
                            .font(.system(size:  22))
                            .bold()
                            .foregroundStyle(self.config.titleColor)
                    }
                }
            Color.white
                .frame(height: 30)
                .overlay {
                    HStack {
                        Spacer()
                        Text("WE ALL MISS YOU")
                            .fontDesign(.monospaced)
                            .bold()
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .foregroundStyle(.black)
                }
        }
        .border(self.config.titleColor, width: 2)
        .frame(width: 240, height: 240, alignment: .top)
    }
    
    struct Config {
        let titleColor: Color
        let titleBgColor: Color
        let textType: Bool = false
        
        init(
            titleColor: Color = Color(253, 253, 150),
            titleBgColor: Color = Color(85, 107, 47)
        ) {
            self.titleColor = titleColor
            self.titleBgColor = titleBgColor
        }
    }
}

#Preview {
    MissYouViewDemo()
}

extension Color {
    init(_ r: Int, _ g: Int, _ b: Int) {
        self.init(r: r, g: g, b: b)
    }
}
