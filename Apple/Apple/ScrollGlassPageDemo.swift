//
//  ScrollGlassPageDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/4/5.
//

import SwiftUI

struct ScrollGlassPageDemo: View {
    private let topHeight: CGFloat = 120
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    ForEach(0...100, id: \.self) { index in
                        Text("第\(index)个卡片")
                            .frame(width: 320, height: 120)
                            .contentShape(Rectangle())
                            .hoverEffect()
                            .background(.gray.opacity(0.5))
                            .mask(RoundedRectangle(cornerRadius: 11))
                    }
                }
                .padding(.top, topHeight)
            }
            HStack {
                Image(systemName: "arrow.left.circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        dismiss()
                    }
                Spacer()
                Text("这是一个 Demo")
                Spacer()
            }
            .padding(.leading, 24)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: topHeight, maxHeight: topHeight)
            .background(
                Rectangle()
                    .fill(.regularMaterial)
                    .ignoresSafeArea()
            )
            .onAppear {
            }
        }
        .background(.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ScrollGlassPageDemo()
}

struct TransparentBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            if let backdropLayer = uiView.layer.sublayers?.first {
                backdropLayer.filters?.removeAll(where: { filter in
                    String(describing: filter) != "gaussianBlur"
                })
            }
        }
    }
}
