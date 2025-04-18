//
//  PointEffect.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI
import SpriteKit
import ImageIO
import AppKit

struct AnimatedSineWaveDemo: View {
    @State var offset: Double = 0
    @State var timer = Timer.publish(
        every: 0.05,
        on: .main,
        in: .common
    ).autoconnect()
    @State private var gifSize: CGSize = .init(width: 240, height: 240)
    @State var textStr = "吉祥如意"
    @State var colorList: [Color] = [.purple]
    @State var isGif: Bool = true
    @State var isClear: Bool = true
    @State var bgColor: Color = .blue
    private let KEY_GIF_MAKER_HISTORY_DATA = "KEY_GIF_MAKER_HISTORY_DATA"

    var body: some View {
        VStack {
            controlArea
            previewArea
        }
    }

    private var controlArea: some View {
        HStack {
            VStack {
                inputArea
                colorPicker
            }
            styleArea
            VStack {
                Button {
                    loadHistory()
                } label: {
                    Text("loadHistory")
                }
                Button {
                    saveImage()
                } label: {
                    Text("output")
                }
            }
        }
    }

    private var styleArea: some View {
        VStack {
            HStack {
                Text("width")
                TextField(
                    value: .init(
                        get: { self.gifSize.width },
                        set: { self.gifSize.width = $0 ?? self.gifSize.width }
                    ),
                    format: .number
                ) {
                }
            }
            HStack {
                Text("height")
                TextField(
                    value: .init(
                        get: { self.gifSize.height },
                        set: { self.gifSize.height = $0 ?? self.gifSize.height }
                    ),
                    format: .number
                ) {
                }
            }
            HStack {
                Text("isGif")
                Spacer()
                Toggle(isOn: $isGif) {
                }
            }
            HStack {
                Text("isClear")
                Spacer()
                Toggle(isOn: $isClear) {
                }
            }
            if !isClear {
                HStack {
                    Text("bgColor")
                    Spacer()
                    ColorPicker(selection: $bgColor) {
                    }
                }
            }
        }
        .frame(width: 120)
    }
    
    private var inputArea: some View {
        TextEditor(text: $textStr)
            .frame(maxWidth: 600, maxHeight: 200)
            .multilineTextAlignment(.leading)
    }
    
    private var colorPicker: some View {
        HStack {
            ForEach(self.colorList.indices, id: \.self) { index in
                ColorPicker(
                    selection: .init(
                        get: { self.colorList[index] },
                        set: { self.colorList[index] = $0 }
                    )
                ) {
                }
            }
            Button {
                self.colorList.append(self.colorList.last ?? .cyan)
            } label: {
                Text("+")
            }
        }
    }
    
    private var previewArea: some View {
        HStack {
            let textList = self.textStr.split { char in
                ",，、;；".contains(where: { $0 == char })
            }.prefix(4)
            ForEach(textList.indices, id: \.self) { index in
                if index >= 0 && index < textList.endIndex {
                    let text = String(textList[index])
                    gifItem(text: text)
                        .textRenderer(AnimatedSineWaveOffsetRender(timeOffset: offset))
                }
            }
        }
        .onReceive(timer) { _ in
            if !self.isGif {
                return
            }
            self.offset += 10
            if self.offset >= self.gifSize.width {
                self.offset = 0
            }
        }
    }
    
