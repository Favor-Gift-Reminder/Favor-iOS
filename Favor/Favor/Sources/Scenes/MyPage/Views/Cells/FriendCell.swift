//
//  FriendCell.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import ReactorKit
import SnapKit

final class FriendCell: UICollectionViewCell, ReuseIdentifying, View {

  // MARK: - Constants

  var disposeBag = DisposeBag()

  // MARK: - Properties

  // MARK: - UI Components

  private lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 30
    imageView.backgroundColor = .lightGray
    return imageView
  }()

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 14)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    label.text = "이름"
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

  func bind(reactor: FriendCellReactor) {
    // Action

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

}

extension FriendCell: BaseView {
  func setupStyles() {
    // 
  }

  func setupLayouts() {
    [
      self.profileImageView,
      self.nameLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.centerX.equalToSuperview()
      make.width.height.equalTo(60)
    }

    self.nameLabel.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.bottom).offset(8)
      make.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
}
