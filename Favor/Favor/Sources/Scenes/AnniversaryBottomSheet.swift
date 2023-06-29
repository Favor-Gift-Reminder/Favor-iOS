//
//  AnniversaryBottomSheet.swift
//  Favor
//
//  Created by 김응철 on 2023/05/23.
//

import UIKit

import FavorKit
import RxCocoa
import RxFlow
import SnapKit
import Then

final class AnniversaryBottomSheet: BaseBottomSheet, Stepper {
  
  // MARK: - UI Components
  
  private let iconViews: [AnniversaryBottomSheetView] = {
    var views = [AnniversaryBottomSheetView]()
    AnniversaryCategory.allCases.forEach { views.append(AnniversaryBottomSheetView($0)) }
    return views
  }()
  
  private lazy var iconViewStackView: UIStackView = UIStackView().then {
    $0.spacing = 56.0
    $0.axis = .horizontal
  }
  
  private let scrollView: UIScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
  }
  
  private let contentsView = UIView()
  
  // MARK: - Properties
  
  /// 현재 선택되어 있는 AnniversaryType입니다.
  private var currentAnniversary: AnniversaryCategory {
    didSet { self.updateView() }
  }
  
  /// 완료 버튼 Handler
  var finishButtonHandler: ((AnniversaryCategory) -> Void)?
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Initializer
  
  /// 생성자로 AnniversaryType을 파라미터로 전해줍니다.
  /// 하지만, 새 기념일을 생성할 경우에는 기본값인 nil을 전해주면 됩니다.
  init(_ anniversaryType: AnniversaryCategory? = nil) {
    self.currentAnniversary = anniversaryType == nil ? .couple : anniversaryType!
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.setScrollOffset()
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    
    super.setupStyles()
    
    self.cancelButton.isHidden = true
    self.updateTitle("기념일 종류")
    self.updateView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.iconViews.forEach { self.iconViewStackView.addArrangedSubview($0) }
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentsView)
    self.contentsView.addSubview(iconViewStackView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.scrollView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(62.0)
      make.height.equalTo(84.0)
    }
    
    self.contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.iconViewStackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(self.view.center.x - 24)
      make.top.bottom.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 완료 버튼 클릭 이벤트
    self.finishButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.finishButtonHandler?(owner.currentAnniversary)
        owner.dismissBottomSheet()
      }
      .disposed(by: self.disposeBag)
    
    // 스크롤 이벤트
    self.scrollView.rx.contentOffset
      .asDriver()
      .drive(with: self) { owner, offset in
        owner.setAutoSelection(offset)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  private func updateView() {
    let anniversaryType = self.currentAnniversary
    self.iconViews.forEach { $0.isSelected = false }
    self.iconViews.filter {
      $0.anniversaryCategory == anniversaryType
    }.first?.isSelected = true
  }
  
  private func setScrollOffset() {
    for button in self.iconViewStackView.arrangedSubviews {
      let category = (button as? AnniversaryBottomSheetView)?.anniversaryCategory ?? .couple
      
      if category == self.currentAnniversary {
        let buttonFrame = button.convert(button.bounds, to: self.scrollView)
        self.scrollView.setContentOffset(CGPoint(
          x: buttonFrame.origin.x - ((self.view.frame.width / 2) - (buttonFrame.width / 2)), y: 0
        ), animated: false)
      }
    }
  }
  
  private func setAutoSelection(_ offset: CGPoint) {
    let centerX = offset.x + self.view.center.x
    
    for button in self.iconViewStackView.arrangedSubviews {
      let buttonFrame = button.convert(button.bounds, to: self.scrollView)
      if buttonFrame.contains(CGPoint(x: centerX, y: self.scrollView.bounds.midY)) {
        self.currentAnniversary = (button as? AnniversaryBottomSheetView)?.anniversaryCategory ?? .couple
        self.updateView()
      }
    }
  }
}
