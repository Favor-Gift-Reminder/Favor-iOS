//
//  FavorPopup.swift
//
//
//  Created by 김응철 on 7/3/23.
//

import UIKit

/// 확인 버튼만 존재하는 단방향적인 알람을 줄 때 사용하는 팝업 창 입니다.
final class FavorPopup: BasePopup {
  
  // MARK: - Properties
  
  /// 팝업에서 알릴 내용 값 입니다.
  private let message: String
  
  /// FavorPopup의 높이 값 입니다.
  private let height: CGFloat = 184.0
  
  // MARK: - UI Components
  
  /// 확인 버튼 입니다.
  private let confirmButton = FavorLargeButton(with: .main("확인"))
  
  /// 메세지를 보여주는 레이블 입니다.
  private lazy var descriptionLabel: UILabel = {
    let lb = UILabel()
    lb.font = .favorFont(.bold, size: 16)
    lb.textColor = .favorColor(.icon)
    lb.textAlignment = .center
    lb.numberOfLines = 2
    lb.text = self.message
    return lb
  }()
  
  // MARK: - Initializer
  
  /// 이니셜라이저
  /// - Parameters:
  ///   - message: 팝업에서 전달할 메세지를 전달해줍니다.
  init(_ message: String) {
    self.message = message
    super.init(self.height)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup

  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.descriptionLabel,
      self.confirmButton
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.confirmButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(24.0)
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.confirmButton.snp.top).offset(-36.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 확인 버튼을 누르면 팝업이 종료됩니다.
    self.confirmButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismissPopup()
      }
      .disposed(by: self.disposeBag)
  }
}
