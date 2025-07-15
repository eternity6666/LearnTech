//
//  AVPlayerDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/5/18.
//

import SwiftUI
import AVKit

#if os(iOS)
struct AVPlayerDemo: View {
    @State var player = AVPlayer()
    @State private var urlStr = "https://tv.iill.top/m3u/Live"
    @State private var segmentList: [M3U8Segment] = []
    
    var body: some View {
        VStack {
            HStack {
                TextField(text: $urlStr) {
                    Text("m3u 播放链接")
                }
                .onSubmit {
                    loadVideo()
                }
                .textFieldStyle(.roundedBorder)
                Button {
                    self.loadVideo()
                } label: {
                    Text("播放")
                }
            }
            .frame(height: 60)
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(segmentList.indices, id: \.self) { index in
                        Text("视频 \(index+1)")
                            .padding()
                            .background(.white.opacity(0.5))
                            .hoverEffect()
                            .onTapGesture {
                                print("playM3U8Segment url=\(self.segmentList[index].url)")
                                self.playM3U8Segment(self.segmentList[index])
                            }
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .frame(height: 60)
            VideoPlayer(player: player)
                .frame(minHeight: 0, maxHeight: .infinity)
        }
        .onAppear {
            loadVideo()
        }
    }
    
    func loadVideo() {
        Task {
            if let url = URL(string: urlStr),
               let data = await withUnsafeContinuation({ continuation in
                   self.fetchM3U8Data(from: url) { data in
                       continuation.resume(returning: data)
                   }
               }) {
                let list = self.parseM3U8Data(data)
                DispatchQueue.main.async {
                    self.segmentList = list
                    if let segment = list.first {
                        self.playM3U8Segment(segment)
                    }
                }
            }
        }
    }

    func loadVideo2() {
        Task {
            let url = URL.init(filePath: urlStr)
            if let data = await withUnsafeContinuation({ continuation in
                   self.fetchM3U8Data(from: url) { data in
                       continuation.resume(returning: data)
                   }
               }) {
                let list = self.parseM3U8Data(data)
                DispatchQueue.main.async {
                    self.segmentList = list
                    if let segment = list.first {
                        self.playM3U8Segment(segment)
                    }
                }
            }
        }
    }

    func fetchM3U8Data(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }

    private func parseM3U8Data(_ data: Data) -> [M3U8Segment] {
        let lines = String(data: data, encoding: .utf8)?.components(separatedBy: "\n") ?? []
        var segments: [M3U8Segment] = []
        
        for line in lines {
            if line.isEmpty || line.hasPrefix("#") {
                continue
            }
            let parts = line.split(separator: ",").map { String($0) }
            guard parts.count >= 1 else { continue }
            let url = URL(string: parts[0])!
            segments.append(M3U8Segment(url: url))
        }
        
        return segments
    }

    func playM3U8Segment(_ segment: M3U8Segment) {
        DispatchQueue.main.async {
            let playerItem = AVPlayerItem(url: segment.url)
            self.player = AVPlayer(playerItem: playerItem)
            self.player.play()
        }
    }
}

struct M3U8Segment {
    let url: URL
}

class SessionDelegate: NSObject, URLSessionDelegate {
    
}

#Preview {
    AVPlayerDemo()
}
#endif
