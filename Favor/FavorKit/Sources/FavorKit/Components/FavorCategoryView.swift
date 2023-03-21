//
//  FavorCategoryView.swift
//  Favor
//
//  Created by 김응철 on 2023/02/06.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

public final class FavorCategoryView: UIScrollView {
  
  // MARK: - UI COMPONENTS
  
  private lazy var lightGiftButton = self.button("가벼운 선물", selectedImage: nil)
  private lazy var birthDayButton = self.button("생일", selectedImage: .favorIcon(.congrat))
  private lazy var houseWarmButton = self.button("집들이", selectedImage: .favorIcon(.housewarm))
  private lazy var testButton = self.button("시험", selectedImage: nil)
  private lazy var promotionButton = self.button("승진", selectedImage: .favorIcon(.employed))
  private lazy var graduationButton = self.button("졸업", selectedImage: .favorIcon(.graduate))
  private lazy var etcButton = self.button("기타", selectedImage: nil)
  
  private lazy var buttons: [FavorSmallButton] = {
    var buttons = [FavorSmallButton]()
    
    [
      self.lightGiftButton,
      self.birthDayButton,
      self.houseWarmButton,
      self.testButton,
      self.promotionButton,
      self.graduationButton,
      self.etcButton
    ].forEach { buttons.append($0) }
    
    return buttons
  }()
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.white)
    
    return view
  }()
  
  // MARK: - PROPERTIES
  
  private var selectedButton: FavorSmallButton {
    self.buttons.filter { $0.isSelected }.first!
  }
  
  /// 현재 선택된 버튼이 어떤 카테고리인지 알 수 있는 Property입니다.
  var currentCategory: FavorCategory {
    get {
      self.selectedButton.category!      
    }
    set {
      let button = self.buttons.filter { $0.category == newValue }.first!
      self.didTapButton(button)
    }
  }
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
    
    self.buttons.forEach {
      $0.addTarget(
        self,
        action: #selector(self.didTapButton),
        for: .touchUpInside
      )
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - HELPERS
  
  @objc
  private func didTapButton(_ sender: FavorSmallButton) {
    for button in self.buttons {
      if button == sender {
        button.isSelected = true
      } else {
        button.isSelected = false
      }
    }
  }
}

extension FavorCategoryView: BaseView {
  public func setupStyles() {
    self.backgroundColor = .favorColor(.white)
    self.showsHorizontalScrollIndicator = false
  }
  
  public func setupLayouts() {
    self.addSubview(self.contentsView)
    
    [
      self.lightGiftButton,
      self.birthDayButton,
      self.houseWarmButton,
      self.testButton,
      self.promotionButton,
      self.graduationButton,
      self.etcButton
    ].forEach {
      self.contentsView.addSubview($0)
    }
  }
  
  public func setupConstraints() {
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
    
    self.birthDayButton.snp.makeConstraints { make in
      make.leading.equalTo(self.lightGiftButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.houseWarmButton.snp.makeConstraints { make in
      make.leading.equalTo(self.birthDayButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.testButton.snp.makeConstraints { make in
      make.leading.equalTo(self.houseWarmButton.snp.trailing).offset(10)
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

private extension FavorCategoryView {
  func button(_ title: String, selectedImage: UIImage?) -> FavorSmallButton {
    let btn = FavorSmallButton(with: .gray(title))
    
    btn.configurationUpdateHandler = {
      switch $0.state {
      case .normal:
        $0.configuration = FavorSmallButtonType.gray(title).configuration
      case .selected:
        let image = selectedImage?.withTintColor(.favorColor(.white))
        $0.configuration = FavorSmallButtonType.darkWithIcon(
          title,
          image: image
        ).configuration
      default:
        break
      }
    }
    return btn
  }
}
