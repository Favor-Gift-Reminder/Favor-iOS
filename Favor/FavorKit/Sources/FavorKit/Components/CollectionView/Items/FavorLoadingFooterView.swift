//
//  FavorLoadingFooterView.swift
//  Favor
//
//  Created by 이창준 on 2023/05/23.
//

import UIKit

import Reusable
import SnapKit

public final class FavorLoadingFooterView: UICollectionReusableView, Reusable {

  // MARK: - Properties

  // MARK: - UI Components

  private let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.hidesWhenStopped = true
    return spinner
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

  public func switchSpinning(to isAnimating: Bool) {
    if isAnimating {
      self.spinner.startAnimating()
    } else {
      self.spinner.stopAnimating()
    }
  }
}

// MARK: - UI Setups

extension FavorLoadingFooterView: BaseView {
  public func setupStyles() {
//    self.backgroundColor = .clear
  }

  public func setupLayouts() {
    self.addSubview(self.spinner)
  }

  public func setupConstraints() {
    self.spinner.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
