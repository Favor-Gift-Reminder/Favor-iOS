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
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.white)
    
    return view
  }()
  
  // MARK: - PROPERTIES
  
  private let disposeBag = DisposeBag()
  
  /// 현재 선택된 버튼 이벤트를 방출하는 Subject입니다.
  private(set) var currentSelectedButton = BehaviorSubject<Category>(value: .lightGift)
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - BIND
  
  private func bind() {

    // 가벼운 선물 버튼 클릭
    self.lightGiftButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.lightGift)
      }
      .disposed(by: self.disposeBag)
    
    // 생일 버튼 클릭
    self.birthDayButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.birthDay)
      }
      .disposed(by: self.disposeBag)
    
    // 집들이 버튼 클릭
    self.houseWarmButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.houseWarm)
      }
      .disposed(by: self.disposeBag)

    // 시험 버튼 클릭
    self.testButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.test)
      }
      .disposed(by: self.disposeBag)

    // 승진 버튼 클릭
    self.promotionButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.promotion)
      }
      .disposed(by: self.disposeBag)

    // 졸업 버튼 클릭
    self.graduationButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.graduation)
      }
      .disposed(by: self.disposeBag)
    
    // 기타 버튼 클릭
    self.etcButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.changeButtonState(.etc)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - HELPERS
  
  private func changeButtonState(_ category: Category) {
    [
      self.lightGiftButton,
      self.birthDayButton,
      self.houseWarmButton,
      self.testButton,
      self.promotionButton,
      self.graduationButton,
      self.etcButton
    ].forEach {
      $0.isSelected = false
    }
    
    switch category {
    case .lightGift:
      self.lightGiftButton.isSelected = true
    case .birthDay:
      self.birthDayButton.isSelected = true
    case .houseWarm:
      self.houseWarmButton.isSelected = true
    case .test:
      self.testButton.isSelected = true
    case .promotion:
      self.promotionButton.isSelected = true
    case .graduation:
      self.graduationButton.isSelected = true
    case .etc:
      self.etcButton.isSelected = true
    }
    
    self.currentSelectedButton.onNext(category)
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
