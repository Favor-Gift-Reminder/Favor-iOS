//
//  EditMyPagePreferenceSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/25.
//

import UIKit

import FavorKit
import RxDataSources

struct EditMyPagePreferenceSection {
  var header: String
  var items: [EditMyPagePreferenceCellReactor]
}

extension EditMyPagePreferenceSection: SectionModelType {
  init(original: EditMyPagePreferenceSection, items: [EditMyPagePreferenceCellReactor]) {
    self = original
    self.items = items
  }
}

extension EditMyPagePreferenceSection: Adaptive {
  var item: FavorCompositionalLayout.Item {
    return .grid(
      width: .estimated(63),
      height: .absolute(33),
      contentInsets: nil
    )
  }

  var group: FavorCompositionalLayout.Group {
    return .flow(
      height: .estimated(33),
      numberOfItems: 6,
      spacing: .fixed(10),
      contentInsets: nil
    )
  }

  var section: FavorCompositionalLayout.Section {
    return .base(
      spacing: 10,
      contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20),
      orthogonalScrolling: .continuousGroupLeadingBoundary,
      boundaryItems: nil,
      decorationItems: nil
    )
  }
}
