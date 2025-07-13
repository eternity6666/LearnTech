//
//  HolidayPlan.swift
//  AppleLearn
//
//  Created by baronyang on 2024/4/20.
//

import SwiftUI

struct HolidayPlan: View {
    private let holidayList: [HolidayData]
    
    init(holidayList: [HolidayData] = HolidayIn20240501) {
        self.holidayList = holidayList
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HolidayContent()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func HolidayContent() -> some View {
        let color: Color = .teal
        ForEach(holidayList.indices, id: \.self) { index in
            let data = holidayList[index]
            let isFirst = index == holidayList.startIndex
            let isLast = index + 1 == holidayList.endIndex
            HStack(spacing: 0) {
                Text("\(data.time)")
                    .frame(width: 50)
                CustomTimeLine(color: color, isFirst: isFirst, isLast: isLast)
                VStack(alignment: .leading) {
                    ForEach(data.descriptions, id: \.self) { description in
                        Text(description)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 13)
                .padding(.leading, 8)
            }
            if !isLast {
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: 50)
                        .foregroundStyle(.clear)
                    Rectangle()
                        .foregroundStyle(color)
                        .frame(width: 8)
                        .frame(width: 16)
                    Divider()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .background(color.opacity(0.2))
                        .padding(.leading, 8)
                }
                .frame(height: 1)
            }
        }
        .foregroundStyle(color)
    }
    
    
    @ViewBuilder
    func CustomTimeLine(color: Color, isFirst: Bool, isLast: Bool) -> some View {
        let verticalLinear: LinearGradient = .linearGradient(
            colors: getLinearGradient(color: color, isFirst: isFirst, isLast: isLast),
            startPoint: .top, endPoint: .bottom
        )
        let size: CGFloat = 8
        let topRadius = isFirst ? size * 0.5 : 0
        let bottomRadius = isLast ? size * 0.5 : 0
        ZStack {
            UnevenRoundedRectangle(
                topLeadingRadius: topRadius,
                bottomLeadingRadius: bottomRadius,
                bottomTrailingRadius: bottomRadius,
                topTrailingRadius: topRadius,
                style: .continuous
            )
            .foregroundStyle(verticalLinear)
            .frame(maxWidth: size, minHeight: 0, maxHeight: .infinity)
            Circle()
                .foregroundStyle(color)
                .frame(width: size * 2, height: size * 2)
                .overlay {
                    Circle()
                        .foregroundStyle(.white)
                        .frame(width: size * 0.8, height: size * 0.8)
                }
        }
    }
    
    private func getLinearGradient(color: Color, isFirst: Bool, isLast: Bool) -> [Color] {
        var gradientColors: [Color] = []
        if isFirst {
            gradientColors.append(color.opacity(0.6))
        }
        gradientColors.append(color)
        if isLast {
            gradientColors.append(color.opacity(0.6))
        }
        return gradientColors
    }
}

struct HolidayData {
    let id: UUID = UUID()
    let time: String
    let descriptions: [String]
}

let HolidayIn20240501: [HolidayData] = [
    .init(time: "4.28", descriptions: ["🐑回家"]),
    .init(time: "5.1", descriptions: ["🐑12点前到株洲", "下午拍登记证照片（暂定海马体）", "晚餐小麻雀"]),
    .init(time: "5.2", descriptions: ["🐑和🐷 gogogo 南昌", "午餐蓝边碗", "下午 NCU 漫步", "晚餐牛魔王", "晚上赣江边 CityWalk"]),
    .init(time: "5.3", descriptions: ["🐑和🐷 恰个南昌特色早餐", "上午滕王阁", "午餐李师傅（🐷最爱滴飞饼）", "下午 JXNU 漫步", "晚餐季季红"]),
    .init(time: "5.4", descriptions: ["🐑和🐷 睡到自然醒", "午餐待定", "下午万寿宫、八一广场", "晚餐待定", "返程株洲"]),
    .init(time: "5.5", descriptions: ["🐑和🐷 睡到自然醒", "午餐大碗先生", "株洲方特玩耍", "晚餐待定"]),
    .init(time: "5.6", descriptions: ["🐑送🐷去上班", "🐑回深圳"])
]

extension HolidayData: Identifiable, Hashable, Equatable {}

#Preview {
    HolidayPlan()
}
