//
//  NewGiftFriendHeaderView.swift
//  Favor
//
//  Created by 김응철 on 2023/04/15.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import SnapKit

final class NewGiftFriendHeaderView: UICollectionReusableView, Reusable, View {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 18)
    lb.textColor = .favorColor(.icon)
    return lb
  }()
  
  private let countLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 18)
    lb.textColor = .favorColor(.icon)
    return lb
  }()
  
  private let searchBar = FavorSearchBar()
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()

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

  // MARK: - Bind
  
  func bind(reactor: NewGiftFriendHeaderViewReactor) {
    reactor.state.map { $0.currentFriendCount }
      .map { "\($0)" }
      .asDriver(onErrorJustReturn: "")
      .drive(with: self) { $0.countLabel.text = $1 }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.sectionType }
      .map { $0 == .selectedFriends }
      .asDriver(onErrorJustReturn: false)
      .drive(with: self) {
        $0.searchBar.isHidden = $1 ? true : false
        $0.titleLabel.text = $1 ? "선택한 친구" : "친구"
      }
      .disposed(by: self.disposeBag)
  }
}

extension NewGiftFriendHeaderView: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.titleLabel,
      self.countLabel,
      self.searchBar
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(32)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
}
