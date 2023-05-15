//
//  EditFriendCollectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/11.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class EditFriendCollectionHeaderView: UICollectionReusableView, Reusable {

  // MARK: - UI Components

  private let addButton: FavorAddButton = {
    let addButton = FavorAddButton()
    addButton.titleString = "직접 추가하기"
    return addButton
  }()

  private let divider = FavorDivider()

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
}

extension EditFriendCollectionHeaderView: BaseView {
  func setupStyles() {
    //
  }

  func setupLayouts() {
    [
      self.addButton,
      self.divider
    ].forEach {
      self.addSubview($0)
    }
  }

  func setupConstraints() {
    self.addButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.divider.snp.makeConstraints { make in
      make.top.equalTo(self.addButton.snp.bottom).offset(16)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}
