//
//  RedCoverView.swift
//  Apple
//
//  Created by Y1616 on 2025/6/15.
//

import SwiftUI

struct RedCoverViewDemo: View {
    var body: some View {
        ZStack {
            let width: CGFloat = 400
            RedCoverView()
//                .border(.blue)
//                .background(.red)
                .scaleEffect(width / 957)
                .frame(width: width, height: width / 957 * 1278)
                .padding()
            SaveGIFButton(dirTitle: "RedCover") { dirUrl in
                let fileUrl = dirUrl.appendingPathComponent("RedCover", conformingTo: .png)
                _ = OutputImg.outputPNG(url: fileUrl) {
                    RedCoverView()
                }
            }
        }
    }
}

struct RedCoverView: View {

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            Color(r: 230, g: 33, b: 23)
            self.bgText
            self.textListView
            Text("随便花")
                .font(.sJjnyyjyy(200))
                .frame(maxWidth: .infinity)
                .padding(.top, 350)
                .bold()
                .foregroundStyle(Color(r: 230, g: 190, b: 138))
                .shadow(color: .white, radius: 1)
        }
        .frame(width: 750, height: 1250)
        .clipped(antialiased: true)
    }

    @ViewBuilder
    private func TextView(_ text: String) -> some View {
        Text(text)
            .font(.sJjnyyjyy(CGFloat.random(in: 45 ..< 60)))
            .bold()
            .foregroundStyle(Color(r: 230, g: 190, b: 138))
            .shadow(color: .white, radius: 1)
    }
    
    var textListView: some View {
        VStack {
            Spacer()
                .frame(height: 10)
            HStack {
                Spacer()
                TextView("一夜暴富")
                Spacer()
                TextView("福气满满")
                Spacer()
            }
            HStack {
                Spacer()
                TextView("日进斗金")
                Spacer()
                TextView("有钱有闲")
                Spacer()
                TextView("躺着赚钱")
                Spacer()
            }
            Spacer()
                .frame(height: 500)
            HStack {
                Spacer()
                TextView("财源广进")
                Spacer()
                TextView("命里有钱")
                Spacer()
                TextView("FOOD流油")
                Spacer()
            }
            HStack {
                Spacer()
                TextView("内有巨款")
                Spacer()
                TextView("暴富")
                Spacer()
            }
            HStack {
                Spacer()
                TextView("发发发发")
                Spacer()
                TextView("中大奖")
                Spacer()
                TextView("好运翻倍")
                Spacer()
            }
            HStack {
                Spacer()
                TextView("开开心心")
                Spacer()
                TextView("多财多亿")
                Spacer()
            }
            HStack {
                Spacer()
                TextView("八方来财")
                Spacer()
                TextView("爱财爱己")
                Spacer()
                TextView("大概一个亿")
                Spacer()
            }
            HStack {
                Spacer()
                TextView("柿柿如意")
                Spacer()
                TextView("心想事成")
                Spacer()
                TextView("有钱途")
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .opacity(0.9)
    }
    
    @ViewBuilder
    private func ImageView() -> some View {
        Image(
            systemName: [
                "bitcoinsign.circle",
                "chineseyuanrenminbisign.circle",
                "dollarsign.circle"
            ].randomElement() ?? "dollarsign.circle"
        )
        .resizable()
        .frame(width: 40, height: 40)
        .foregroundStyle(Color(r: 230, g: 190, b: 138))
    }

    var bgText: some View {
        ZStack {
            let list = Array(repeating: Array(repeating: 0, count: 12), count: 16)
            VStack(spacing: 10) {
                ForEach(list.indices) { rowIndex in
                    HStack(spacing: 10) {
                        ForEach(list[rowIndex].indices) { columnIndx in
                            Color(r: 230, g: 190, b: 138)
                                .opacity(0.5)
                                .clipShape(.rect(cornerRadius: 16, style: .continuous))
                                .overlay(content: {
                                    Text("富")
                                        .font(.sJjnyyjyy(50))
                                        .foregroundStyle(.white)
                                        .bold()
                                        .baselineOffset(4)
                                })
                                .opacity(0.4)
                        }
                    }
                }
            }
            .padding(.all, -50)
            .mask {
                LinearGradient(colors: [.white.opacity(0.1), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            .mask {
                LinearGradient(colors: [.white.opacity(0.1), .white], startPoint: .topTrailing, endPoint: .bottomLeading)
            }
        }
    }
}

#Preview(body: {
    RedCoverViewDemo()
})


extension Color {
    init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
