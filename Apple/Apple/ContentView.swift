//
//  ContentView.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            AnimatedSineWaveDemo()
//            ColorTextView()
//            TopBottomTextView()
            DeviceInfoView()
        }
        .padding()
    }
}

@available(iOS 2.0, *)
struct DeviceInfoView: View {
    var body: some View {
        VStack {
            Text("\(UIDevice.current.batteryLevel)")
            Text("\(UIDevice.current.batteryState)")
            Text("\(UIDevice.current.proximityState)")
        }
    }
}

#Preview {
    ScrollTextView()
        .background(.gray.opacity(0.1))
}

struct ScrollTextView: View {
    private let arrowWidth: CGFloat = 4
    private let spacing: CGFloat = 8
    private let itemHeight: CGFloat = 60
    private let count: Int = 10
    
    var text = "有点东西！！！"
    
    private var list: Array<String> {
        Array(repeating: text, count: count)
    }
    private var totalLength: CGFloat {
        return CGFloat(count) * itemHeight + CGFloat(count - 1) * spacing
    }
    
    @State
    var offset: CGFloat = 0
    
    var body: some View {
        Sticker(ratio: offset)
            .onAppear {
                Task {
                    while (true) {
                        if Task.isCancelled {
                            return
                        }
                        print(self.offset)
                        self.offset -= 10
                        try? await Task.sleep(for: .seconds(1 / 30.0))
                        if abs(self.offset) > totalLength - 240 {
                            self.offset = 0
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    private func Sticker(ratio: CGFloat) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: spacing) {
                    ForEach(list.indices, id: \.self) { index in
                        HStack(spacing: 0) {
                            Item(text: list[index])
                            Spacer()
                        }
                    }
                }
                .offset(y: ratio)
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
        .frame(width: 240, height: 240)
    }
    
    @ViewBuilder
    private func Item(text: String) -> some View {
        Text(text)
            .padding(.horizontal, 8)
            .padding(.leading, arrowWidth)
            .frame(height: itemHeight)
            .background {
                background
            }
    }
    
    private var background: some View {
        ZStack {
            Color.white
                .frame(width: 2 * arrowWidth * sqrt(2), height: 2 * arrowWidth * sqrt(2))
                .clipShape(.rect(cornerRadii: .init(bottomLeading: 4)))
                .rotationEffect(.degrees(45))
                .frame(maxWidth: .infinity, alignment: .leading)
            Color.white
                .clipShape(.rect(cornerRadius: 8))
                .padding(.leading, arrowWidth)
        }
    }
}
