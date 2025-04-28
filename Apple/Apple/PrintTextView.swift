//
//  PrintTextView.swift
//  Apple
//
//  Created by Y1616 on 2025/4/23.
//

import SwiftUI

struct PrintTextView: View {
    private let text = "遥遥领先"
    @State
    private var ratio: CGFloat = 0
    @State
    private var timer = Timer.publish(
        every: 0.01,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        itemView(ratio: ratio)
            .onReceive(timer) { _ in
                ratio += 0.005
                if ratio >= 1 {
                    ratio = 0
                }
            }
    }

    private var textList: [[String]] {
        let textList = text.map { String($0) }
        return stride(from: 0, to: textList.count, by: 2).map {
            Array(textList[$0..<min(textList.count, $0 + 2)])
        }
    }
    
    private func convert(_ ratio: CGFloat) -> Double {
        return ratio * 360.0
    }

    @ViewBuilder
    private func itemView(
        ratio: CGFloat = 0.5,
        size: CGSize = .init(width: 400, height: 400)
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(textList.indices, id: \.self) { rowIndex in
                let row = textList[rowIndex]
                HStack(spacing: 0) {
                    ForEach(row.indices, id: \.self) { index in
                        Text(row[index])
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .rotationEffect(.degrees(convert(ratio)))
                    }
                }
                .font(.pomo(size.width / 2))
            }
        }
        .padding(.all, 8)
        .frame(width: size.width, height: size.height)
        .mask {
            LinearGradient(
                colors: [.blue, .yellow],
                startPoint: .leading,
                endPoint: .trailing
            )
            .opacity(0.5)
        }
        .background(.pink)
    }

    private func convert(
        ratio: CGFloat,
        size: CGSize,
        fontSize: CGFloat
    ) -> Data {
        if (true) {
            return Data(y: size.height - fontSize, scale: 1)
        }
        let height = size.height
        let scale: CGFloat
        if ratio < 0.8 {
            scale = 0.2 * ratio / 0.8 + 0.2
        } else {
            scale = 0.4 + (ratio - 0.8) / 0.2 * 0.6
        }
        let y: CGFloat = height
        return Data(y: y, scale: scale)
    }

    struct Data {
        let x: CGFloat
        let y: CGFloat
        let angle: CGFloat
        let scale: CGFloat

        init(
            x: CGFloat = 0,
            y: CGFloat = 0,
            angle: CGFloat = 0,
            scale: CGFloat = 1
        ) {
            self.x = x
            self.y = y
            self.angle = angle
            self.scale = scale
        }
    }
}

#Preview {
    PrintTextView()
        .colorScheme(.light)
        .border(.black, width: 1)
        .scaleEffect(240.0/400.0)
        .padding()
        .background(.white)
}
