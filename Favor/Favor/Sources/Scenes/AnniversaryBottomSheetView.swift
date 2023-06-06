//
//  AnniversaryBottomSheetView.swift
//  Favor
//
//  Created by 김응철 on 2023/05/23.
//

import UIKit

import FavorKit
import RxSwift
import SnapKit
import Then

final class AnniversaryBottomSheetView: UIView {
  
  private enum Metric {
    static let iconSize: CGFloat = 48.0
    static let iconLabelTopOffset: CGFloat = 16.0
  }
  
  // MARK: - UI Components
  
  private lazy var iconLabel: UILabel = UILabel().then {
    $0.textColor = .favorColor(.line3)
    $0.font = .favorFont(.regular, size: 16)
    $0.textAlignment = .center
    $0.text = self.anniversaryType.text
  }
  
  private lazy var iconImageView: UIImageView = UIImageView().then {
    $0.image = self.anniversaryType.image?.withRenderingMode(.alwaysTemplate)
  }
  
  // MARK: - Properties
  
  /// 현재 뷰가 가지고 있는 AnniversaryType입니다.
  let anniversaryType: AnniversaryCategory
  
  /// 선택이 되면 색깔이 바뀝니다.
  var isSelected: Bool = false {
    didSet {
      if isSelected {
        self.iconLabel.textColor = .favorColor(.main)
        self.iconImageView.tintColor = .favorColor(.main)
      } else {
        self.iconLabel.textColor = .favorColor(.line3)
        self.iconImageView.tintColor = .favorColor(.line3)
      }
    }
  }
  
  lazy var tapObservable = self.rx.tapGesture()
    .skip(1)
    .withUnretained(self)
    .flatMap { return Observable.just($0.0.anniversaryType) }
  
  // MARK: - Initializer
  
  init(_ anniversaryType: AnniversaryCategory) {
    self.anniversaryType = anniversaryType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Setup

extension AnniversaryBottomSheetView: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.iconImageView,
      self.iconLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    let labelWidth = self.iconLabel.intrinsicContentSize.width
    
    self.snp.makeConstraints { make in
      make.width.equalTo(labelWidth > 48.0 ? labelWidth : 48.0)
    }
    
    self.iconImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.iconSize)
      make.top.centerX.equalToSuperview()
    }

    self.iconLabel.snp.makeConstraints { make in
      make.top.equalTo(self.iconImageView.snp.bottom).offset(Metric.iconLabelTopOffset)
      make.centerX.bottom.equalToSuperview()
    }
  }
}
