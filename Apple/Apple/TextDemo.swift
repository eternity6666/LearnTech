//
//  TextDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/4/3.
//

import SwiftUI

struct TextDemo: View {
    private let textStyleList : [(String, Font?)]
    @State private var text = "这是一个字符串"
    
    init() {
        var tmpTextStyleList : [(String, Font?)] = [
            ("default", nil),
            ("largeTitle", .largeTitle),
            ("title", .title),
            ("title2", .title2),
            ("title3", .title3),
            ("headline", .headline),
            ("subheadline", .subheadline),
            ("body", .body),
            ("callout", .callout),
            ("caption", .caption),
            ("caption2", .caption2),
            ("footnote", .footnote),
        ]
#if os(visionOS)
        tmpTextStyleList.append(("extraLargeTitle", .extraLargeTitle))
        tmpTextStyleList.append(("extraLargeTitle2", .extraLargeTitle2))
#endif
        self.textStyleList = tmpTextStyleList
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(textStyleList, id: \.0) { item in
                    ItemView(item.0, item.1)
                }
            }
        }
    }
    
    @ViewBuilder
    private func ItemView(_ key: String, _ value: Font? = nil) -> some View {
        HStack {
            Text("\(key):")
            Spacer()
            Text(text)
                .font(value)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TextDemo()
}
