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
  
  private lazy var lightGiftButton = self.button("가벼운선물", selectedImage: .favorIcon(.gift))
  private lazy var birthDayButton = self.button("생일", selectedImage: .favorIcon(.congrat))
  private lazy var houseWarmButton = self.button("집들이", selectedImage: .favorIcon(.housewarm))
  private lazy var testButton = self.button("시험", selectedImage: .favorIcon(.pass))
  private lazy var promotionButton = self.button("승진", selectedImage: .favorIcon(.employed))
  private lazy var graduationButton = self.button("졸업", selectedImage: .favorIcon(.graduate))
  private lazy var etcButton = self.button("기타", selectedImage: .favorIcon(.etc))
  
  private lazy var buttons: [FavorButton] = {
    var buttons: [FavorButton] = []
    [
      self.lightGiftButton,
      self.birthDayButton,
      self.houseWarmButton,
      self.testButton,
      self.promotionButton,
      self.graduationButton,
      self.etcButton
    ].forEach {
      buttons.append($0)
    }
    return buttons
  }()
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.white)
    return view
  }()
  
  // MARK: - PROPERTIES
  
  /// 현재 선택된 버튼이 어떤 카테고리인지 알 수 있는 Property입니다.
  public let currentCategory = BehaviorRelay<FavorCategory>(value: .lightGift)
  
  private let disposeBag = DisposeBag()
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
    
    // buttons AddTarget
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
  
  /// 외부에서 카테고리를 주입해줄 수 있는 메서드입니다.
  public func setSelectedCategory(_ category: FavorCategory) {
    let button = self.buttons.filter { $0.category == category }.first!
    self.didTapButton(button)
  }
  
  // MARK: - SELECTORS
  
  @objc
  private func didTapButton(_ sender: FavorButton) {
    for button in self.buttons {
      if button == sender {
        button.isSelected = true
        self.currentCategory.accept(button.category)
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
    self.didTapButton(self.lightGiftButton)
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
      make.leading.trailing.equalToSuperview()
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.lightGiftButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.birthDayButton.snp.makeConstraints { make in
      make.leading.equalTo(self.lightGiftButton.snp.trailing).offset(10)
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.houseWarmButton.snp.makeConstraints { make in
      make.leading.equalTo(self.birthDayButton.snp.trailing).offset(10)
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.testButton.snp.makeConstraints { make in
      make.leading.equalTo(self.houseWarmButton.snp.trailing).offset(10)
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.promotionButton.snp.makeConstraints { make in
      make.leading.equalTo(self.testButton.snp.trailing).offset(10)
      make.directionalVerticalEdges.equalToSuperview()
    }

    self.graduationButton.snp.makeConstraints { make in
      make.leading.equalTo(self.promotionButton.snp.trailing).offset(10)
      make.directionalVerticalEdges.equalToSuperview()
    }

    self.etcButton.snp.makeConstraints { make in
      make.leading.equalTo(self.graduationButton.snp.trailing).offset(10)
      make.directionalVerticalEdges.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
}

private extension FavorCategoryView {
  func button(_ title: String, selectedImage: UIImage?) -> FavorButton {
    let btn = FavorButton(title)
    btn.cornerRadius = 16.0
    btn.font = .favorFont(.bold, size: 12.0)
    btn.imagePlacement = .leading
    btn.imagePadding = 6
    btn.contentInset = NSDirectionalEdgeInsets(
      top: 8,
      leading: 16,
      bottom: 8,
      trailing: 16
    )
    
    btn.configurationUpdateHandler = { button in
      guard let button = button as? FavorButton else { return }
      switch button.state {
      case .normal:
        button.image = nil
        button.baseBackgroundColor = .white
        button.baseForegroundColor = .favorColor(.subtext)
        button.borderColor = .favorColor(.line3)
        button.borderWidth = 1.0
      case .selected:
        button.baseBackgroundColor = .favorColor(.main)
        button.baseForegroundColor = .white
        button.borderWidth = 0.0

        let image = selectedImage?
          .withTintColor(.favorColor(.white))
          .resize(newWidth: 16.0)
        button.image = image
      default:
        break
      }
    }
    return btn
  }
}
