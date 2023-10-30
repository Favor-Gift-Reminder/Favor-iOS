//
//  Photo.swift
//  Favor
//
//  Created by 이창준 on 2023/07/07.
//

import Foundation

public struct Photo {
  let identifier: Int
  /// 서버 이미지의 주소
  let remote: String
  /// 로컬 이미지의 Cache Key
  let local: String
}
