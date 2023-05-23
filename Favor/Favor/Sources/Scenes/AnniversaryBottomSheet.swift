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
    AnniversaryType.allCases.forEach { views.append(AnniversaryBottomSheetView($0)) }
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
  private var currentAnniversary: AnniversaryType {
    didSet { self.updateView() }
  }
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Initializer
  
  /// 생성자로 AnniversaryType을 파라미터로 전해줍니다.
  /// 하지만, 새 기념일을 생성할 경우에는 기본값인 nil을 전해주면 됩니다.
  init(_ anniversaryType: AnniversaryType? = nil) {
    self.currentAnniversary = anniversaryType == nil ? .couple : anniversaryType!
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      make.leading.trailing.equalToSuperview().inset(53.0)
      make.top.bottom.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    for view in iconViews {
      view.tapObservable
        .asDriver(onErrorRecover: { _ in return .empty() })
        .drive(with: self) { owner, anniversaryType in
          owner.currentAnniversary = anniversaryType
          owner.updateView()
        }
        .disposed(by: self.disposeBag)
    }
    
    self.finishButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.steps.accept(AppStep.anniversaryBottomSheetIsComplete(owner.currentAnniversary))
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  private func updateView() {
    let anniversaryType = self.currentAnniversary
    self.iconViews.forEach { $0.isSelected = false }
    self.iconViews.filter { $0.anniversaryType == anniversaryType }.first?.isSelected = true
  }
}
