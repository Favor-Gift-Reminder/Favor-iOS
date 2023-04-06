//
//  BaseBottomSheetViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/03/17.
//

import UIKit

import FavorKit
import SnapKit

open class BaseBottomSheetViewController: BaseViewController {

  // MARK: - UI Components

  public lazy var topMenuContainerView = UIView()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    label.text = "팝업"
    return label
  }()

  // MARK: - Life Cycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    if let sheet = self.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.preferredCornerRadius = 24
    }
  }

  // MARK: - UI Setup

  open override func setupLayouts() {
    self.view.addSubview(self.topMenuContainerView)
    self.topMenuContainerView.addSubview(self.titleLabel)
  }

  open override func setupConstraints() {
    self.topMenuContainerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.height.equalTo(32)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  // MARK: - Functions

  public func updateTitle(_ title: String) {
    self.titleLabel.text = title
  }
}
