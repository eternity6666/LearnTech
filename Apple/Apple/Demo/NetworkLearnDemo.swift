//
//  NetworkLearnDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/5/15.
//

import SwiftUI

struct NetworkLearnDemo: View {
    @State private var dataItemList: [NetworkLearnDemoDataItem] = []
    @State private var index = 0
    
    private let baseUrl = "https://www.wanandroid.com"
    
    var body: some View {
        VStack {
            Button {
                self.loadData(index: index)
            } label: {
                Text("请求数据")
            }
            .buttonStyle(.bordered)
            ScrollView {
                LazyVStack {
                    ForEach(dataItemList, id: \.self) { data in
                        VStack(alignment: .leading) {
                            Text(data.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if !data.author.isEmpty {
                                Text("by: \(data.author)")
                                    .foregroundStyle(.secondary)
                            }
                            TagListView(tagList: data.tags)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.purple, lineWidth: 1.5)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func TagListView(tagList: [NetworkLearnDemoDataItemTag]) -> some View {
        if !tagList.isEmpty {
            ScrollView {
                HStack {
                    ForEach(tagList.indices, id: \.self) { index in
                        Text(tagList[index].name)
                            .foregroundColor(.white)
                            .padding(.all, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .foregroundStyle(.purple.opacity(0.5))
                            }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func loadData(index: Int) {
        if index < 0 {
            return
        }
        Task {
            if let url = URL(string: "\(baseUrl)/article/list/\(index)/json") {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "GET"
                urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                let session = URLSession.shared
                let task: URLSessionDataTask = session.dataTask(with: urlRequest) { data, response, error in
                    if let error {
                        print(error)
                        return
                    }
                    if let data,
                       let demoResponse = try? JSONDecoder().decode(NetworkLearnDemoResponse<NetworkLearnDemoData>.self, from: data) {
                        self.dataItemList.append(contentsOf: demoResponse.data.datas)
                        self.index = demoResponse.data.curPage == demoResponse.data.pageCount ? -1 : demoResponse.data.curPage
                    }
                }
                task.resume()
            }
        }
    }
}

struct NetworkLearnDemoData: Codable {
    var curPage: Int
    var datas: [NetworkLearnDemoDataItem]
    var pageCount: Int
}

struct NetworkLearnDemoDataItem: Identifiable {
    var id: Int
    var title: String
    var link: String
    var author: String
    var chapterId: Int
    var chapterName: String
    var niceDate: String
    var tags: [NetworkLearnDemoDataItemTag]
}

struct NetworkLearnDemoDataItemTag: Hashable, Codable {
    var name: String
    var url: String
}

extension NetworkLearnDemoDataItem: Hashable {}
extension NetworkLearnDemoDataItem: Codable {}

struct NetworkLearnDemoResponse<Data: Codable>: Codable {
    var errorMsg: String
    var errorCode: Int
    var data: Data
}
