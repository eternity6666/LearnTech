//
//  ColorDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/4/12.
//

import SwiftUI

#if os(iOS)
struct ColorDemo: View {
    private let colorList: [(String, Color)]
    init() {
        let list: [(String, Color)] = [
            ("black", .black),
            ("blue", .blue),
            ("brown", .brown),
//            ("clear", .clear),
            ("cyan", .cyan),
            ("gray", .gray),
            ("green", .green),
            ("indigo", .indigo),
            ("mint", .mint),
            ("orange", .orange),
            ("pink", .pink),
            ("purple", .purple),
            ("red", .red),
            ("teal", .teal),
            ("white", .white),
            ("yellow", .yellow),
            ("accentColor", .accentColor),
            ("primary", .primary),
            ("secondary", .secondary),
        ]
        colorList = list
    }
    var body: some View {
        List(colorList, id: \.0) { item in
            ItemView(item.0, item.1)
        }
    }
    
    @ViewBuilder
    private func ItemView(_ key: String, _ value: Color) -> some View {
        HStack {
            Text(key)
            Spacer()
            ColorItemView(color: value, isLight: true)
                .preferredColorScheme(.light)
            ColorItemView(color: value, isLight: false)
                .preferredColorScheme(.dark)
        }
        .font(.system(size: 30, design: .rounded))
        .padding(.horizontal, 16)
    }
    
    
    @ViewBuilder
    private func ColorItemView(color: Color, isLight: Bool) -> some View {
        let toRgba: (Color) -> (Int, Int, Int, Int) = { color in
            let ciColor = UIColor(color).cgColor
            let red = Int((ciColor.components?[0] ?? 0) * 256)
            let green = Int((ciColor.components?[1] ?? 0) * 256)
            let blue = Int((ciColor.components?[2] ?? 0) * 256)
            let alpha = Int((ciColor.components?[3] ?? 0) * 256)
            print("\(color), \(red) \(green) \(blue)")
            return (red, green, blue, alpha)
        }
        let useWhiteFont: (Color) -> Bool = { color in
            let resolved = color.resolve(in: .init())
            let colorAdd = resolved.red + resolved.green + resolved.blue
            return colorAdd < 1.5
        }
        let colorItemSize: CGFloat = 80
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 11)
                    .fill(isLight ? .white : .black)
                    .frame(width: colorItemSize, height: colorItemSize)
                    .overlay {
                        Text("abc")
                            .foregroundStyle(color)
                    }
                RoundedRectangle(cornerRadius: 11)
                    .fill(color)
                    .frame(width: colorItemSize, height: colorItemSize)
                    .overlay {
                        let rgba = toRgba(color)
                        VStack {
                            Text("R \(rgba.0)")
                            Text("G \(rgba.1)")
                            Text("B \(rgba.2)")
                            Text("A \(rgba.3)")
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(useWhiteFont(color) ? .white : .black)
                    }
            }
            Text(isLight ? "Light" : "Dark")
                .font(.system(size: 16))
        }
    }
}

#Preview {
    ColorDemo()
}
#endif
