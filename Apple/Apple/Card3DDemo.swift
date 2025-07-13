//
//  Card3DDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2025/1/23.
//

import SwiftUI

struct Card3DDemo: View {
    @State
    private var rowCount: Int = 5
    @State
    private var columnCount: Int = 4
    @State
    private var sign: [[String]] = []
    @State
    private var rotate: [[Int]] = []
    @State
    private var timer: Timer? = nil
    @State
    private var timerValue: Int = 0
    @State
    private var isOver: Bool = false
    @State
    private var lastClick: (Int, Int) = (-1, -1)
    @State
    private var isWin = false
    
    var newGameArea: some View {
        ZStack {
            Text("\(timerValue)")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            Text("新游戏")
                .padding()
                .background(.red)
                .clipShape(.rect(cornerRadius: 16))
                .shadow(radius: 1)
                .foregroundStyle(.white)
                .bold()
                .onTapGesture {
                    self.initGame()
                }
                .padding()
        }
    }

    var body: some View {
        VStack {
            self.newGameArea
            let rowLength = self.sign.count
            ForEach(self.sign.indices, id: \.self) { rowIndex in
                if rowIndex >= 0 && rowIndex < rowLength {
                    let row = self.sign[rowIndex]
                    let columnLength = row.count
                    HStack {
                        ForEach(row.indices, id: \.self) { columnIndex in
                            if columnIndex >= 0 && columnIndex < columnLength {
                                let item = row[columnIndex]
                                CardItem(
                                    rotate: self.queryRotate(rowIndex, columnIndex),
                                    content: item
                                ) {
                                    self.onItemClick(rowIndex, columnIndex)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            initGame()
        }
        .overlay(alignment: .center) {
            if self.isWin {
                self.winPage
            }
        }
    }

    private var winPage: some View {
        VStack {
            Text("Win")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .frame(width: 200)
            Text("Score: \(self.timerValue)")
                .bold()
            Text("新游戏")
                .padding()
                .background(.red)
                .clipShape(.rect(cornerRadius: 16))
                .foregroundStyle(.white)
                .bold()
                .onTapGesture {
                    self.initGame()
                }
        }
        .padding(.all, 24)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.ultraThinMaterial)
                .shadow(radius: 100)
        }
    }
        
    private func onItemClick(_ rowIndex: Int, _ columnIndex: Int) {
        if self.timer == nil {
            startTimer()
        }
        if self.rotate[rowIndex][columnIndex] != 0 {
            return
        }
        Task { @MainActor in
            let lastClick = self.lastClick
            self.rotate[rowIndex][columnIndex] = 180
            if lastClick == (-1, -1) {
                self.lastClick = (rowIndex, columnIndex)
            } else {
                self.lastClick = (-1, -1)
                if self.sign[lastClick.0][lastClick.1] == self.sign[rowIndex][columnIndex] {
                    checkIsWin()
                } else {
                    try? await Task.sleep(for: .seconds(1))
                    self.rotate[lastClick.0][lastClick.1] = 0
                    self.rotate[rowIndex][columnIndex] = 0
                }
            }
        }
    }

    private func checkIsWin() {
        let isWin = self.rotate.reduce(true) { result, row in
            return result && row.reduce(true) { rowResult, item in
                return rowResult && item == 180
            }
        }
        print("\(#function) \(isWin)")
        if isWin {
            self.timer?.invalidate()
            self.timer = nil
            self.isWin = true
        }
    }

    private func startTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.timerValue += 1
        })
        self.timer = timer
        timer.tolerance = 0.2
    }

    private func initGame() {
        if self.rowCount <= 0 {
            self.rowCount = 4
        }
        if self.columnCount <= 0 {
            self.columnCount = 6
        }
        if self.rowCount * self.columnCount % 2 != 0 {
            self.rowCount += 1
        }
        self.lastClick = (-1, -1)
        self.rotate = []
        self.sign = []
        self.timer?.invalidate()
        self.timer = nil
        self.timerValue = 0
        self.isWin = false
        for rowIndex in 0 ..< self.rowCount {
            self.rotate.append([])
            self.sign.append([])
            for _ in 0 ..< self.columnCount {
                self.rotate[rowIndex].append(0)
                self.sign[rowIndex].append("")
            }
        }
        let totalCount = self.rowCount * self.columnCount

        func initSign(sign: String) {
            while true {
                let rowIndex = Int.random(in: 0 ..< rowCount)
                let columnIndex = Int.random(in: 0 ..< columnCount)
                if self.sign[rowIndex][columnIndex] == "" {
                    self.sign[rowIndex][columnIndex] = sign
                    break
                }
            }
        }

        for index in 0 ..< totalCount {
            if index % 2 != 0 {
                continue
            }
            while(true) {
                if let sign = signList.randomElement() {
                    initSign(sign: sign)
                    initSign(sign: sign)
                    break
                }
            }
        }
    }

    private func queryRotate(
        _ rowIndex: Int,
        _ columnIndex: Int
    ) -> Binding<Int> {
        if rowIndex >= 0 && rowIndex < self.rotate.count {
            let row = self.rotate[rowIndex]
            if columnIndex >= 0 && columnIndex < row.count {
                return Binding(
                    get: {
                        self.rotate[rowIndex][columnIndex]
                    },
                    set: { newValue in
                        self.rotate[rowIndex][columnIndex] = newValue
                    }
                )
            }
        }
        return .constant(0)
    }
}

private struct CardItem: View {
    @Binding
    var rotate: Int
    let content: String

    let onClick: () -> Void

    init(rotate: Binding<Int>, content: String, onClick: @escaping () -> Void) {
        self._rotate = rotate
        self.content = content
        self.onClick = onClick
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.red)
                .overlay {
                }
                .zIndex(abs(180 - self.rotate) < 90 ? 0 : 1)
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.blue)
                .overlay {
                    Image(systemName: content)
                        .bold()
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
        }
        .shadow(radius: 2)
        .rotation3DEffect(
            .degrees(Double(self.rotate)),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center
        )
        .animation(.spring, value: self.rotate)
        .onTapGesture {
            self.onClick()
        }
    }
}

#Preview {
    Card3DDemo()
}
