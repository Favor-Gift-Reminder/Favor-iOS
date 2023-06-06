//
//  GiftManagementCategoryViewCell.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import FavorKit
import RxCocoa
import RxSwift
import SnapKit

public protocol GiftManagementCategoryViewCellDelegate: AnyObject {
  func categoryDidUpdate(to category: FavorCategory)
}

final class GiftManagementCategoryViewCell: BaseCollectionViewCell {

  // MARK: - Properties

  public weak var delegate: GiftManagementCategoryViewCellDelegate?

  // MARK: - UI Components

  private let categoryView: FavorCategoryView = {
    let categoryView = FavorCategoryView()
    categoryView.contentInset = UIEdgeInsets(top: .zero, left: 20, bottom: .zero, right: 20)
    return categoryView
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bind

  private func bind() {
    self.categoryView.currentCategory
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, category in
        owner.delegate?.categoryDidUpdate(to: category)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  public func bind(with category: FavorCategory) {
    self.categoryView.setSelectedCategory(category)
  }
}

// MARK: - UI Setups

extension GiftManagementCategoryViewCell: BaseView {
  func setupStyles() { }

  func setupLayouts() {
    self.addSubview(self.categoryView)
  }

  func setupConstraints() {
    self.categoryView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
