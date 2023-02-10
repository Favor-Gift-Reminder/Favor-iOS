//
//  PickedPictureSection.swift
//  Favor
//
//  Created by 김응철 on 2023/02/08.
//

import UIKit

import RxDataSources

enum PickedPictureSection {
  case first([PickedPictureSectionItem])
}

enum PickedPictureSectionItem {
  case pick(PickPictureCellReactor)
  case picked(PickedPictureCellReactor)
}

extension PickedPictureSection: SectionModelType {
  var items: [PickedPictureSectionItem] {
    switch self {
    case .first(let items): return items
    }
  }
  
  init(original: PickedPictureSection, items: [PickedPictureSectionItem]) {
    switch original {
    case .first: self = .first(items)
    }
  }
}