    private func gifItem(
        text: String = "遥遥领先"
    ) -> some View {
        return Text(text)
            .font(.custom("baotuxiaobaiti", size: gifSize.width / CGFloat(text.count)))
            .frame(width: gifSize.width, height: gifSize.height)
            .foregroundStyle(
                .linearGradient(
                    colors: self.colorList,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .background(isClear ? .clear : bgColor)
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.value(forKey: KEY_GIF_MAKER_HISTORY_DATA) as? Data,
           let historyData = try? JSONDecoder().decode(HistoryData.self, from: data) {
            self.textStr = historyData.text
            self.colorList = historyData.color
        }
    }

    private func saveHistoryData() {
        if let data = try? JSONEncoder().encode(HistoryData(text: self.textStr, color: self.colorList)) {
            UserDefaults.standard.set(data, forKey: KEY_GIF_MAKER_HISTORY_DATA)
        }
    }
    
    func saveImage() {
        let historyData: HistoryData = .init(
            text: self.textStr,
            color: self.colorList
        )
        saveHistoryData()
        guard let downloadPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first else {
            print("无法获取下载目录")
            return
        }
        
        let folderName = "\(Int(Date.now.timeIntervalSince1970))"
        let url = URL(fileURLWithPath: downloadPath).appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            
            let textArray = self.textStr.split { char in
                ",，、;；".contains(where: { $0 == char })
            }
            textArray.forEach { item in
                let text = String(item)
                if !text.isEmpty {
                    if (self.isGif) {
                        let frames = captureFrames(view: gifItem(text: text), frameCount: 30)
                        let fileUrl = url.appendingPathComponent("\(text).gif")
                        createGIF(from: frames, delay: 0.05, outputURL: fileUrl)
                        print("GIF saved at: \(fileUrl)")
                    } else {
                        if let image = captureFrames(view: gifItem(text: text), frameCount: 30).first {
                            let fileUrl = url.appendingPathComponent("\(text).png")
                            createPNG(from: image, outputURL: fileUrl)
                            print("PNG saved at: \(fileUrl)")
                        }
                    }
                }
            }
        } catch {
            print("创建失败: \(error)")
        }
    }
    
    func captureFrames(view: some View, frameCount: Int) -> [CGImage] {
        var images = [CGImage]()
        
        var offset: Double = 0
        for _ in 0 ..< frameCount {
            let render = AnimatedSineWaveOffsetRender(timeOffset: offset)
            let view2 = view
                .textRenderer(render)
            let renderer = ImageRenderer(content: view2)
            if let image = renderer.cgImage {
                images.append(image)
                if !isGif {
                    return images
                }
            }
            offset += self.gifSize.width / Double(frameCount)
        }
        return images
    }
    
    func createPNG(from image: CGImage, outputURL: URL) {
        if let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, kUTTypePNG, 1, nil) {
            CGImageDestinationAddImage(destination, image, nil)
            CGImageDestinationFinalize(destination)
        }
    }
    
    func createGIF(from images: [CGImage], delay: Double, outputURL: URL) {
        let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, kUTTypeGIF, images.count, nil)!
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]]
        let gifProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] // 0 = 无限循环
        
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        for cgImage in images {
            CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        }
        
        CGImageDestinationFinalize(destination)
    }
}

struct HistoryData: Codable {
    let text: String
    let color: [Color]
}

struct AnimatedSineWaveOffsetRender: TextRenderer {
    let timeOffset: Double // 时间偏移量
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let count = layout.flattenedRunSlices.count // 统计文本布局中所有 RunSlice 的数量
        let width = layout.first?.typographicBounds.width ?? 0 // 获取文本 Line 的宽度
        let height = layout.first?.typographicBounds.rect.height ?? 0 // 获取文本 Line 的高度
        // 遍历每个 RunSlice 及其索引
        for (index, slice) in layout.flattenedRunSlices.enumerated() {
            // 计算当前字符的正弦波偏移量
            let offset = animatedSineWaveOffset(
                forCharacterAt: index,
                amplitude: height / 2, // 振幅设为行高的一半
                wavelength: width,
                phaseOffset: timeOffset,
                totalCharacters: count
            )
            // 创建上下文副本并进行平移
            var copy = context
            copy.translateBy(x: 0, y: offset)
            // 在修改后的上下文中绘制当前 RunSlice
            copy.draw(slice)
        }
    }
    
    // 根据字符索引计算正弦波偏移量
    func animatedSineWaveOffset(
        forCharacterAt index: Int,
        amplitude: Double,
        wavelength: Double,
        phaseOffset: Double,
        totalCharacters: Int
    ) -> Double {
        let x = Double(index)
        let position = (x / Double(totalCharacters)) * wavelength
        let radians = ((position + phaseOffset) / wavelength) * 2 * .pi
        return sin(radians) * amplitude
    }
}

extension Text.Layout {
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        flatMap { line in
            line
        }
    }
    
    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap(\.self)
    }
}

#Preview {
    AnimatedSineWaveDemo()
}
