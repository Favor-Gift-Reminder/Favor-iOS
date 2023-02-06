//
//  NewGiftVC.swift
//  Favor
//
//  Created by 김응철 on 2023/02/05.
//

import UIKit

import SnapKit

final class NewGiftViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let scrollView: UIScrollView = {
    let sv = UIScrollView()
    
    return sv
  }()
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  
  private lazy var giftReceivedButton = self.makeGiftButton("받은 선물")
  private lazy var giftGivenButton = self.makeGiftButton("준 선물")
  private lazy var titleLabel = self.makeTitleLabel("제목")
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.giftReceivedButton.isSelected = true
  }
  
  override func setupLayouts() {
    self.scrollView.addSubview(contentsView)
    
    [
      self.scrollView,
    ].forEach {
      self.view.addSubview($0)
    }
    
    [
      self.giftReceivedButton,
      self.giftGivenButton,
      self.titleLabel
    ].forEach {
      self.contentsView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.giftReceivedButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32)
      make.leading.equalToSuperview().inset(20)
    }
    
    self.giftGivenButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32)
      make.leading.equalTo(self.giftReceivedButton.snp.trailing).offset(33)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.giftReceivedButton.snp.bottom).offset(40)
    }
  }
  
  // MARK: - Bind
}

// MARK: - Helpers

private extension NewGiftViewController {
  func makeGiftButton(_ title: String) -> UIButton {
    let btn = UIButton()
    let attributedTitle = NSAttributedString(
      string: title,
      attributes: [
        .font: UIFont.favorFont(.bold, size: 22)
      ]
    )
    btn.setAttributedTitle(attributedTitle, for: .normal)
    btn.setTitleColor(.favorColor(.titleAndLine), for: .selected)
    btn.setTitleColor(.favorColor(.line2), for: .normal)
    
    return btn
  }
  
  func makeTitleLabel(_ title: String) -> UILabel {
    let lb = UILabel()
    lb.textColor = .black
    lb.text = title
    lb.font = .favorFont(.bold, size: 18)
    
    return lb
  }
  
  func makeLine() -> UIView {
    let view = UIView()
    
    return view
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct NewGiftVC_PreView: PreviewProvider {
  static var previews: some View {
    NewGiftViewController().toPreview()
  }
}
#endif

