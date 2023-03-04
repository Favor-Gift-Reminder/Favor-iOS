//
//  CategoryView.swift
//  Favor
//
//  Created by 김응철 on 2023/02/06.
//

import UIKit

import SnapKit

final class FavorCategoryView: UIScrollView {
  
  // MARK: - Properties
  
  private let lightGiftButton = FavorSmallButton(with: .mainWithIcon("가벼운 선물", imageName: ""))
  private let birthButton = FavorSmallButton(with: .mainWithIcon("생일", imageName: ""))
  private let houseWarmingButton = FavorSmallButton(with: .mainWithIcon("집들이", imageName: ""))
  private let testButton = FavorSmallButton(with: .mainWithIcon("시험", imageName: ""))
  private let promotionButton = FavorSmallButton(with: .mainWithIcon("승진", imageName: ""))
  private let graduationButton = FavorSmallButton(with: .mainWithIcon("졸업", imageName: ""))
  private let etcButton = FavorSmallButton(with: .mainWithIcon("기타", imageName: ""))
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.background)
    
    return view
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FavorCategoryView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.background)
    self.showsHorizontalScrollIndicator = false
  }
  
  func setupLayouts() {
    self.addSubview(self.contentsView)
    
    [
      self.lightGiftButton,
      self.birthButton,
      self.houseWarmingButton,
      self.testButton,
      self.promotionButton,
      self.graduationButton,
      self.etcButton
    ].forEach {
      self.contentsView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(32)
    }
    
    self.contentsView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.top.equalToSuperview()
    }
    
    self.lightGiftButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.bottom.equalToSuperview()
    }
    
    self.birthButton.snp.makeConstraints { make in
      make.leading.equalTo(self.lightGiftButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.houseWarmingButton.snp.makeConstraints { make in
      make.leading.equalTo(self.birthButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.testButton.snp.makeConstraints { make in
      make.leading.equalTo(self.houseWarmingButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.promotionButton.snp.makeConstraints { make in
      make.leading.equalTo(self.testButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }

    self.graduationButton.snp.makeConstraints { make in
      make.leading.equalTo(self.promotionButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }

    self.etcButton.snp.makeConstraints { make in
      make.leading.equalTo(self.graduationButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
}
