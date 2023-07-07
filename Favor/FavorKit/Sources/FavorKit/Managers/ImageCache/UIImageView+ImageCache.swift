//
//  UIImageView+ImageCache.swift
//  Favor
//
//  Created by 이창준 on 2023/07/07.
//

import UIKit

import Kingfisher

extension UIImageView {
  /// Kingfisher의 `setImage` 메서드를 **Favor**에 맞게 wrapping한 메서드
  public func setImage(with source: Source?, mapper: CacheKeyMapper) {
    let cache = ImageCacheManager()
    let preferredSize = mapper.preferredSize ?? CGSize(width: 80, height: 80)
    let downsamplingProcessor = DownsamplingImageProcessor(size: preferredSize)
    
    Task {
      self.kf.indicatorType = .activity
      let cachedImage: UIImage? = await cache.fetch(from: mapper)
      let options: KingfisherOptionsInfo = [
        .processor(downsamplingProcessor),
        .retryStrategy(DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2)))
      ]
      
      self.kf.setImage(
        with: source,
        placeholder: cachedImage,
        options: options
      )
    }
  }
}
