//
//  ContentView.swift
//  Apple
//
//  Created by Y1616 on 2025/4/18.
//

import SwiftUI

struct ContentView: View {

    @State private var pageList: [PageType] = []
    @State private var uiSizeType: UISizeType = .regular

    var body: some View {
        ZStack {
            NavigationStack {
                PageList()
                    .navigationDestination(for: PageType.self) { pageType in
                        AnyView(pageType.view)
                            .navigationTitle(pageType.name)
                    }
            }
        }
        .background(
            GeometryReader {
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: $0.size
                )
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { size in
            let sizeType = UISizeType.match(size)
            if sizeType != uiSizeType {
                uiSizeType = sizeType
            }
        }
        .onChange(of: pageList) { oldValue, newValue in
            print(newValue)
        }
    }

    @ViewBuilder
    private func PageList() -> some View {
        List(PageType.allCases) { pageType in
            NavigationLink(pageType.name, value: pageType)
        }
    }
}

class SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

enum UISizeType {
    case regular
    case large
    case huge
    case max
}

extension UISizeType {
    static func match(_ size: CGSize) -> UISizeType {
        if size.width > 1000 {
            return .max
        } else if size.width > 800 {
            return .huge
        } else if size.width > 500 {
            return .large
        }
        return .regular
    }
}


enum PageType: CaseIterable, Identifiable {
    var id: Self { self }
    case textPage
    case syncTaskInMain
    case holidayPlan
    case networkLearn
    case FileDownload
    case CustomLayout
    case Card3D
    
#if os(iOS)
    case AVPlayer
    case colorPage
    case FileReader
    case fileSearchPath
    case scrollGlassPage
#endif
}

extension PageType {
    var view: any View {
        switch self {
        case .holidayPlan: HolidayPlan()
        case .textPage: TextDemo()
        case .syncTaskInMain: SyncTaskInMainDemo()
        case .FileDownload: FileDownloadDemo()
        case .networkLearn: NetworkLearnDemo()
        case .CustomLayout: CustomLayoutDemo()
        case .Card3D: Card3DDemo()
            
#if os(iOS)
        case .AVPlayer: AVPlayerDemo()
        case .colorPage: ColorDemo()
        case .FileReader: FileReaderDemo()
        case .fileSearchPath: FileSearchPathDemo()
        case .scrollGlassPage: ScrollGlassPageDemo()
#endif
        default: EmptyView()
        }
    }

    var name: String {
        switch self {
            case .textPage: "Text 相关"
            case .networkLearn: "网络请求"
            default: "\(self)"
        }
    }
}
