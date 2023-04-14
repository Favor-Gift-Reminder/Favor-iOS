//
//  SearchResultSection.swift
//  Favor
//
//  Created by 이창준 on 2023/04/14.
//

import UIKit

import RxDataSources

enum SearchResultSectionType {
  case gift, user
}

struct SearchResultSection {
  typealias SearchGiftResultModel = SectionModel<SearchResultSectionType, SearchResultItem>

  enum SearchResultItem {
    case gift(SearchGiftResultCellReactor)
    case user(SearchUserResultCellReactor)
  }
}

extension SearchResultSectionType {
  var cellSize: NSCollectionLayoutSize {
    switch self {
    case .gift:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(0.5),
        heightDimension: .fractionalWidth(0.5)
      )
    case .user:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    }
  }

  var columns: Int {
    switch self {
    case .gift: return 2
    case .user: return 1
    }
  }

  var spacing: CGFloat {
    switch self {
    case .gift: return 5.0
    case .user: return 0.0
    }
  }

  var sectionInset: NSDirectionalEdgeInsets {
    switch self {
    case .gift:
      return NSDirectionalEdgeInsets(
        top: 32,
        leading: 20,
        bottom: 32,
        trailing: 20
      )
    case .user:
      return NSDirectionalEdgeInsets(
        top: .zero,
        leading: 20,
        bottom: .zero,
        trailing: 20
      )
    }
  }
}
