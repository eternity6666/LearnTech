//
//  PointEffect.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI
import SpriteKit
import ImageIO

struct AnimatedSineWaveDemo: View {
    @State var offset: Double = 0
    @State var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State var textStr = "吉祥如意、好事连连、心想事成、寿与天齐、花开富贵、大吉大利、必定如意、一帆风顺、福寿安康、万事如意、事事顺心、福如东海、寿比南山、金玉满堂、人见人爱、吉祥康乐、似锦如织"
    
    private func gifItem(
        text: String = "遥遥领先"
    ) -> some View {
        return Text(text)
            .font(.custom("baotuxiaobaiti", size: 48))
            .frame(width: 240, height: 240)
            .background(.blue.opacity(0.5))
    }
    
    var body: some View {
        gifItem()
            .textRenderer(AnimatedSineWaveOffsetRender(timeOffset: offset))
            .opacity(0.1)
            .onReceive(timer) { _ in
                if offset > 360 {
                    offset = 0 // 重置时间偏移
                }
                offset += 10
            }
            .overlay {
                Button {
                    saveImage()
                } label: {
                    Text("save")
                }
            }
    }
    
    func saveImage() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let url = documentsURL.appendingPathComponent("\(Int(Date.now.timeIntervalSince1970))")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print("创建目录失败: \(error)")
                return
            }
        }
        self.textStr.split(separator: "、").forEach { item in
            let text = String(item)
            let frames = captureFrames(view: gifItem(text: text), frameCount: 30)
            let gifURL = url.appendingPathComponent("\(text).gif")
            
            createGIF(from: frames, delay: 0.1, outputURL: gifURL)
            print("GIF saved at: \(gifURL)")
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
            }
            offset += 360.0 / Double(frameCount)
        }
        return images
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
