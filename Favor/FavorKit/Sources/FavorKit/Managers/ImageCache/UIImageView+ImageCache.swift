//
//  UIImageView+ImageCache.swift
//  Favor
//
//  Created by 이창준 on 2023/07/07.
//

import OSLog
import UIKit

import Kingfisher

extension UIImageView {
  /// Kingfisher의 `setImage` 메서드를 **Favor**에 맞게 wrapping한 메서드
  public func setImage(from url: URL, mapper: CacheKeyMapper) {
    let cache = ImageCacheManager()
    let preferredSize = mapper.preferredSize ?? CGSize(width: 80, height: 80)
    let downsamplingProcessor = DownsamplingImageProcessor(size: preferredSize)
    
    Task(priority: .high) {
      self.kf.indicatorType = .activity
      let cachedImage: UIImage? = await cache.fetch(from: mapper)
      self.image = cachedImage
      
      let options: KingfisherOptionsInfo = [
        .processor(downsamplingProcessor),
        .targetCache(cache.cacher),
        .keepCurrentImageWhileLoading,
        .retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2)))
      ]
      
      let resource: Resource = KF.ImageResource(downloadURL: url, cacheKey: mapper.key)
      let source: Source = .network(resource)
      self.kf.setImage(with: source, options: options)
      
      let disk = try await cache.cacher.diskStorageSize
      os_log(.debug, "💿 Disk storage size in use: \(disk)")
    }
  }
}
