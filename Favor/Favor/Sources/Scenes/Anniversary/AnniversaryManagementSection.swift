//
//  AnniversaryManagementSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import FavorKit

// MARK: - Item

public enum AnniversaryManagementSectionItem: SectionModelItem {
  case name(String?)
  case category
  case date(String?)
}

// MARK: - Section

public enum AnniversaryManagementSection: SectionModelType {
  case name
  case category
  case date
}

// MARK: - Hashable

extension AnniversaryManagementSectionItem {

}

extension AnniversaryManagementSection {

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

extension AnniversaryManagementSection: Adaptive {
  public var item: FavorCompositionalLayout.Item {
    return .listRow(height: .absolute(50))
  }

  public var group: FavorCompositionalLayout.Group {
    return .list()
  }

  public var section: FavorCompositionalLayout.Section {
    let header: FavorCompositionalLayout.BoundaryItem = .header(height: .absolute(22))
    let footer: FavorCompositionalLayout.BoundaryItem = .footer(height: .absolute(1))
    return .base(boundaryItems: [header, footer])
  }
}
