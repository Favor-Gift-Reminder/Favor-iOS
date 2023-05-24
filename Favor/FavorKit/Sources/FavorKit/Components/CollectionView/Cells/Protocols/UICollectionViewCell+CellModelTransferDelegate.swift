//
//  UICollectionViewCell+CellModelTransferDelegate.swift
//  Favor
//
//  Created by 이창준 on 2023/05/22.
//

import UIKit

public protocol CellModelTransferDelegate: AnyObject {
  func transfer(_ model: (any CellModel)?, from cell: UICollectionViewCell)
}
