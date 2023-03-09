//
//  NewGiftVC.swift
//  Favor
//
//  Created by 김응철 on 2023/02/05.
//

import UIKit

import FavorUIKit
import RSKPlaceholderTextView
import RxDataSources
import RxSwift
import SnapKit

final class NewGiftViewController: BaseViewController {
  
  typealias DataSource = RxCollectionViewSectionedReloadDataSource<PickedPictureSection>
  
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
  
  private lazy var pickedPictureCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 110, height: 110)
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .favorColor(.background)
    cv.showsHorizontalScrollIndicator = false
    cv.register(
      PickedPictureCell.self,
      forCellWithReuseIdentifier: PickedPictureCell.reuseIdentifier
    )
    cv.register(
      PickPictureCell.self,
      forCellWithReuseIdentifier: PickPictureCell.reuseIdentifier
    )
    
    return cv
  }()
  
  private lazy var emotionStackView: UIStackView = {
    let sv = UIStackView()
    [
      self.emotionButton1,
      self.emotionButton2,
      self.emotionButton3,
      self.emotionButton4,
      self.emotionButton5
    ].forEach {
      sv.addArrangedSubview($0)
    }
    
    sv.axis = .horizontal
    sv.distribution = .equalSpacing
    
    return sv
  }()
  
  private let memoTextView: RSKPlaceholderTextView = {
    let tv = RSKPlaceholderTextView()
    let attributedPlaceholder = NSAttributedString(
      string: "자유롭게 작성해주세요!",
      attributes: [
        .foregroundColor: UIColor.favorColor(.explain),
        .font: UIFont.favorFont(.regular, size: 16)
      ]
    )
    tv.attributedPlaceholder = attributedPlaceholder
    tv.textColor = .favorColor(.explain)
    tv.font = .favorFont(.regular, size: 16)
    tv.backgroundColor = .favorColor(.background)
    tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    return tv
  }()
  
  private let pinTimelineButton: UIButton = {
    var config = UIButton.Configuration.plain()
    var titleContainer = AttributeContainer()
    titleContainer.font = .favorFont(.bold, size: 18)
    titleContainer.foregroundColor = .favorColor(.titleAndLine)
    
    config.attributedTitle = AttributedString(
      "타임라인 고정",
      attributes: titleContainer
    )
    
    // TODO: 핀셋 이미지 추가
    
    let button = UIButton(configuration: config)
    return button
  }()
  
  var dataSource = DataSource { dataSource, collectionView, indexPath, item in
    switch item {
    case .pick(let reactor):
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: PickPictureCell.reuseIdentifier,
        for: indexPath
      ) as? PickPictureCell else {
        return UICollectionViewCell()
      }
      return cell
      
    case .picked(let reactor):
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: PickedPictureCell.reuseIdentifier,
        for: indexPath
      ) as? PickedPictureCell else {
        return UICollectionViewCell()
      }
      return cell
    }
  }
  
  private lazy var giftReceivedButton = self.makeGiftButton("받은 선물")
  private lazy var giftGivenButton = self.makeGiftButton("준 선물")
  private lazy var titleLabel = self.makeTitleLabel("제목")
  private lazy var titleLine = self.makeLine()
  private lazy var categoryLabel = self.makeTitleLabel("카테고리")
  private let categoryView = FavorCategoryView()
  private lazy var pictureLabel = self.makeTitleLabel("사진")
  private lazy var friendLabel = self.makeTitleLabel("준 사람")
  private let giverButton = FavorPlainButton(with: .main("친구 선택", isRight: true))
  private let receiverButton = FavorPlainButton(with: .main("친구선택", isRight: true))
  private lazy var friendLine = self.makeLine()
  private lazy var dateLabel = self.makeTitleLabel("날짜")
  private let dateButton = FavorPlainButton(with: .main("날짜 선택", isRight: false))
  private lazy var dateLine = self.makeLine()
  private lazy var emotionLabel = self.makeTitleLabel("감정 메모")
  private lazy var emotionButton1 = self.makeEmotionButton("🥹")
  private lazy var emotionButton2 = self.makeEmotionButton("🥹")
  private lazy var emotionButton3 = self.makeEmotionButton("🥹")
  private lazy var emotionButton4 = self.makeEmotionButton("🥹")
  private lazy var emotionButton5 = self.makeEmotionButton("🥹")
  private lazy var memoLine = self.makeLine()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Observable.just(getMockSection())
      .bind(to: self.pickedPictureCollectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
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
      self.pictureLabel, self.pickedPictureCollectionView,
      self.friendLabel, self.giverButton, self.receiverButton, self.friendLine,
      self.dateLabel, self.dateButton, self.dateLine,
      self.emotionLabel, self.emotionStackView,
      self.memoTextView, self.memoLine,
      self.pinTimelineButton
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
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
    }
    
    self.titleLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleTextField.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.titleLine.snp.bottom).offset(40)
    }
    
    self.categoryView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.width.equalTo(self.view.frame.width)
      make.top.equalTo(self.categoryLabel.snp.bottom).offset(16)
    }
    
    self.pictureLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.categoryView.snp.bottom).offset(24)
    }
    
    self.pickedPictureCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.pictureLabel.snp.bottom).offset(16)
      make.height.equalTo(110)
    }
    
    self.friendLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.pickedPictureCollectionView.snp.bottom).offset(40)
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
    
    self.emotionStackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.emotionLabel.snp.bottom).offset(16)
    }
    
    self.memoTextView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.emotionStackView.snp.bottom).offset(16)
      make.height.equalTo(130)
    }
    
    self.memoLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.memoTextView.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.pinTimelineButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.memoLine.snp.bottom).offset(40)
      make.bottom.equalToSuperview().inset(85)
    }
  }
  
  // MARK: - Bind
  func getMockSection() -> [PickedPictureSection] {
    let pickItem = PickedPictureSectionItem.pick(.init(5))
    let pickedPicture1 = PickedPictureSectionItem.picked(.init(UIImage()))
    let pickedPicture2 = PickedPictureSectionItem.picked(.init(UIImage()))
    let pickedPicture3 = PickedPictureSectionItem.picked(.init(UIImage()))
    let pickedPicture4 = PickedPictureSectionItem.picked(.init(UIImage()))
    
    let itemInFirstSection = [pickItem, pickedPicture1, pickedPicture2, pickedPicture3, pickedPicture4]
    let firstSection = PickedPictureSection(
      original: PickedPictureSection(
        original: .first(itemInFirstSection),
        items: itemInFirstSection
      ),
      items: itemInFirstSection
    )
    
    return [firstSection]
  }
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
  
  func makeEmotionButton(_ image: String) -> UIButton {
    let button = UIButton()
    button.setImage(UIImage(named: image), for: .normal)
    
    return button
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
