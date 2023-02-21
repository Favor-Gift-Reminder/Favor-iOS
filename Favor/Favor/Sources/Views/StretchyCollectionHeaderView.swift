//
//  StretchyCollectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/21.
//

import UIKit

import SnapKit

class StretchyCollectionHeaderView: UICollectionReusableView {

  // MARK: - Constants

  private enum Constant {
    static let headerHeight = 333.0
  }

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var containerView = UIView()

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: "MyPageHeaderPlaceholder")
    return imageView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public func scrollViewDidScroll(contentOffset: CGPoint, contentInset: NSDirectionalEdgeInsets) {
    let offsetY = -(contentOffset.y + contentInset.top)
    self.containerView.clipsToBounds = offsetY <= 0

    let height = max(offsetY + contentInset.top, contentInset.top)
    let bottom = offsetY >= 0 ? 0 : -offsetY / 2

//    self.imageView.snp.updateConstraints { make in
////      make.bottom.equalTo(bottom)
//      make.height.equalTo(Constant.headerHeight + height)
//    }
  }
}

extension StretchyCollectionHeaderView: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    self.addSubview(self.containerView)

    [
      self.imageView
    ].forEach {
      self.containerView.addSubview($0)
    }
  }

  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.width.height.equalToSuperview()
      make.centerX.equalToSuperview()
    }

    self.imageView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.height.width.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }
}
