//
//  CanvasDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2025/3/20.
//

import SwiftUI

struct CanvasDemo: View {
    var body: some View {
        ZStack {
            Text("嘿嘿嘿嘿")
                .font(
                    .system(size: 60)
                    .bold()
                )
                .foregroundStyle(.white)
                .shadow(level: 10)
        }
    }
}

extension View {
    func shadow(level: Int) -> some View {
        self.shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
    }
}

#Preview {
    CanvasDemo()
}
