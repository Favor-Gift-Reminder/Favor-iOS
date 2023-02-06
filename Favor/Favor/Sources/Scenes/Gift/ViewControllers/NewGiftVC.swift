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
    view.backgroundColor = .favorColor(.background)
    
    return view
  }()
  
  private let titleTextField: UITextField = {
    let tf = UITextField()
    let attributedPlaceholder = NSAttributedString(
      string: "선물 이름 (최대 20자)",
      attributes: [
        .foregroundColor: UIColor.favorColor(.subtext),
        .font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    tf.attributedPlaceholder = attributedPlaceholder
    tf.font = .favorFont(.regular, size: 16)
    tf.textColor = .favorColor(.titleAndLine)
    
    return tf
  }()
  
  private lazy var addPictureCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 110, height: 110)
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .favorColor(.error)
    
    return cv
  }()
  
  private let emotionStack: UIStackView = {
    let sv = UIStackView()
    ["🥹", "🥰", "🙂", "😐", "😰"].forEach {
      sv.addArrangedSubview($0)
    }
    
    return sv
  }()
  
  private lazy var giftReceivedButton = self.makeGiftButton("받은 선물")
  private lazy var giftGivenButton = self.makeGiftButton("준 선물")
  private lazy var titleLabel = self.makeTitleLabel("제목")
  private lazy var titleLine = self.makeLine()
  private lazy var categoryLabel = self.makeTitleLabel("카테고리")
  private let categoryView = CategoryView()
  private lazy var pictureLabel = self.makeTitleLabel("사진")
  private lazy var friendLabel = self.makeTitleLabel("준 사람")
  private let giverButton = PlainFavorButton(.main, title: "친구 선택")
  private let receiverButton = PlainFavorButton(.main, title: "친구 선택")
  private lazy var friendLine = self.makeLine()
  private lazy var dateLabel = self.makeTitleLabel("날짜")
  private let dateButton = PlainFavorButton(.main, title: "날짜 선택")
  private lazy var dateLine = self.makeLine()
  private lazy var emotionLabel = self.makeTitleLabel("감정 메모")
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.giftReceivedButton.isSelected = true
    self.view.backgroundColor = .favorColor(.background)
    self.receiverButton.isHidden = true
  }
  
  override func setupLayouts() {
    self.scrollView.addSubview(contentsView)
    
    [
      self.scrollView,
    ].forEach {
      self.view.addSubview($0)
    }
    
    [
      self.giftReceivedButton, self.giftGivenButton,
      self.titleLabel, self.titleLine, self.titleTextField, self.titleLine,
      self.categoryLabel, self.categoryView,
      self.pictureLabel, self.addPictureCollectionView,
      self.friendLabel, self.giverButton, self.receiverButton, self.friendLine,
      self.dateLabel, self.dateButton, self.dateLine,
      self.emotionLabel
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
    
    self.titleLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    self.titleTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    self.titleLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleTextField.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleLine.snp.bottom).offset(40)
    }
    
    self.categoryView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.width.equalTo(self.view.frame.width)
      make.top.equalTo(categoryLabel.snp.bottom).offset(16)
    }
    
    self.pictureLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.categoryView.snp.bottom).offset(24)
    }
    
    self.addPictureCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.pictureLabel.snp.bottom).offset(16)
      make.height.equalTo(110)
    }
    
    self.friendLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.addPictureCollectionView.snp.bottom).offset(40)
    }
    
    self.giverButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendLabel.snp.bottom).offset(16)
    }
    
    self.receiverButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendLabel.snp.bottom).offset(16)
    }
    
    self.friendLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.giverButton.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.dateLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendLine.snp.bottom).offset(40)
    }
    
    self.dateButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.dateLabel.snp.bottom).offset(16)
    }
    
    self.dateLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.dateButton.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.emotionLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.dateLine.snp.bottom).offset(40)
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
    lb.textColor = .favorColor(.titleAndLine)
    lb.text = title
    lb.font = .favorFont(.bold, size: 18)
    
    return lb
  }
  
  func makeLine() -> UIView {
    let view = UIView()
    view.backgroundColor = .favorColor(.divider)
    
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
