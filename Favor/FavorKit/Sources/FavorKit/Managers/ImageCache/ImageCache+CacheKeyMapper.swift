//
//  ImageCache+CacheKeyMapper.swift
//  Favor
//
//  Created by 이창준 on 2023/07/07.
//

import CoreGraphics

import Kingfisher

/// `User`, `Friend`, `Gift`로부터 이미지 캐싱 키를 생성하는 Mapper 구조체입니다.
///
/// `"Category/Identifier/\(subpath)"`로 구성됩니다.
/// ### example
/// ```plain
/// "user/24/profilePhoto"
/// "gift/13/image/1"
/// ```
/// - Note: 각 `Storable`에 대한 생성자는 해당 파일의 `extension`으로 정의되어 있습니다.
public struct CacheKeyMapper {
  public let key: String
  public let cacheType: CacheType
  public var preferredSize: CGSize?
  
  /// 각 `Storable`의 생성자에서 사용되는 생성자입니다.
  public init(key: String, cacheType: CacheType) {
    self.key = key
    self.cacheType = cacheType
  }
}
