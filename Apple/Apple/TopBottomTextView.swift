//
//  TopBottomTextView.swift
//  Apple
//
//  Created by Y1616 on 2025/4/28.
//

import SwiftUI

private extension Font {
    static func font(_ size: CGFloat) -> Font {
        .youSheBiaoTiHei(size)
    }
}

@Observable
class TopBottomViewModel {
    var ratio: CGFloat = 0
    var frameCount = 30
    var time: CGFloat = 1
    var color: Color = .green
    var title: String = "怼怼"
    var subTitle: String = "怼怼没输过"
    var inputText: String = "老奶奶穿棉袄,一套又一套;" {
        didSet {
            updateTextArray()
        }
    }
    var size: CGSize = .init(width: 240, height: 240)

    var textArray: [(String, String)] = []

    init() {
        Task {
            let fFrameCount = CGFloat(frameCount)
            let fTimeSleep = time / fFrameCount * 1000
            let maxRatio: CGFloat = 1.0
            let dRatio = 1.0 / fFrameCount
            while (true) {
                let ratio = self.ratio + dRatio > maxRatio ? 0 : self.ratio + dRatio
                self.ratio = ratio
                try? await Task.sleep(for: .milliseconds(Int(fTimeSleep)))
            }
        }
        self.updateTextArray()
    }

    private func dirUrl() -> URL? {
        guard let downloadPath = NSSearchPathForDirectoriesInDomains(
            .downloadsDirectory,
            .userDomainMask, true
        ).first else {
            print("无法获取下载目录")
            return nil
        }
        let folderName: String = "\(title)_\(Int(Date.now.timeIntervalSince1970))"
        let url = URL(fileURLWithPath: downloadPath).appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        } catch {
            return nil
        }
    }
    
    @MainActor
    func output() {
        if let url = dirUrl() {
            outputStickers(url)
            outputPNG(url: url, text: title, size: .init(width: 500, height: 500))
            outputPNG(url: url, text: subTitle, size: .init(width: 750, height: 400))
            outputPNG(url: url, text: "谢谢你", size: .init(width: 750, height: 750))
            outputPNG(url: url, text: "你若喜欢 给个赞吧", size: .init(width: 750, height: 560))
        }
    }

    @MainActor
    private func outputStickers(_ url: URL) {
        textArray.forEach { (top, bottom) in
            let fileUrl = url.appendingPathComponent("\(top).gif")
            let isSuccess = OutputImg.outputGif(
                config: .init(
                    frameCount: self.frameCount,
                    width: self.size.width,
                    delayTime: 0.05,
                    outputPath: fileUrl
                )
            ) { ratio in
                TopBottomView(
                    text: (top, bottom),
                    ratio: ratio,
                    color: self.color,
                    size: self.size
                )
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
        let fileUrl = url.appendingPathComponent("\(text).png")
        let isSuccess = OutputImg.outputPNG(url: fileUrl) {
            VStack {
                Text(text)
                    .foregroundStyle(color)
            }
            .padding()
            .lineLimit(1)
            .minimumScaleFactor(0.01)
            .font(.font(max(size.width, size.height)))
            .frame(width: size.width, height: size.height)
            .background(color.opacity(0.2))
        }
        print("isSuccess=\(isSuccess), file=\(fileUrl.absoluteString)")
    }
    
    private func updateTextArray() {
        let array = inputText.split { char in
            ";；".contains(where: { char == $0})
        }
        var result: [(String, String)] = []
        array.forEach { item in
            let tmp = item.split { char in
                ",".contains(where: { char == $0})
            }
            if tmp.count >= 2 {
                result.append((String(tmp[0]), String(tmp[1])))
            }
        }
        textArray = result
    }
}

struct TopBottomTextView: View {
    @State
    private var viewModel: TopBottomViewModel = .init()
    
    var body: some View {
        VStack {
            ControlArea()
                .frame(maxHeight: 150)
            VStack(spacing: 0) {
                PreviewArea()
                    .colorScheme(.light)
                    .background(.white)
                PreviewArea()
                    .colorScheme(.dark)
                    .background(.black)
            }
        }
    }
    
    @ViewBuilder
    private func InputNumber(
        value: Binding<FloatingPointFormatStyle<Double>.FormatInput>,
        text: String
    ) -> some View {
        HStack {
            Text(text)
            TextField(value: value, format: .number) {
                
            }
        }
    }
    
    @ViewBuilder
    private func ControlArea() -> some View {
        HStack {
            VStack {
                ColorPicker(selection: self.$viewModel.color) {
                    Text("颜色")
                }
                InputNumber(
                    value: .init(
                        get: { viewModel.size.width },
                        set: { viewModel.size.width = $0 }
                    ),
                    text: "width"
                )
                InputNumber(
                    value: .init(
                        get: { viewModel.size.height },
                        set: { viewModel.size.height = $0 }
                    ),
                    text: "height"
                )
            }
            .frame(width: 100)
            VStack {
                HStack(alignment: .center) {
                    TextField(text: self.$viewModel.title) {
                    }
                    TextField(text: self.$viewModel.subTitle) {
                    }
                }
                .frame(height: 20)
                TextEditor(text: self.$viewModel.inputText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                    .overlay(alignment: .bottomTrailing) {
                        Text("个数: \(self.viewModel.textArray.count)")
                    }
            }
            Button {
                self.viewModel.output()
            } label: {
                Text("导出")
            }
        }
    }
    
    @ViewBuilder
    private func PreviewArea() -> some View {
        let array = viewModel.textArray
        ScrollView(.horizontal) {
            HStack {
                ForEach(array.indices, id: \.self) { index in
                    TopBottomView(
                        text: array[index],
                        ratio: viewModel.ratio,
                        color: viewModel.color,
                        size: viewModel.size
                    )
                    .scaleEffect(100 / viewModel.size.width)
                    .frame(width: 100, height: 100)
                }
            }
        }
    }
}

struct TopBottomView: View {
    let text: (String, String)
    let ratio: CGFloat
    let color: Color
    let size: CGSize

    init(
        text: (String, String) = ("老奶奶穿棉袄", "一套又一套"),
        ratio: CGFloat,
        color: Color,
        size: CGSize = .init(width: 240, height: 240)
    ) {
        self.text = text
        self.ratio = ratio
        self.color = color
        self.size = size
    }

    var body: some View {
            VStack(spacing: 0) {
                Text(text.0)
                Text(text.1)
                    .padding()
                    .padding(.all, 0.5)
                    .frame(maxHeight: size.height * 0.4)
                    .frame(width: size.width * 0.8)
                    .background {
                        bottomBg()
                    }
            }
            .foregroundStyle(color)
            .padding()
            .lineLimit(1)
            .minimumScaleFactor(0.01)
            .font(.font(max(size.width, size.height)))
            .frame(width: size.width, height: size.height)
    }
    
    @ViewBuilder
    private func bottomBg() -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(color, style: .init(lineWidth: 1), antialiased: true)
            .mask {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        .linearGradient(
                            colors: [
                                color
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 800)
                    .rotationEffect(.degrees(toBottomBgRotation()))
            }
    }

    private func toShadowRadius() -> CGFloat {
        return sin(ratio * .pi) * 0.5 + 0.5
    }

    private func toBottomBgRotation() -> CGFloat {
        return ratio * 180
    }
}

#Preview {
    VStack(spacing: 0) {
        TopBottomTextView()
    }
}
