//
//  GiftManagementSection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

public enum GiftManagementSectionItem: ComposableItem {
  case title
  case category
  case photo(GiftManagementPhotoModel?)
  case friends([Friend])
  case date
  case memo
  case pin
}

// MARK: - Section

public enum GiftManagementSection: ComposableSection {
  case title
  case category
  case photos
  case friends(isGiven: Bool)
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

// MARK: - Composable

extension GiftManagementSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
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
      return .listRow(height: .estimated(113))
    case .pin:
      return .full()
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    switch self {
    case .title:
      return .grid(height: .absolute(20), numberOfItems: 1)
    case .category:
      return .grid(height: .absolute(32), numberOfItems: 1)
    case .photos:
      return .flow(
        height: .absolute(100),
        numberOfItems: 6,
        spacing: .fixed(6)
      )
    case .friends:
      return .grid(height: .absolute(20), numberOfItems: 1)
    case .date:
      return .grid(height: .absolute(20), numberOfItems: 1)
    case .memo:
      return .singleFullList(height: .absolute(169))
    case .pin:
      return .grid(height: .absolute(22), numberOfItems: 1)
    }
  }

  public var section: UICollectionViewComposableLayout.Section {
    let sectionHeader: UICollectionViewComposableLayout.BoundaryItem = .header(
      height: .absolute(22)
    )
    let sectionFooter: UICollectionViewComposableLayout.BoundaryItem = .footer(
      height: .absolute(1)
    )
    let defaultSection: UICollectionViewComposableLayout.Section = .base(
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
