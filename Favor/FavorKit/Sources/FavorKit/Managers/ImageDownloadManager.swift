//
//  ImageDownloadManager.swift
//
//
//  Created by 김응철 on 11/4/23.
//

import UIKit

import Kingfisher

public class ImageDownloadManager {
  static public func downloadImage(with url: URL) async throws -> UIImage {
    let image = try await withCheckedThrowingContinuation { continuation in
      ImageDownloader.default.downloadImage(with: url) { result in
        switch result {
        case .success(let image):
          continuation.resume(returning: image.image)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
    return image
  }
}
