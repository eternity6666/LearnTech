//
//  FileSearchPathDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/8/9.
//

import SwiftUI

#if os(iOS)
struct FileSearchPathDemo: View {
    @State
    private var viewModel: FileSearchPathDemoViewModel = .init()
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHGrid(rows: [.init(.adaptive(minimum: 40, maximum: 50), spacing: 10)], spacing: 10) {
                    ForEach(viewModel.searchPathList.indices, id: \.self) { index in
                        let item: FileManager.SearchPathDirectory = viewModel.searchPathList[index]
                        let isSelected = item == viewModel.currentSearchPath
                        Text("\(item.name)")
                            .padding()
                            .background(.red.opacity(isSelected ? 1 : 0.5))
                            .hoverEffect()
                            .onTapGesture {
                                viewModel.select(to: item)
                            }
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .frame(height: 120)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(viewModel.searchPathDomainMaskList.indices, id: \.self) { index in
                        let item: FileManager.SearchPathDomainMask = viewModel.searchPathDomainMaskList[index]
                        let isSelected = item == viewModel.currentSearchMaskDomain
                        Text("\(item.name)")
                            .padding()
                            .background(.red.opacity(isSelected ? 1 : 0.5))
                            .hoverEffect()
                            .onTapGesture {
                                viewModel.select(to: item)
                            }
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .frame(height: 60)
            ScrollView {
                let list = viewModel.urlList
                LazyVStack {
                    ForEach(list.indices, id: \.self) { index in
                        if index >= 0 && index < list.count {
                            let file = list[index]
                            VStack {
                                Text(file.fileName)
                                Text(file.filePath)
                                Text("文件大小: \(file.fileSize)")
                                    .font(.footnote)
                            }
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(.red.opacity(0.05))
                            .clipShape(.rect(cornerRadius: 16))
                        } else {
                            EmptyView()
                        }
                    }
                }
                .padding()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
}

@Observable
class FileSearchPathDemoViewModel {
    let searchPathList: [FileManager.SearchPathDirectory]
    let searchPathDomainMaskList: [FileManager.SearchPathDomainMask]
    private(set) var currentSearchPath: FileManager.SearchPathDirectory {
        didSet {
            loadUrl()
        }
    }
    private(set) var currentSearchMaskDomain: FileManager.SearchPathDomainMask {
        didSet {
            loadUrl()
        }
    }
    private(set) var urlList: [FileReaderDemoFile] = []
    
    init() {
        self.searchPathList = FileManager.SearchPathDirectory.allCases
        self.searchPathDomainMaskList = FileManager.SearchPathDomainMask.allCases
        self.currentSearchPath = searchPathList.first ?? .applicationDirectory
        self.currentSearchMaskDomain = searchPathDomainMaskList.first ?? .userDomainMask
    }
    
    func select(to searchPath: FileManager.SearchPathDirectory) {
        if searchPath == currentSearchPath {
            return
        }
        self.currentSearchPath = searchPath
    }
    
    func select(to searchMask: FileManager.SearchPathDomainMask) {
        if searchMask == currentSearchMaskDomain {
            return
        }
        self.currentSearchMaskDomain = searchMask
    }
    
    private func loadUrl() {
        Task {
            self.urlList.removeAll()
            if let fileManager = FileManager.default.urls(
                for: currentSearchPath, in: currentSearchMaskDomain
            ).first {
                self.urlList.append(contentsOf: loadFiles(url: fileManager))
            }
        }
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
}

extension FileManager.SearchPathDirectory {
    static var allCases: [FileManager.SearchPathDirectory] {
        var list: [FileManager.SearchPathDirectory] = [
            .applicationDirectory,
            .demoApplicationDirectory,
            .developerApplicationDirectory,
            .adminApplicationDirectory,
            .libraryDirectory,
            .developerDirectory,
            .userDirectory,
            .documentationDirectory,
            .documentDirectory,
            .coreServiceDirectory,
            .autosavedInformationDirectory,
            .desktopDirectory,
            .cachesDirectory,
            .applicationSupportDirectory,
            .downloadsDirectory,
            .inputMethodsDirectory,
            .moviesDirectory,
            .musicDirectory,
            .picturesDirectory,
            .printerDescriptionDirectory,
            .sharedPublicDirectory,
            .preferencePanesDirectory,
            .itemReplacementDirectory,
            .allApplicationsDirectory,
            .allLibrariesDirectory,
            .trashDirectory
        ]
#if TARGET_OS_VISION
        list.append(.applicationScriptsDirectory)
#endif
        return list
    }
    
    var name: String {
        switch self {
            case .applicationDirectory:
                "applicationDirectory"
            case .demoApplicationDirectory:
                "demoApplicationDirectory"
            case .developerApplicationDirectory:
                "developerApplicationDirectory"
            case .adminApplicationDirectory:
                "adminApplicationDirectory"
            case .libraryDirectory:
                "libraryDirectory"
            case .developerDirectory:
                "developerDirectory"
            case .userDirectory:
                "userDirectory"
            case .documentationDirectory:
                "documentationDirectory"
            case .documentDirectory:
                "documentDirectory"
            case .coreServiceDirectory:
                "coreServiceDirectory"
            case .autosavedInformationDirectory:
                "autosavedInformationDirectory"
            case .desktopDirectory:
                "desktopDirectory"
            case .cachesDirectory:
                "cachesDirectory"
            case .applicationSupportDirectory:
                "applicationSupportDirectory"
            case .downloadsDirectory:
                "downloadsDirectory"
            case .inputMethodsDirectory:
                "inputMethodsDirectory"
            case .moviesDirectory:
                "moviesDirectory"
            case .musicDirectory:
                "musicDirectory"
            case .picturesDirectory:
                "picturesDirectory"
            case .printerDescriptionDirectory:
                "printerDescriptionDirectory"
            case .sharedPublicDirectory:
                "sharedPublicDirectory"
            case .preferencePanesDirectory:
                "preferencePanesDirectory"
            case .applicationScriptsDirectory:
                "applicationScriptsDirectory"
            case .itemReplacementDirectory:
                "itemReplacementDirectory"
            case .allApplicationsDirectory:
                "allApplicationsDirectory"
            case .allLibrariesDirectory:
                "allLibrariesDirectory"
            case .trashDirectory:
                "trashDirectory"
            @unknown default:
                "\(self)"
        }
    }
}

extension FileManager.SearchPathDomainMask {
    static var allCases: [FileManager.SearchPathDomainMask] {
        return [
            .userDomainMask,
            .localDomainMask,
            .networkDomainMask,
            .systemDomainMask,
            .allDomainsMask
        ]
    }
    
    var name: String {
        switch self {
            case .userDomainMask:
                "userDomainMask"
            case .localDomainMask:
                "localDomainMask"
            case .networkDomainMask:
                "networkDomainMask"
            case .systemDomainMask:
                "systemDomainMask"
            case .allDomainsMask:
                "allDomainsMask"
            default:
                "\(self)"
        }
    }
}
#endif
