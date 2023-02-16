//
//  MyPageSectionHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/13.
//

import UIKit

import ReactorKit
import SnapKit

final class MyPageSectionHeaderView: UICollectionReusableView, ReuseIdentifying, View {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var headerTitle: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 20)
    label.text = "헤더 타이틀"
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
  
  func bind(reactor: MyPageSectionHeaderReactor) {
    // Action
    
    // State
    reactor.state.map { $0.sectionType }
      .bind(with: self, onNext: { owner, sectionType in
        owner.headerTitle.text = sectionType.headerTitle
      })
      .disposed(by: self.disposeBag)
  }
}

extension MyPageSectionHeaderView: BaseView {
  func setupStyles() {
    //
  }
  
  func setupLayouts() {
    [
      self.headerTitle
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.headerTitle.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
}
