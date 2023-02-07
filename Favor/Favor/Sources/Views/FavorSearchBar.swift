//
//  FavorSearchBar.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import SnapKit

class FavorSearchBar: UISearchBar {
  
  // MARK: - Properties
  
  /// SearchBar 전체 높이
  var height: CGFloat = 40.0
  
  /// 왼쪽에 있는 아이콘의 이미지
  var leftItemImage: UIImage? = UIImage(named: "ic_Search") {
    didSet {
      self.updateSearchItem()
    }
  }
  
  /// SearchBar에 내장되어 있는 TextField의 Corner Radius
  var cornerRadius: CGFloat = 20.0 {
    didSet {
      self.updateTextField()
    }
  }
  
  /// SearchBar에 내장되어 있는 TextField의 placeholder 텍스트
  override var placeholder: String? {
    didSet {
      self.updateTextField()
    }
  }
  
  /// placeholder 텍스트의 색상
  var placeholderColor: UIColor = .favorColor(.detail) {
    didSet {
      self.updateTextField()
    }
  }
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupBaseSearchBar()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupBaseSearchBar() {
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.updateTextField()
    self.updateSearchItem()
  }
  
  // MARK: - Functions
  
  /// SearchBar에 내장되어 있는 TextField를 업데이트합니다.
  func updateTextField() {
    self.searchTextField.layer.cornerRadius = self.cornerRadius
    
    let attributedString = NSAttributedString(
      string: self.placeholder ?? "",
      attributes: [
        NSAttributedString.Key.foregroundColor: self.placeholderColor,
        NSAttributedString.Key.font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    self.searchTextField.attributedPlaceholder = attributedString
    self.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
  }
  
  func updateSearchItem() {
    self.setImage(self.leftItemImage, for: .search, state: .normal)
    self.setPositionAdjustment(UIOffset(horizontal: 16, vertical: 0), for: .search)
  }
}

// MARK: - Setup

extension FavorSearchBar: BaseView {
  func setupStyles() {
    self.searchBarStyle = .minimal
    self.backgroundColor = .clear
    self.searchTextField.backgroundColor = .favorColor(.background)
    self.searchTextField.clipsToBounds = true
  }
  
  func setupLayouts() {
    //
  }
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(self.height)
    }
    self.searchTextField.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
