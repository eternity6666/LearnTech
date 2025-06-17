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
                titleColor: Color(47, 79, 79),
                titleBgColor: Color(245, 245, 220)
            ),
            .init(
                titleColor: Color(63, 112, 77),
                titleBgColor: Color(176, 224, 230)
            ),
            .init(
                titleColor: Color(255, 255, 255),
                titleBgColor: Color(44, 62, 80)
            ),
            .init(
                titleColor: Color(253, 253, 150),
                titleBgColor: Color(85, 107, 47)
            ),
        ].randomElement() ?? .init()
    }

    private func output() {
        Task {
            if let dirUrl = TopBottomViewModel.dirUrl(title: "路牌表情包") {
                DataSet.country.forEach { (first, second) in
                    let url = dirUrl.appendingPathComponent("\(first)")
                    try? TopBottomViewModel.createDirIfNeed(url)
                    let config = self.config
                    outputPNG(url: url, text: first, size: .init(width: 500, height: 500), config: config)
                    outputPNG(url: url, text: "我在\(first)很想你", size: .init(width: 750, height: 400), config: config)
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
            ZStack {
                Color.white
                config.titleBgColor
                    .opacity(0.8)
                    .overlay {
                        Text(text)
                            .foregroundStyle(config.titleColor)
                            .font(.youSheBiaoTiHei(max(size.width, size.height)))
                            .padding()
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                    }
            }
            .frame(width: size.width, height: size.height)
        }
        let fileUrlStr = fileUrl.absoluteString
        print("[outputPNG]: \(fileUrlStr.removingPercentEncoding ?? fileUrlStr) \(isSuccess)")
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
                        Text("我在\(text)很想你")
                            .fontDesign(.monospaced)
                            .font(.system(size: 26))
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
                            .fontDesign(.rounded)
                            .bold()
                            .font(.system(size: 18))
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
