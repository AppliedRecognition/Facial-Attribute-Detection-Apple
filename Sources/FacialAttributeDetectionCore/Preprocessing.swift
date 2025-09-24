//
//  Preprocessing.swift
//
//
//  Created by Jakub Dolejs on 15/09/2025.
//

import Foundation
import UIKit
import CoreML
import Accelerate

enum Preprocessing {
    
    static func modelInputFromAlignedFaceImage(_ image: UIImage) throws -> MLMultiArray {
        guard let cgImage = image.cgImage else {
            throw NSError()
        }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        guard let data = malloc(height * bytesPerRow) else {
            throw NSError()
        }
        var buffer = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
        defer {
            buffer.free()
        }
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        guard let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo) else {
            throw NSError()
        }
        let rect = CGRect(origin: .zero, size: image.size)
        context.draw(cgImage, in: rect)
        let pixelCount = width * height
        let totalCount = pixelCount * 3
        var contiguous: [UInt8] = Array(repeating: 0, count: totalCount)
        try contiguous.withUnsafeMutableBufferPointer { buf in
            var a = try vImage_Buffer(size: CGSize(width: width, height: height), bitsPerPixel: 8)
            var r = vImage_Buffer(data: buf.baseAddress!, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: width)
            var g = vImage_Buffer(data: buf.baseAddress!.advanced(by: pixelCount), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: width)
            var b = vImage_Buffer(data: buf.baseAddress!.advanced(by: pixelCount * 2), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: width)
            guard vImageConvert_ARGB8888toPlanar8(&buffer, &a, &r, &g, &b, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
                throw NSError()
            }
        }
        var contiguousF = [Float](repeating: 0, count: totalCount)
        vDSP_vfltu8(&contiguous, 1, &contiguousF, 1, vDSP_Length(totalCount))
        let minF: Float = -1
        let maxF: Float = 1
        var scale = (maxF - minF) / 255.0
        var offset = minF
        contiguousF.withUnsafeMutableBufferPointer { buf in
            let ptr = buf.baseAddress!
            vDSP_vsmsa(ptr, 1, &scale, &offset, ptr, 1, vDSP_Length(totalCount))
        }
        let multiArray = try MLMultiArray(shape: [1, 3, NSNumber(value: width), NSNumber(value: height)], dataType: .float32)
        contiguousF.withUnsafeBufferPointer { buf in
            memcpy(multiArray.dataPointer, buf.baseAddress!, buf.count * MemoryLayout<Float>.size)
        }
        return multiArray
    }
}
