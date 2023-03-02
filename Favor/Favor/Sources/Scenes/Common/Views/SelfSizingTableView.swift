//
//  SelfSizingTableView.swift
//  Favor
//
//  Created by 이창준 on 2023/03/02.
//

import UIKit

class SelfSizingTableView: UITableView {
  override var contentSize: CGSize {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    self.layoutIfNeeded()
    return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height)
  }
}
