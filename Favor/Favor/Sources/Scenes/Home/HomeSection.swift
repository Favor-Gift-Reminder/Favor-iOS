//
//  HomeSection.swift
//  Favor
//
//  Created by 이창준 on 2023/01/31.
//

import UIKit

import Composer
import FavorKit

// MARK: - Item

enum HomeSectionItem: ComposableItem {
  case upcoming(Upcoming)
  case timeline(Timeline)

  enum Upcoming: Hashable {
    case empty(UIImage?, String)
    case reminder(Reminder)
  }
  
  enum Timeline: Hashable {
    case empty(UIImage?, String)
    case gift(Gift)
  }
}

// MARK: - Section

public enum HomeSection: ComposableSection {
  case upcoming(isEmpty: Bool)
  case timeline(isEmpty: Bool)
}

// MARK: - Composer

extension HomeSection: Composable {
  public var item: UICollectionViewComposableLayout.Item {
    switch self {
    case .upcoming(let isEmpty):
      if isEmpty {
        return .full()
      } else {
        return .listRow(height: .absolute(95))
      }
    case .timeline(let isEmpty):
      if isEmpty {
        return .full()
      } else {
        return .grid(width: .fractionalWidth(0.5), height: .fractionalWidth(0.5))
      }
    }
  }

  public var group: UICollectionViewComposableLayout.Group {
    switch self {
    case .upcoming(let isEmpty):
      if isEmpty {
        return .custom(
          width: .fractionalWidth(1.0),
          height: .absolute(258),
          direction: .horizontal,
          numberOfItems: 1)
      } else {
        return .list(spacing: .fixed(10))
      }
    case .timeline(let isEmpty):
      if isEmpty {
        return .custom(
          width: .fractionalWidth(1.0),
          height: .absolute(258),
          direction: .horizontal,
          numberOfItems: 1)
      } else {
        return .grid(
          height: .fractionalWidth(0.5),
          numberOfItems: 2,
          spacing: .fixed(6)
        )
      }
    }
  }

  public var section: UICollectionViewComposableLayout.Section {
    switch self {
    case .upcoming(let isEmpty):
      let header: UICollectionViewComposableLayout.BoundaryItem = .header(height: .absolute(32.0))
      if isEmpty {
        return .base(
          contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20),
          boundaryItems: [header]
        )
      } else {
        return .base(
          spacing: 10,
          contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 40, trailing: 20),
          boundaryItems: [header]
        )
      }
    case .timeline(let isEmpty):
      if isEmpty {
        return .base(
          contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20),
          boundaryItems: [
            .header(height: .absolute(68))
          ]
        )
      } else {
        return .base(
          spacing: 3,
          contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: .zero, trailing: 20),
          boundaryItems: [
            .header(
              height: .absolute(68.0 + 16.0),
              contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: 16, trailing: .zero)
            ),
            .footer(height: .absolute(120))
          ]
        )
      }
    }
  }
}
