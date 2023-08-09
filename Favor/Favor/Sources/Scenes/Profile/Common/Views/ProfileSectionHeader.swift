//
//  ProfileSectionHeader.swift
//  Favor
//
//  Created by 이창준 on 2023/02/13.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import SnapKit

final class ProfileSectionHeader: UICollectionReusableView, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private let headerTitle: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
    label.text = "헤더 타이틀"
    return label
  }()
  
  fileprivate let rightButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.subtext)

    let button = UIButton(configuration: config)
    return button
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
  
  func bind(reactor: ProfileSectionHeaderReactor) {
    // Action
    
    // State
    reactor.state.map { $0.title }
      .filter { $0 != nil }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, title in
        owner.headerTitle.text = title
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.rightButtonTitle }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, title in
        owner.rightButton.configuration?.updateAttributedTitle(
          title,
          font: .favorFont(.regular, size: 12)
        )
        owner.rightButton.isHidden = title == nil
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Setup

extension ProfileSectionHeader: BaseView {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    [
      self.headerTitle,
      self.rightButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.headerTitle.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
    }

    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.headerTitle.snp.centerY)
      make.trailing.equalToSuperview()
    }
  }
}

// MARK: - Reactive

extension Reactive where Base: ProfileSectionHeader {
  var rightButtonDidTap: ControlEvent<()> {
    return ControlEvent(events: base.rightButton.rx.tap)
  }
}
