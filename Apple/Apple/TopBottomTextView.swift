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
    }
}

struct TopBottomTextView: View {
    @State
    private var viewModel: TopBottomViewModel = .init()

    var body: some View {
        VStack {
            TopBottomView(
                ratio: viewModel.ratio,
                color: viewModel.color
            )
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
                    .shadow(color: color, radius: toShadowRadius())
                Text(text.1)
                    .shadow(color: color, radius: toShadowRadius())
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
                                color.opacity(0),
                                color.opacity(0.7),
                                color.opacity(0.8),
                                color.opacity(0.7),
                                color.opacity(0),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 66, height: 800)
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
            .border(.blue, width: 2)
            .padding()
            .colorScheme(.light)
            .background(.white)

        TopBottomTextView()
            .border(.blue, width: 2)
            .padding()
            .colorScheme(.dark)
            .background(.black)
    }
}
