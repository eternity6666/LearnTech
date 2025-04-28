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
        let width: CGFloat
        /// 单位: 秒
        let delayTime: CGFloat
        let outputPath: URL
    }
    
    
    static func outputGif(
        config: GifConfig,
        view: (CGFloat) -> some View
    ) -> Bool {
        let gifFrames = captureGIFFrames(frameCount: config.frameCount, width: config.width, view: view)
        return createGIF(from: gifFrames, delay: config.delayTime, outputURL: config.outputPath)
    }

    static func captureGIFFrames(
        frameCount: Int,
        width: CGFloat,
        view: (CGFloat) -> some View
    ) -> [CGImage] {
        var images = [CGImage]()
        var offset: CGFloat = 0
        var diffOffset = width / Double(frameCount)
        for _ in 0 ..< frameCount {
            let renderer = ImageRenderer(content: view(offset))
            renderer.scale = 0.5
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
                kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0] // 0 = 无限循环
            ] as [CFString : Any]
            
            CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
            
            for cgImage in images {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
            
            CGImageDestinationFinalize(destination)
            print("GIF saved at: \(outputURL)")
            return true
        }
        return false
    }
}
