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
    }

    func output() {
        
    }
}

struct Sticker250707: View {
    let config: Config
    
    var body: some View {
        ZStack {
            SliceView()
        }
        .frame(width: 240, height: 240)
        .padding()
    }
    
    struct Config {
        var bgColor1: Color = Color.orange
        var bgColor2: Color = Color.yellow
        var firstLine: String = "深圳"
        var secondLine: String = "等你来玩"
    }
    
    struct SliceView: View {
        let numberOfSlices = 32
        var body: some View {
            GeometryReader { geometry in
                ForEach(0..<numberOfSlices, id: \.self) { i in
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let radius = min(geometry.size.width, geometry.size.height) / 2
                        
                        let startAngle = Angle(degrees: Double(sliceIndex) * (360 / Double(totalSlices)))
                        let endAngle = Angle(degrees: Double(sliceIndex + 1) * (360 / Double(totalSlices)))
                        
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    .fill(i % 2 == 0 ? .red : .green)
                }
            }
            .frame(width: 300, height: 300)
            .rotationEffect(.degrees(-90)) // Rotate the whole circle to start from the top
        }
    }
}

#Preview(body: {
    Sticker250707Demo()
})
