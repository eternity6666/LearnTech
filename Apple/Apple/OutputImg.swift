//
//  OutputImg.swift
//  Apple
//
//  Created by Y1616 on 2025/4/28.
//

import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct OutputImg {
    struct GifConfig {
        let frameCount: Int
        /// 单位: 秒
        let delayTime: CGFloat
        let outputPath: URL

        init(frameCount: Int = 30, delayTime: CGFloat = 0.05, outputPath: URL) {
            self.frameCount = frameCount
            self.delayTime = delayTime
            self.outputPath = outputPath
        }
    }
    
    static func outputGif(
        config: GifConfig,
        view: (CGFloat) -> some View
    ) -> Bool {
        let gifFrames = captureGIFFrames(frameCount: config.frameCount, view: view)
        return createGIF(from: gifFrames, delay: config.delayTime, outputURL: config.outputPath)
    }

    static func outputPNG(
        url: URL,
        view: () -> some View
    ) -> Bool {
        let renderer = ImageRenderer(content: view())
        renderer.scale = 4
        if let image = renderer.cgImage {
            return createPNG(from: image, outputURL: url)
        }
        return false
    }

    static func captureGIFFrames(
        frameCount: Int,
        view: (CGFloat) -> some View
    ) -> [CGImage] {
        var images = [CGImage]()
        var offset: CGFloat = 0
        let diffOffset = 1.0 / Double(frameCount)
        for _ in 0 ..< frameCount {
            let renderer = ImageRenderer(content: view(offset))
            renderer.scale = 2
            if let image = renderer.cgImage {
                images.append(image)
            }
            offset = offset + diffOffset
        }
        return images
    }

    static func createGIF(
        from images: [CGImage],
        delay: Double,
        outputURL: URL
    ) -> Bool {
        if let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            UTType.gif.identifier as CFString,
            images.count,
            nil
        ) {
            let frameProperties = [
                kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]
            ] as [CFString : Any]
            let gifProperties = [
                kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0], // 0 = 无限循环
            ] as [CFString : Any]

            CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)

            for cgImage in images {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }

            CGImageDestinationFinalize(destination)
            return true
        }
        return false
    }

    static func createPNG(from image: CGImage, outputURL: URL) -> Bool {
        if let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) {
            let options = [kCGImageDestinationLossyCompressionQuality: 1.0] as CFDictionary
            CGImageDestinationAddImage(destination, image, options)
            CGImageDestinationFinalize(destination)
            return true
        }
        return false
    }
}
