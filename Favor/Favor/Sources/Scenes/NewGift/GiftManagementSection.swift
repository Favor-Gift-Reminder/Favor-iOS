//
//  GiftManagementSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit

// MARK: - Item

public enum GiftManagementSectionItem: SectionModelItem {
  case title
  case category
  case photo(UIImage?)
  case friends
  case date
  case memo
  case pin
}

// MARK: - Section

public enum GiftManagementSection: SectionModelType {
  case title
  case category
  case photos
  case friends
  case date
  case memo
  case pin
}

// MARK: - Properties

extension GiftManagementSection {
  public var header: String {
    switch self {
    case .title: return "제목"
    case .category: return "카테고리"
    case .photos: return "사진"
    case .friends: return "준 사람"
    case .date: return "날짜"
    case .memo: return "메모"
    case .pin: return ""
    }
  }
}

// MARK: - Hashable

extension GiftManagementSectionItem: Hashable {
  public static func == (lhs: GiftManagementSectionItem, rhs: GiftManagementSectionItem) -> Bool {
    switch (lhs, rhs) {
    case (.title, .title):
      return true
    case (.category, .category):
      return true
    case let (.photo(lhsImage), .photo(rhsImage)):
      return lhsImage == rhsImage
    case (.friends, .friends):
      return true
    case (.date, .date):
      return true
    case (.memo, .memo):
      return true
    case (.pin, .pin):
      return true
    default:
      return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .title:
      hasher.combine("title")
    case .category:
      hasher.combine("category")
    case .photo(let image):
      hasher.combine(image)
    case .friends:
      hasher.combine("friends")
    case .date:
      hasher.combine("date")
    case .memo:
      hasher.combine("memo")
    case .pin:
      hasher.combine("pin")
    }
  }
}

// MARK: - Adaptive

extension GiftManagementSection: Adaptive {
  public var item: FavorKit.FavorCompositionalLayout.Item {
    switch self {
    case .title:
      return .full()
    case .category:
      return .full()
    case .photos:
      return .grid(width: .absolute(100), height: .absolute(100))
    case.friends:
      return .full()
    case .date:
      return .full()
    case .memo:
      return .full()
    case .pin:
      return .full()
    }
  }

  public var group: FavorKit.FavorCompositionalLayout.Group {
    switch self {
    case .title:
      return .grid(height: .absolute(20), numberOfItems: 1)
    case .category:
      return .grid(height: .absolute(32), numberOfItems: 1)
    case .photos:
      return .flow(
        height: .absolute(100),
        numberOfItems: 5,
        spacing: .fixed(6)
      )
    case .friends:
      return .grid(height: .absolute(20), numberOfItems: 1)
    case .date:
      return .grid(height: .absolute(20), numberOfItems: 1)
    case .memo:
      return .grid(height: .estimated(130), numberOfItems: 1)
    case .pin:
      return .grid(height: .absolute(22), numberOfItems: 1)
    }
  }

  public var section: FavorKit.FavorCompositionalLayout.Section {
    let sectionHeader: FavorCompositionalLayout.BoundaryItem = .header(
      height: .absolute(22)
    )
    let sectionFooter: FavorCompositionalLayout.BoundaryItem = .footer(
      height: .absolute(1)
    )
    let defaultSection: FavorCompositionalLayout.Section = .base(
      spacing: nil,
      contentInsets: NSDirectionalEdgeInsets(
        top: 15, leading: 20, bottom: 15, trailing: 20),
      orthogonalScrolling: nil,
      boundaryItems: [sectionHeader, sectionFooter],
      decorationItems: nil
    )
    
    switch self {
    case .title:
      return defaultSection
    case .category:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(
          top: 15, leading: .zero, bottom: .zero, trailing: .zero),
        boundaryItems: [
          .header(
            height: .absolute(22),
            contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20)
          )
        ]
      )
    case .photos:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(
          top: 15, leading: 20, bottom: .zero, trailing: 20),
        orthogonalScrolling: .continuous,
        boundaryItems: [sectionHeader]
      )
    case .friends:
      return defaultSection
    case .date:
      return defaultSection
    case .memo:
      return defaultSection
    case .pin:
      return .base(
        contentInsets: NSDirectionalEdgeInsets(
          top: .zero, leading: 20, bottom: .zero, trailing: 20)
      )
    }
  }
}
