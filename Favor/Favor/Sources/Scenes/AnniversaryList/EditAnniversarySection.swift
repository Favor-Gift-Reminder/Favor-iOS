//
//  EditAnniversarySection.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import UIKit

import FavorKit

public enum EditAnniversarySectionItem: SectionModelItem {

}

public enum EditAnniversarySection: SectionModelType {

}

// MARK: - Hashable

extension EditAnniversarySectionItem {

}

extension EditAnniversarySection {

}

// MARK: - Adaptive

extension EditAnniversarySection: Adaptive {
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
