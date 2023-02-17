//
//  MyPageHeaderView.swift
//  Favor
//
//  Created by 이창준 on 2023/02/16.
//

import UIKit

import ReactorKit

final class MyPageHeaderView: UICollectionReusableView, ReuseIdentifying, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - UI Components
  
  private lazy var backgroundImageView: UIImageView = {
    let imageView = UIImageView()
//    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: "MyPagePlaceholder")
    return imageView
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
  
  func bind(reactor: MyPageHeaderReactor) {
    // Action
    
    // State
    
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
}

extension MyPageHeaderView: BaseView {
  func setupStyles() {
    
  }
  
  func setupLayouts() {
    [
      self.backgroundImageView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.backgroundImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
