//
//  NewAnniversaryHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/25.
//

import UIKit

import ReactorKit
import SnapKit

final class NewAnniversaryHeaderView: UICollectionReusableView, ReuseIdentifying, View {

  // MARK: - Constants

  // MARK: - Properties

  var disposeBag = DisposeBag()

  // MARK: - UI Components

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = .favorFont(.bold, size: 18)
    label.text = "기념일"
    return label
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

  // MARK: - Binding

  func bind(reactor: NewAnniversaryHeaderViewReactor) {
    // Action

    // State

  }

  // MARK: - Functions

}

// MARK: - Setup

extension NewAnniversaryHeaderView: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    [
      self.titleLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
    }
  }
}
