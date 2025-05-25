//
//  AVView.swift
//  Apple
//
//  Created by Y1616 on 2025/5/25.
//

import SwiftUI
import AVFoundation
import Accelerate

struct AVView: View {
    var body: some View {
        Text("Hello")
    }
}


#Preview(body: {
    AVView()
})


@Observable
class AudioAnalyzer {
    @ObservationIgnored
    private var engine = AVAudioEngine()
    @ObservationIgnored
    private var player = AVAudioPlayerNode()
    @ObservationIgnored
    private var fftSize: Int = 2048 // FFT采样窗口大小
    var frequencyData: [Float] = [] // 频谱数据

    init() {
        setupAudio()
    }

    private func setupAudio() {
        // 配置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord)
        try? audioSession.setActive(true)

        // 连接节点
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)

        // 在mainMixerNode上安装分接头获取实时数据
        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: UInt32(fftSize),
            format: nil
        ) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        // 启动引擎
        try? engine.start()
    }

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
    }
}
