//
//  BilibiliDemo.swift
//  Apple
//
//  Created by Y1616 on 2025/6/16.
//

import SwiftUI
import Alamofire

struct BilibiliDemo: View {
    @State
    private var vm: BilibiliDemoVM = .init()
    var body: some View {
        VStack {
            Text(vm.mid)
            Text("关注数: \(vm.following)")
            Text("粉丝数: \(vm.follower)")
            Text("播放数: \(vm.playCount)")
            Button {
                vm.request()
            } label: {
                Text("load")
            }
        }
        .onAppear {
            vm.request()
        }
    }
}

struct UserStatResponse: Codable {
    let code: Int
    let message: String
    let ttl: Int
    let data: UserStatData
}

struct UserStatData: Codable {
    let mid: Int
    let following: Int
    let whisper: Int
    let black: Int
    let follower: Int
}

struct UpStatResponse: Codable {
    let code: Int
    let message: String
    let ttl: Int
    let data: UpStatData
}

struct UpStatData: Codable {
    let archive: ArchiveStat
    let article: ArticleStat
    let likes: Int
}

struct ArchiveStat: Codable {
    let enable_vt: Int
    let view: Int64
    let vt: Int
}

struct ArticleStat: Codable {
    let view: Int64
}

@Observable
class BilibiliDemoVM {
    // up ID
    var mid = "471303350"
    
    var follower: Int = 0
    var following: Int = 0
    var face: String = ""
    var likes: Int64 = 0
    var playCount: Int64 = 0
    
    func request() {
        Task {
            if let url = URL(string: API.stat.url) {
                let result = await request(
                    url,
                    ["vmid": mid]
                )
                if let data = result.data,
                   let statResponse = try? JSONDecoder().decode(UserStatResponse.self, from: data) {
                    self.follower = statResponse.data.follower
                    self.following = statResponse.data.following
                    print("用户基础统计:")
                    print("MID: \(statResponse.data.mid)")
                    print("关注数: \(statResponse.data.following)")
                    print("粉丝数: \(statResponse.data.follower)")
                    print("悄悄关注: \(statResponse.data.whisper)")
                    print("拉黑数: \(statResponse.data.black)")
                }
            }
            if let url = URL(string: API.upstat.url) {
                let result = await request(
                    url,
                    ["mid": mid]
                )
                if let data = result.data {
                    do {
                        print(String.init(data: data, encoding: .utf8))
                        let upstatResponse = try JSONDecoder().decode(UpStatResponse.self, from: data)
                        self.playCount = upstatResponse.data.archive.view
                        print("\nUP主详细统计:")
                        print("视频播放量: \(upstatResponse.data.archive.view)")
                        print("专栏阅读量: \(upstatResponse.data.article.view)")
                        print("获赞数: \(upstatResponse.data.likes)")
                        print("是否启用VT: \(upstatResponse.data.archive.enable_vt == 1 ? "是" : "否")")
                    } catch {
                        print("\(error)")
                    }
                }
            }
        }
    }

    private func request(
        _ url: URL,
        _ params: [String: String] = [:]
    ) async -> AFDataResponse<Data?> {
        print(url.absoluteString)
        return await withUnsafeContinuation { continuation in
            AF.request(url, parameters: params)
                .onURLRequestCreation(on: .global(), perform: { request in
                    print("request=\(request)")
                })
                .response { data in
                    continuation.resume(returning: data)
                }
        }
    }

    enum API {
        case stat
        case upstat

        var url: String {
            switch self {
            case .stat:
                return "https://api.bilibili.com/x/relation/stat"
            case .upstat:
                return "https://api.bilibili.com/x/space/upstat"
            }
        }
    }
}

#Preview {
    BilibiliDemo()
}
