//
//  PixelDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2025/3/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct PixelatedText: View {
    let text: String
    let fontSize: CGFloat
    
    // 渲染文本为图片，并像素化
    private func pixelatedImage(for text: String) -> UIImage {
        let font = UIFont.systemFont(ofSize: fontSize)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.green
        ]
        let originSize = text.size(withAttributes: attributes)
        let originWidth = originSize.width
        let originHeight = originSize.height
        let widthAndHeight = max(originWidth, originHeight)
        let size: CGSize = originSize
        
        // 创建一个图形上下文，设置大小
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // 渲染文本
        text.draw(
            in: .init(
                origin: .init(
                    x: (size.width - originSize.width) / 2,
                    y: (size.height - originSize.height) / 2
                ),
                size: size
            ),
            withAttributes: attributes
        )
        
        // 获取渲染的图像
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        getPixelColors(from: renderedImage)

        // 将图像进行像素化
        return pixelate(image: renderedImage)
    }
    
    // 将图像像素化
    private func pixelate(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let currentCIImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.pixellate()
        filter.inputImage = currentCIImage
        filter.scale = 5
        guard let outputImage = filter.outputImage else { return image }
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return image
        }
        return image
    }
    
    var body: some View {
        Image(uiImage: pixelatedImage(for: text))
            .resizable()
            .scaledToFit()
            .frame(height: fontSize * 1.5)
            .border(.black, width: 1)
    }
}

struct PixelatedView: View {
    @State private var inputText: String = "你123"
    @State private var fontSize: CGFloat = 40
    
    var body: some View {
        VStack {
            // 文本输入框
            TextField("Enter text", text: $inputText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 20))
            
            // 显示像素化 LED 风格文字
            PixelatedText(text: inputText, fontSize: fontSize)
        }
        .padding()
        .cornerRadius(10)
    }
}


func getPixelColors(from image: UIImage) {
    // 将图片转换为CGImage
    guard let cgImage = image.cgImage else {
        print("无法获取图片的CGImage")
        return
    }
    
    // 获取图片的宽高
    let width = cgImage.width
    let height = cgImage.height
    
    // 创建一个用于存储像素信息的像素缓冲区
    guard let pixelData = cgImage.dataProvider?.data else {
        print("无法获取图片数据")
        return
    }
    
    // 获取数据指针
    let data = CFDataGetBytePtr(pixelData)
    
    // 遍历所有像素并打印每个像素的颜色代码
    for y in 0..<height {
        for x in 0..<width {
            // 计算每个像素的偏移量
            let pixelInfo = ((width * y) + x) * 4
            
            // 获取当前像素的 RGBA 值
            let r = data![pixelInfo]
            let g = data![pixelInfo + 1]
            let b = data![pixelInfo + 2]
            let a = data![pixelInfo + 3]
            
            if r != 0 || g != 0 || b != 0 {
                // 打印颜色代码 (RGBA)
                print("Pixel at (\(x), \(y)): R:\(r) G:\(g) B:\(b) A:\(a)")
            }
        }
    }
}

#Preview(body: {
    PixelatedView()
        .colorScheme(.dark)
})
