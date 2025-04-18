//
//  PointEffect.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI
import SpriteKit

struct AnimatedSineWaveDemo: View {
  @State var offset: Double = 0
  @State var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
  var body: some View {
    Text("遥遥领先")
      .font(.system(size: 48))
      .frame(width: 240, height: 240)
      .textRenderer(AnimatedSineWaveOffsetRender(timeOffset: offset))
      .onReceive(timer) { _ in
        if offset > 1_000_000_000_000 {
          offset = 0 // 重置时间偏移
        }
        offset += 10
      }
      .background(.blue)
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
  func animatedSineWaveOffset(forCharacterAt index: Int, amplitude: Double, wavelength: Double, phaseOffset: Double, totalCharacters: Int) -> Double {
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
