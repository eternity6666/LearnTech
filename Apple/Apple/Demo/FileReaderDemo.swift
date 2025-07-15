//
//  FileReaderDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/8/8.
//

import SwiftUI
import Foundation

#if os(iOS)
struct FileReaderDemo: View {
    @State private var viewModel: FileReaderDemoViewModel = .init()
    
    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                smallScreenContent
            }
            else {
                bigScreenContent
            }
        }
        .onAppear {
            viewModel.loadFileList()
        }
    }
    
    private var smallScreenContent: some View {
        VStack {
            ScrollView(.horizontal) {
                let dataList = viewModel.fileList
                LazyHStack(alignment: .top) {
                    ForEach(dataList.indices, id: \.self) { index in
                        let file: FileReaderDemoFile = dataList[index]
                        VStack {
                            Text(file.fileName)
                            Text("文件大小: \(file.fileSize)")
                                .font(.footnote)
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .hoverEffect()
                        .onTapGesture {
                            viewModel.openFile(file: file)
                        }
                        .clipShape(.rect(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .frame(height: 100)
            ScrollView(.vertical) {
                let dataList = viewModel.contentList
                LazyVStack(alignment: .leading) {
                    ForEach(dataList.indices, id: \.self) { index in
                        let text = dataList[index]
                        Text(text)
                    }
                    Spacer()
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    private var bigScreenContent: some View {
        HStack {
            ScrollView {
                let dataList = viewModel.fileList
                LazyVStack(alignment: .leading) {
                    ForEach(dataList.indices, id: \.self) { index in
                        let file: FileReaderDemoFile = dataList[index]
                        VStack {
                            Text(file.fileName)
                            Text("文件大小: \(file.fileSize)")
                                .font(.footnote)
                        }
                        .padding()
                        .background(.white.opacity(0.05))
                        .hoverEffect()
                        .onTapGesture {
                            viewModel.openFile(file: file)
                        }
                        .clipShape(.rect(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .frame(width: 200)
            ScrollView {
                let dataList = viewModel.contentList
                LazyVStack(alignment: .leading) {
                    ForEach(dataList.indices, id: \.self) { index in
                        let text = dataList[index]
                        Text(text)
                    }
                    Spacer()
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

@Observable
@MainActor
class FileReaderDemoViewModel {
    private(set) var fileList: [FileReaderDemoFile] = []
    private(set) var currentSelectFile: FileReaderDemoFile? = nil {
        didSet {
            if let file = currentSelectFile {
                loadFileContent(path: file.filePath)
            } else {
                contentList.removeAll()
            }
        }
    }
    private(set) var contentList: [String] = []
    private var task: Task<Void, Never>? = nil

    func loadFileList() {
        Task {
            if let fileManager = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            ).first {
                self.fileList.removeAll()
                self.fileList.append(contentsOf: loadFiles(url: fileManager))
                if currentSelectFile == nil {
                    self.currentSelectFile = self.fileList.first
                }
            }
        }
    }

    func openFile(file: FileReaderDemoFile) {
        self.currentSelectFile = file
    }

    private func loadFiles(url: URL) -> [FileReaderDemoFile] {
        var result: [FileReaderDemoFile] = .init()
        let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        if isDirectory {
            let list = (try? FileManager.default.contentsOfDirectory(
                at: url, includingPropertiesForKeys: nil, options: []
            )) ?? []
            list.forEach { item in
                result.append(contentsOf: loadFiles(url: item))
            }
        } else {
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            let fileName = (try? url.resourceValues(forKeys: [.nameKey]).name) ?? ""
            print("\(fileName): fileSize=\(fileSize)")
            result.append(
                .init(
                    fileName: String(fileName),
                    filePath: url.relativePath,
                    fileSize: fileSize
                )
            )
        }
        return result
    }

    private func loadFileContent(path: String) {
        self.task?.cancel()
        self.task = Task { [weak self] in
            self?.contentList = []
            guard let fileHandle = FileHandle(forReadingAtPath: path) else {
                return
            }
            defer {
                do {
                    try fileHandle.close()
                } catch {
                    print("loadFileContent error=\(error)")
                }
            }
            
            while autoreleasepool(invoking: {
                if Task.isCancelled {
                    return false
                }
                let data = fileHandle.readData(ofLength: 1024 * 1024) // 每次读取 1MB 数据
                if data.isEmpty {
                    return false
                }
                
                let chunks = data.split(separator: .init(ascii: "\n"))
                var result: [String] = []
                for chunk in chunks {
                    if let line = String(bytes: chunk, encoding: .utf8) {
                        if !line.isEmpty && line != "\r" {
                            result.append(line)
                        }
                    }
                }
                self?.contentList.append(contentsOf: result)
                return true
            }) {
                
            }
        }
    }
}

struct FileReaderDemoFile {
    let fileName: String
    let filePath: String
    let fileSize: Int
}
#endif
