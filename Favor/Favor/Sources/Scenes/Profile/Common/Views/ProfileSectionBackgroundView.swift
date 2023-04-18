//
//  ProfileSectionBackgroundView.swift
//  Favor
//
//  Created by 이창준 on 2023/04/18.
//

import UIKit

import FavorKit
import Reusable
import SnapKit

final class ProfileSectionBackgroundView: UICollectionReusableView, Reusable {

  // MARK: - Properties

//  var sectionType: ProfileSection = .profileSetupHelper(_) {
//
//  }

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

// MARK: - UI Setups

extension ProfileSectionBackgroundView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.white)
  }

  func setupLayouts() {
    //
  }

  func setupConstraints() {
    //
  }
}
