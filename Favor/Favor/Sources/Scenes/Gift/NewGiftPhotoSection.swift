//
//  PickedPictureSection.swift
//  Favor
//
//  Created by 김응철 on 2023/02/08.
//

import UIKit

import RxDataSources

struct NewGiftPhotoSection {
  typealias NewGiftPhotoSectionModel = SectionModel<Int, NewGiftSectionItem>
  
  enum NewGiftSectionItem {
    case empty
    case photo(UIImage)
  }
}
