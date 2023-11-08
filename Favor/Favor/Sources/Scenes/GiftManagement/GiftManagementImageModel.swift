//
//  GiftManagementImageModel.swift
//  Favor
//
//  Created by 김응철 on 11/6/23.
//

import UIKit

public struct GiftManagementPhotoModel: Hashable {
  /// 해당 속성이 있으면 Url로 가져온 사진임을 의미합니다.
  /// 또, 기존 사진을 삭제 시킬 때 필요합니다.
  let url: String?
  let isNew: Bool
  let image: UIImage?
}
