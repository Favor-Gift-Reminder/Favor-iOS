//
//  ImageCache+Manager.swift
//  Favor
//
//  Created by 이창준 on 2023/07/07.
//

import PhotosUI
import UIKit

import Kingfisher

public final class ImageCacheManager {
  
  // MARK: - Enums
  
  public enum ImageType {
    case image, livePhoto
  }
  
  public enum Metric {
    public static let bannerSize: CGSize = CGSize(width: 500.0, height: 440.0)
    public static let profileSize: CGSize = CGSize(width: 90.0, height: 90.0)
  }
  
  // MARK: - Constants
  
  public static let cacheName = "com.favor.Favor.iOS.ImageCache"
  public static let processor = "com.favor.Favor.iOS.FavorProcessor"
  
  // MARK: - Properties
  
  public let cacher: ImageCache
  
  // MARK: - Initialzier
  
  public init() {
    let cache = ImageCache(name: ImageCacheManager.cacheName)
    cache.memoryStorage.config.expiration = .seconds(600)
    cache.memoryStorage.config.cleanInterval = 60
    cache.diskStorage.config.expiration = .never
    self.cacher = cache
  }
  
  // MARK: - Functions
  
  /// 캐시에 이미지를 저장합니다.
  ///
  /// - Parameters:
  ///   - asset: 캐시에 저장할 이미지 (`UIImage`, `PHLivePhoto`)
  ///   - mapper: 캐시에 저장할 키를 생성하는 `CacheKeyMapper`
  public func cache(_ asset: Any, mapper: CacheKeyMapper) {
    if let image = asset as? UIImage {
      self.cacher.store(image, forKey: mapper.key)
    } else if let livePhoto = asset as? PHLivePhoto {
      // TODO: Cache Live Photo
    }
  }
  
  /// 캐시에 저장된 이미지를 불러옵니다.
  ///
  /// - Parameters:
  ///   - mapper: 캐시에 저장한 키를 얻기 위한 `CacheKeyMapper`
  ///
  /// - Returns: `UIImage?` 혹은 `PHLivePhoto?`
  public func fetch<T>(from mapper: CacheKeyMapper) async -> T? {
    if self.cacher.isCached(forKey: mapper.key) {
      if T.self is UIImage.Type {
        if let image = try? await self.fetchImage(forKey: mapper.key) as? T {
          return image
        }
      } // TODO: Live Photo
    }
    return nil
  }
  
  private func fetchImage(forKey key: String) async throws -> UIImage? {
    return try await withUnsafeThrowingContinuation { continuation in
      self.cacher.retrieveImage(forKey: key) { result in
        switch result {
        case .success(let cacheResult):
          continuation.resume(returning: cacheResult.image)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
