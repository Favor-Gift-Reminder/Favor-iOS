//
//  AnniversaryManagementSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum AnniversaryManagementSectionItem: ComposableItem {
  case name(String?)
  case category(AnniversaryCategory?)
  case date(Date?)
}

// MARK: - Section

public enum AnniversaryManagementSection: ComposableSection {
  case name
  case category
  case date
}

// MARK: - Properties

extension AnniversaryManagementSection {
  public var headerTitle: String {
    switch self {
    case .name: return "제목"
    case .category: return "종류"
    case .date: return "날짜"
    }
  }
}

// MARK: - Adaptive

extension AnniversaryManagementSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    return .listRow(height: .absolute(50))
  }

  public var group: UICollectionViewComposableLayout.Group {
    return .list()
  }

  public var section: UICollectionViewComposableLayout.Section {
    let header: UICollectionViewComposableLayout.BoundaryItem = .header(height: .absolute(22))
    let footer: UICollectionViewComposableLayout.BoundaryItem = .footer(height: .absolute(1))
    return .base(boundaryItems: [header, footer])
  }
}
