//
//  CardCellData.swift
//  Favor
//
//  Created by 이창준 on 2023/03/14.
//

import UIKit

struct CardCellData: Equatable {
  /// 좌측 아이콘 이미지
  let iconImage: UIImage?
  /// 타이틀
  let title: String
  /// 타이틀 하단의 서브타이틀
  let subtitle: String
}
