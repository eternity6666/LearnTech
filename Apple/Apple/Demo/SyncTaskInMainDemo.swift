//
//  SyncTaskInMainDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/4/9.
//

import SwiftUI

struct SyncTaskInMainDemo: View {
    @State private var text = ""
    var body: some View {
        VStack {
            Button {
                trySyncInMain()
            } label: {
                Text("尝试在主队列调用同步任务")
            }
            .buttonStyle(.bordered)
            Text(text)
        }
    }
    
    private func trySyncInMain() {
        print("trySyncInMain \(Thread.current) start\n")
        let queue = DispatchQueue.main
        print("\(Thread.current) async before \n")
        queue.async {
            print("\(Thread.current) async in\n")
        }
        print("\(Thread.current) async after\n")
        
        print("\(Thread.current) sync before\n")
        queue.sync {
            print("\(Thread.current) sync in\n")
        }
        print("\(Thread.current) sync after\n")
        print("trySyncInMain \(Thread.current) end\n")
    }
}

#Preview {
    SyncTaskInMainDemo()
}
