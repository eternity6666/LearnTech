//
//  Untitled.swift
//  Apple
//
//  Created by Y1616 on 2025/7/7.
//

import SwiftUI

struct Sticker250707Demo: View {
    @State
    private var config: Sticker250707.Config = .init()

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
                    .font(.starLoveSweety(50))
                    .foregroundStyle(.black)
                Text(config.secondLine)
                    .font(.starLoveSweety(40))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: config.size.width, height: config.size.height)
        .clipped()
        .padding()
    }
    
    struct Config {
        var bgColor1: Color = Color.orange
        var bgColor2: Color = Color.yellow
        var firstLine: String = "呼和浩特"
        var secondLine: String = "欢迎你"
        var numberOfSlices = 16
        var size: CGSize = .init(width: 240, height: 200)
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
