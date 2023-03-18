//
//  FavorSearchBar.swift
//  Favor
//
//  Created by 이창준 on 2023/02/07.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

public class FavorSearchBar: UIView {
  
  // MARK: - Properties
  
  /// 왼쪽 버튼의 크기 (1:1 ratio)
  public var leftItemSize: CGFloat = 48.0 {
    didSet {
      self.updateLeftItem()
    }
  }
  
  /// SearchBar의 높이
  public var searchBarHeight: CGFloat = 40.0
  
  /// 왼쪽에 있는 아이콘의 이미지
  public var leftItemImage: UIImage? = .favorIcon(.search) {
    didSet {
      self.updateSearchItem()
    }
  }
  
  /// SearchBar에 내장되어 있는 TextField의 Corner Radius
  public var cornerRadius: CGFloat = 20.0 {
    didSet {
      self.updateTextField()
    }
  }
  
  /// SearchBar에 내장되어 있는 TextField의 placeholder 텍스트
  public var placeholder: String? {
    didSet {
      self.updateTextField()
    }
  }
  
  /// placeholder 텍스트의 색상
  public var placeholderColor: UIColor = .favorColor(.explain) {
    didSet {
      self.updateTextField()
    }
  }
  
  // MARK: - UI Components

  /// SearchBar의 textField에 짧게 접근하기 위한 프로퍼티
  public var textField: UITextField {
    self.searchBar.searchTextField
  }
  
  public lazy var leftItem: UIButton = {
    var configuration = UIButton.Configuration.plain()
    configuration.baseForegroundColor = .favorColor(.icon)
    configuration.image = UIImage(systemName: "chevron.backward")
    
    let button = UIButton(configuration: configuration)
    return button
  }()
  
  public lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.searchBarStyle = .minimal
    searchBar.backgroundColor = .clear
    searchBar.searchTextField.backgroundColor = .favorColor(.background)
    searchBar.searchTextField.clipsToBounds = true
    searchBar.placeholder = "플레이스 홀더 메시지"
    searchBar.autocapitalizationType = .none
    return searchBar
  }()
  
  private lazy var searchStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 18
    stackView.alignment = .center
    [
      self.leftItem,
      self.searchBar
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }()
  
  // MARK: - Initializer
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.setupBaseSearchBar()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupBaseSearchBar() {
    self.updateTextField()
    self.updateSearchItem()
  }
  
  // MARK: - Functions
  
  public func updateLeftItem() {
    self.leftItem.snp.updateConstraints { make in
      make.height.width.equalTo(self.leftItemSize)
    }
  }
  
  public func updateLeftItemVisibility(isHidden: Bool) {
    let duration = isHidden ? 0.3 : 0.4
    DispatchQueue.main.async {
      UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
        self.leftItem.isHidden = isHidden
      }
    }
  }
  
  /// SearchBar에 내장되어 있는 TextField를 업데이트합니다.
  public func updateTextField() {
    self.searchBar.searchTextField.layer.cornerRadius = self.cornerRadius
    
    let attributedString = NSAttributedString(
      string: self.placeholder ?? "",
      attributes: [
        NSAttributedString.Key.foregroundColor: self.placeholderColor,
        NSAttributedString.Key.font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    self.searchBar.searchTextField.attributedPlaceholder = attributedString
    self.searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
  }
  
  public func updateSearchItem() {
    self.searchBar.setImage(self.leftItemImage, for: .search, state: .normal)
    self.searchBar.setPositionAdjustment(UIOffset(horizontal: 16, vertical: 0), for: .search)
  }
}

// MARK: - Setup

extension FavorSearchBar {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    [
      self.searchStack
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.searchStack.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(self.leftItemSize)
    }
    self.leftItem.snp.makeConstraints { make in
      make.width.height.equalTo(self.leftItemSize)
    }
    self.searchBar.snp.makeConstraints { make in
      make.height.equalTo(self.searchBarHeight)
    }
  }
}

public extension Reactive where Base: FavorSearchBar {
  var leftItemDidTap: ControlEvent<()> {
    let source = base.leftItem.rx.tap
    return ControlEvent(events: source)
  }

  var editingDidBegin: ControlEvent<()> {
    let source = base.searchBar.searchTextField.rx.controlEvent(.editingDidBegin)
    return ControlEvent(events: source)
  }

  var editingDidEnd: ControlEvent<()> {
    let source = base.searchBar.searchTextField.rx.controlEvent(.editingDidEnd)
    return ControlEvent(events: source)
  }

  var editingDidEndOnExit: ControlEvent<()> {
    let source = base.searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
    return ControlEvent(events: source)
  }
}
