//
//  TopBottomTextView.swift
//  Apple
//
//  Created by Y1616 on 2025/4/28.
//

import SwiftUI

@Observable
class TopBottomViewModel {
    var ratio: CGFloat = 0
    var frameCount = 30
    var time: CGFloat = 1
    var color: Color = .green
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

    private func dirUrl(
        folderName: String = "\(Int(Date.now.timeIntervalSince1970))"
    ) -> URL? {
        guard let downloadPath = NSSearchPathForDirectoriesInDomains(
            .downloadsDirectory,
            .userDomainMask, true
        ).first else {
            print("无法获取下载目录")
            return nil
        }
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
                        color: self.color
                    )
                }
                print("isSuccess=\(isSuccess), file=\(fileUrl.absoluteString)")
            }
        }
    }

    private func updateTextArray() {
        let array = inputText.split(separator: ";")
        var result: [(String, String)] = []
        array.forEach { item in
            let tmp = item.split(separator: ",")
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
    private func ControlArea() -> some View {
        HStack {
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
            Spacer()
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
            VStack(spacing: 8) {
                Text(text.0)
                Text(text.1)
                    .padding()
                    .padding(.all, 0.5)
                    .background {
                        bottomBg()
                    }
            }
            .foregroundStyle(color)
            .padding()
            .lineLimit(1)
            .minimumScaleFactor(0.01)
            .font(.pomo(max(size.width, size.height)))
            .frame(width: size.width, height: size.width)
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
