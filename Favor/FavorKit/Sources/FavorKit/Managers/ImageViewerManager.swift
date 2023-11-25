//
//  ImageViewerManager.swift
//
//
//  Created by 김응철 on 11/26/23.
//

import UIKit

import ImageViewer

public final class ImageViewerManager {
  
  // MARK: - Properties
  
  private var galleryItems: [GalleryItem] = []
  
  private var configuration: GalleryConfiguration = {
    return [
      .closeButtonMode(.builtIn),
      .closeLayout(.pinLeft(28, 22)),
      .deleteButtonMode(.none),
      .thumbnailsButtonMode(.none),
      .pagingMode(.standard),
      .presentationStyle(.displacement),
      .hideDecorationViewsOnLaunch(false),
      .swipeToDismissMode(.vertical),
      .activityViewByLongPress(false),
      .maximumZoomScale(3.0),
      .swipeToDismissThresholdVelocity(500),
      .doubleTapToZoomDuration(0.3)
    ]
  }()
  
  // MARK: - Init
  
  public init() {}
  
  // MARK: - Functions
  
  public func presentToIamgeViewer(_ mappers: [CacheKeyMapper], startIndex: Int = 0) {
    let cache = ImageCacheManager()
    Task {
      for mapper in mappers {
        if cache.cacher.isCached(forKey: mapper.key) {
          let image: UIImage? = await cache.fetch(from: mapper)
          self.galleryItems.append(.image { $0(image) })
        } else {
          guard let url = URL(string: mapper.url) else { return }
          let image = try await ImageDownloadManager.downloadImage(with: url)
          cache.cache(image, mapper: mapper)
          self.galleryItems.append(.image { $0(image) })
        }
      }
      let viewController = await GalleryViewController(
        startIndex: startIndex,
        itemsDataSource: self,
        configuration: self.configuration
      )
      await UIApplication.shared.topViewController()?.present(viewController, animated: true)
    }
  }
}

extension ImageViewerManager: GalleryItemsDataSource {
  public func itemCount() -> Int {
    return self.galleryItems.count
  }
  
  public func provideGalleryItem(_ index: Int) -> ImageViewer.GalleryItem {
    return self.galleryItems[index]
  }
}
