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
   Downsample CGImage before decoding them into UIImage
   - Parameters:
      - url: URL of image.
      - pointSize: Target size for resizing image.
      - scale: Scale of the device (`UIScreen.main.scale`)
   - Returns: `Data?` which can be decoded as image.
   */
  func downsample(at url: URL, to pointSize: CGSize, scale: CGFloat) -> Data? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }
    
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
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
