//
//  CustomLayoutDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/6/12.
//

import SwiftUI

struct CustomLayoutDemo: View {
    private let itemList: [String]
    
    init() {
        var itemList: [String] = []
        (0...10).forEach { _ in
            let str = "hello world"
            let toIndex = Int.random(in: 0..<str.count)
            let startIndex = str.startIndex
            let endIndex = str.index(startIndex, offsetBy: toIndex)
            let substring = str[startIndex..<endIndex]
            itemList.append(String(substring))
        }
        self.itemList = itemList
    }
    
    var body: some View {
        CustomLayout {
            ForEach(itemList.indices, id: \.self) { index in
                Text(itemList[index])
                    .padding()
                    .frame(height: 48)
                    .background(.white.opacity(0.5))
                    .clipShape(.rect(cornerRadius: 24))
            }
        }
        .frame(width: 300)
        .background(.blue)
    }
}

#Preview {
    CustomLayoutDemo()
}

struct CustomLayout: Layout {
    
    var spacing: CGFloat = 12
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        var totalWidth: Double = 0
        var totalHeight: Double = 0
        var lineWidth: Double = 0
        var lineHeight: Double = 0
        if let containerWidth = proposal.width {
            subviews.forEach { item in
                let itemSize = item.sizeThatFits(.unspecified)
                if lineWidth == 0 || lineWidth + spacing + itemSize.width > containerWidth {
                    totalWidth = max(totalWidth, lineWidth)
                    totalHeight = totalHeight + (totalHeight == 0 ? 0 : spacing) + lineHeight
                    lineWidth = itemSize.width
                    lineHeight = itemSize.height
                } else {
                    lineWidth = lineWidth + spacing + itemSize.width
                    lineHeight = max(lineHeight, itemSize.height)
                }
            }
            totalWidth = max(totalWidth, lineWidth)
            totalHeight = totalHeight + (totalHeight == 0 ? 0 : spacing) + lineHeight
        } else {
            print("CustomLayout proposal.width = nil")
        }
        print("CustomLayout proposal=(width=\(String(describing: proposal.width)), height=\(String(describing: proposal.height)))")
        print("CustomLayout total=(width: \(totalWidth), height: \(totalHeight))")
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var pt = CGPoint(x: bounds.minX, y: bounds.minY)
        for v in subviews {
            v.place(at: pt, anchor: .topLeading, proposal: .unspecified)
            
            pt.x += v.sizeThatFits(.unspecified).width + spacing
        }
    }
    
    struct CachedData {
        var rowIndex: Int
    }
}
