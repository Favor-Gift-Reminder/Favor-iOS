//
//  CoreGraphicManager.swift
//  Favor
//
//  Created by 이창준 on 2023/01/18.
//

import UIKit
import UniformTypeIdentifiers

final class CoreGraphicManager {
    
  /**
   CGImage를 다운샘플링 한 뒤 UIImage로 디코딩하여 반환합니다.
   - Parameters:
      - url: 이미지(URL 타입).
      - pointSize: 목표 이미지 크기.
      - scale: 디바이스의 Scale (`UIScreen.main.scale`)
   - Returns: `Data?` (UIImage로 Decodable).
   */
  func downsample(at url: URL, toSize pointSize: CGSize, screenScale: CGFloat) -> Data? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }
    
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * screenScale
    let downsampleOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ] as CFDictionary
    
    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else { return nil }
    
    let data = NSMutableData()
    
    guard let imageDestination = CGImageDestinationCreateWithData(
      data, UTType.jpeg.identifier as CFString, 1, nil
    ) else { return nil }
    
    let isPNG: Bool = {
      guard let utType = cgImage.utType else { return false }
      return (utType as String) == UTType.png.identifier
    }()
    
    let destinationProperties = [
      kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.75
    ] as CFDictionary
    
    CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
    CGImageDestinationFinalize(imageDestination)
    
    return data as Data
  }
}
