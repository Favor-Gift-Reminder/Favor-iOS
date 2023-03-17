//
//  BaseBottomSheetViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/03/17.
//

import UIKit

open class BaseBottomSheetViewController: BaseViewController {

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    if let sheet = self.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.preferredCornerRadius = 24
    }
  }
}
