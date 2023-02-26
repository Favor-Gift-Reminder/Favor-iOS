//
//  MyPageSectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/13.
//

import UIKit

import ReactorKit
import Reusable
import SnapKit

final class MyPageSectionHeaderView: UICollectionReusableView, Reusable, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var headerTitle: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
    label.text = "헤더 타이틀"
    return label
  }()

  private lazy var rightButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .favorColor(.explain)

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
  
  func bind(reactor: MyPageSectionHeaderViewReactor) {
    // Action
    
    // State
    reactor.state.map { $0.sectionType }
      .filter { $0 != nil }
      .bind(with: self, onNext: { owner, sectionType in
        owner.headerTitle.text = sectionType?.headerTitle

        if let buttonTitle = sectionType?.headerRightItemTitle {
          var titleContainer = AttributeContainer()
          titleContainer.foregroundColor = .favorColor(.explain)
          titleContainer.font = .favorFont(.regular, size: 12)
          owner.rightButton.configuration?.attributedTitle = AttributedString(buttonTitle, attributes: titleContainer)
        } else {
          owner.rightButton.isHidden = true
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.title }
      .filter { $0 != nil }
      .asDriver(onErrorJustReturn: "")
      .drive(with: self, onNext: { owner, title in
        owner.headerTitle.text = title
      })
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Setup

extension MyPageSectionHeaderView: BaseView {
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
      make.top.leading.trailing.equalToSuperview()
    }

    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.headerTitle.snp.centerY)
      make.trailing.equalToSuperview()
    }
  }
}
