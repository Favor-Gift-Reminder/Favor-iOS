//
//  EditMyPageSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/30.
//

import UIKit

import FavorKit

enum EditMyPageSectionItem: SectionModelItem {
  case textField(text: String, placeholder: String)
  case favor(isSelected: Bool, favor: Favor)
}

enum EditMyPageSection {
  case name
  case id
  case favor
}

extension EditMyPageSection: SectionModelType {
  public var header: String {
    switch self {
    case .name: return "이름"
    case .id: return "ID"
    case .favor: return "취향"
    }
  }

  public var footer: String? {
    switch self {
    case .name, .id: return nil
    case .favor: return "최대 5개까지 선택할 수 있습니다."
    }
  }
}

extension EditMyPageSection: Adaptive {
  var item: FavorCompositionalLayout.Item {
    switch self {
    case .name, .id:
      return .listRow(height: .absolute(19))
    case .favor:
      return .grid(width: .estimated(63), height: .absolute(32))
    }
  }

  var group: FavorCompositionalLayout.Group {
    switch self {
    case .name, .id:
      return .list()
    case .favor:
      let innerGroup: FavorCompositionalLayout.Group = .flow(
        height: .absolute(32),
        numberOfItems: 6,
        spacing: .fixed(10)
      )
      return .custom(
        width: .estimated(500),
        height: .absolute(116),
        direction: .vertical,
        numberOfItems: 3,
        spacing: .fixed(10),
        innerGroup: innerGroup
      )
    }
  }

  var section: FavorCompositionalLayout.Section {
    switch self {
    case .name, .id:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20),
        boundaryItems: [
          .header(
            height: .absolute(37),
            contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: 16, trailing: .zero)
          ),
          .footer(
            height: .absolute(17),
            contentInsets: NSDirectionalEdgeInsets(top: 16, leading: .zero, bottom: .zero, trailing: .zero)
          )
        ]
      )
    case .favor:
      return .base(
        spacing: 10,
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20),
        orthogonalScrolling: .continuous,
        boundaryItems: [
          .header(
            height: .absolute(37),
            contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: 16, trailing: .zero)
          ),
          .footer(
            height: .absolute(43),
            contentInsets: NSDirectionalEdgeInsets(top: 16, leading: .zero, bottom: .zero, trailing: .zero)
          )
        ]
      )
    }
  }
}
