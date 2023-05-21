//
//  AnniversaryListCellModel.swift
//  Favor
//
//  Created by 이창준 on 2023/05/20.
//

import FavorKit

public struct AnniversaryListCellModel: CellModel {
  public var item: Anniversary
  public var cellType: AnniversaryListCell.CellType
  public var sectionType: AnniversaryListSection
}
