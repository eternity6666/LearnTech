//
//  ColorTextView.swift
//  Apple
//
//  Created by Y1616 on 2025/5/27.
//

import SwiftUI
import SwiftCommon

struct ColorTextView: View {
    @State
    private var ratio: CGFloat = 0
    @State
    private var num: Int = 30
    private var list: [String] {
        return "哦好哈嗯噢牛可行不六唉强谢哭烦哼".map { String($0) }
    }
    private let title: String = "一个字搞定"
    private let subTitle: String = "多一个字都不需要！"
    @State
    private var fontType: FontType = .youSheBiaoTiHei
    private var color: Color = Color(red: 0.88, green: 1, blue: 0.48)
    var size: CGSize = .init(width: 240, height: 240)

    @MainActor
    private func output() {
        if let url = TopBottomViewModel.dirUrl(title: title) {
            outputStickers(url)
            outputPNG(url: url, text: title, size: .init(width: 500, height: 500))
            outputPNG(url: url, text: subTitle, size: .init(width: 750, height: 400))
            outputPNG(url: url, text: "谢谢你", size: .init(width: 750, height: 750))
            outputPNG(url: url, text: "你若喜欢 给个赞吧", size: .init(width: 750, height: 560))
        }
    }
    
    
    @MainActor
    private func outputStickers(_ url: URL) {
        list.forEach { text in
            let fileUrl = url.appendingPathComponent("\(text).gif")
            let isSuccess = OutputImg.outputGif(
                config: .init(
                    frameCount: num,
                    delayTime: 0.05,
                    outputPath: fileUrl
                )
            ) { ratio in
                BreatheBgTextView(ratio: ratio, text: text, size: size, color: color)
            }
            print("isSuccess=\(isSuccess), file=\(fileUrl.absoluteString)")
        }
    }
    
    @MainActor
    private func outputPNG(
        url: URL,
        text: String,
        size: CGSize
    ) {
        TopBottomViewModel.outputPNG(url: url, text: text, size: size, color: color, fontType: fontType)
    }
    
    var body: some View {
        VStack {
            Button {
                output()
            } label: {
                Text("导出")
            }
            Text("个数: \(list.count)")
            
            Preview()
                .colorScheme(.dark)
                .background(.black)
            Preview()
                .colorScheme(.light)
                .background(.white)
        }
        .onAppear {
            Task {
                while (true) {
                    try? await Task.sleep(for: .milliseconds(16))
                    if ratio + 0.01 >= 1 {
                        ratio = 0
                    } else {
                        ratio = ratio + 0.01
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func Preview() -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(list.indices) { index in
                    let text = list[index]
                    BreatheBgTextView(ratio: ratio, text: text, size: size, color: color)
                        .scaleEffect(100 / 240)
                        .frame(width: 100, height: 100)
                }
            }
        }
    }
}

struct BreatheBgTextView: View {
    let ratio: CGFloat
    let text: String
    let size: CGSize
    let color: Color
    let bgColor: Color
    let fontType: FontType
    
    init(
        ratio: CGFloat,
        text: String,
        size: CGSize,
        color: Color,
        bgColor: Color = Color(red: 0.8, green: 0.2, blue: 0.1),
        fontType: FontType = .youSheBiaoTiHei
    ) {
        self.ratio = ratio
        self.text = text
        self.size = size
        self.color = color
        self.bgColor = bgColor
        self.fontType = fontType
    }
    
    var body: some View {
        VStack {
            Text(text)
                .font(fontType.font(max(size.width, size.height)))
                .frame(width: size.width, height: size.height)
                .foregroundStyle(color)
                .background(bgColor)
                .mask {
                    Canvas { ctx, size in
                        var path = Path()
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radiusBig = size.width / 2 * abs(sin(ratio * .pi + .pi / 4))
                        let radiusSmall = max(0, radiusBig - size.width / 8)
                        path.addArc(
                            center: center, radius: radiusBig,
                            startAngle: .init(degrees: 0), endAngle: .init(degrees: 360),
                            clockwise: false
                        )
                        path.addArc(
                            center: center, radius: radiusSmall,
                            startAngle: .init(degrees: 360), endAngle: .init(degrees: 0),
                            clockwise: true
                        )
                        ctx.fill(path, with: .color(bgColor))
                    }
                }
        }
        .minimumScaleFactor(0.01)
    }
}

#Preview {
    ColorTextView()
}
