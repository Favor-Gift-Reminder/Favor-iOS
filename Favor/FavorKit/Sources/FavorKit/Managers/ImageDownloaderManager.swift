//
//  ImageDownloaderManager.swift
//
//
//  Created by 김응철 on 10/30/23.
//

import UIKit

import Kingfisher

public class ImageDownloaderManager {
  public static func downloadImage(from url: URL, completion: @escaping ((UIImage?) -> Void)) {
    KingfisherManager.shared.retrieveImage(with: url) { result in
      switch result {
      case .success(let imageResult):
        completion(imageResult.image)
      case .failure(let error):
        print("ERROR: \(error.localizedDescription)")
        completion(nil)
      }
    }
  }
}
