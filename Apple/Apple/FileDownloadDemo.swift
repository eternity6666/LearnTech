//
//  FileDownloadDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/6/3.
//

import SwiftUI
import Alamofire

struct FileDownloadDemo: View {
    @State private var fileUrl: String = "https://dzs.qishuta.org/7/7310/%E8%AF%A1%E7%A7%98%E4%B9%8B%E4%B8%BB.txt"
    @State private var status: DownloadStatus = .none
    private let vm: FileDownloadDemoViewModel = .init()
    
    var body: some View {
        VStack {
            TextField(text: $fileUrl) {
                Text("下载地址")
            }
            .textFieldStyle(.roundedBorder)
            Button {
                download()
            } label: {
                Text("下载")
            }
            DownloadStatusView()
        }
    }
    
    @ViewBuilder
    private func DownloadStatusView() -> some View {
        switch status {
            case .none:
                EmptyView()
            case .progress(let progress):
                Text("\(progress)%")
                    .foregroundStyle(.green)
            case .failure(let progress):
                Text("\(progress)%")
                    .foregroundStyle(.red)
            case .success:
                Text("下载完成")
        }
    }
    
    private func download() {
        vm.downloadUrl(urlStr: self.fileUrl) { status in
            self.status = status
        }
    }
    
}

class FileDownloadDemoViewModel {
    func downloadUrl(urlStr: String, callBack: @escaping (DownloadStatus) -> Void) {
        let destination: DownloadRequest.Destination = { [weak self] (url, response) in
            let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let suggestFileName = response.suggestedFilename?.removingPercentEncoding ?? "\(Date.now)"
            let fileUrl = documentUrl.appendingPathComponent(suggestFileName)
            print("下载地址: \(String(describing: fileUrl.absoluteString))")
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        Task {
            if let url = URL(string: urlStr) {
                AF.download(url, to: destination).downloadProgress { progress in
                    callBack(.progress(progress: Int(progress.completedUnitCount)))
                }.validate().response { [weak self] response in
                    callBack(.success)
                }
            }
        }
        
    }
}

enum DownloadStatus {
    case none
    case progress(progress: Int)
    case failure(progress: Int)
    case success
}

#Preview {
    FileDownloadDemo()
}
