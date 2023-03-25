//
//  NewGiftVC.swift
//  Favor
//
//  Created by 김응철 on 2023/02/05.
//

import UIKit

import FavorKit
import ReactorKit
import RSKPlaceholderTextView
import RxDataSources
import RxSwift
import SnapKit

final class NewGiftViewController: BaseViewController, View {
  
  typealias DataSource = RxCollectionViewSectionedReloadDataSource<PickedPictureSection>
  
  // MARK: - UI COMPONENTS
  
  private let scrollView: UIScrollView = {
    let sv = UIScrollView()
    
    return sv
  }()
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.white)
    
    return view
  }()
  
  private let titleTextField: UITextField = {
    let tf = UITextField()
    let attributedPlaceholder = NSAttributedString(
      string: "선물 이름 (최대 20자)",
      attributes: [
        .foregroundColor: UIColor.favorColor(.explain),
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
    
    let button = UIButton(configuration: config)
    return button
  }()
  
  private lazy var datePicker: UIDatePicker = {
    let dp = UIDatePicker()
    dp.datePickerMode = .date
    dp.addTarget(self, action: #selector(didChangedDate), for: .valueChanged)
    
    return dp
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
  
  // Divider
  private let titleDivider = FavorDivider()
  private let friendDivider = FavorDivider()
  private let dateDivider = FavorDivider()
  private let memoDivider = FavorDivider()
  
  // Label
  private lazy var titleLabel = self.label("제목")
  private lazy var categoryLabel = self.label("카테고리")
  private lazy var photoLabel = self.label("사진")
  private lazy var dateLabel = self.label("날짜")
  private lazy var friendLabel = self.label("준 사람")
  private lazy var emotionLabel = self.label("감정 메모")
  
  // Button
  private lazy var giftReceivedButton = self.giftButton("받은 선물")
  private lazy var giftGivenButton = self.giftButton("준 선물")
  private lazy var choiceFriendButton = self.choiceButton("친구 선택", isRight: true)
  private lazy var choiceDateButton = self.choiceButton("날짜 선택", isRight: false)
  private lazy var emotionButton1 = self.makeEmotionButton("🥹")
  private lazy var emotionButton2 = self.makeEmotionButton("🥹")
  private lazy var emotionButton3 = self.makeEmotionButton("🥹")
  private lazy var emotionButton4 = self.makeEmotionButton("🥹")
  private lazy var emotionButton5 = self.makeEmotionButton("🥹")
  
  private let categoryView = FavorCategoryView()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Observable.just(getMockSection())
      .bind(to: self.pickedPictureCollectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .favorColor(.white)
    self.categoryView.currentCategory = .lightGift
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
      self.titleLabel, self.titleDivider, self.titleTextField, self.titleDivider,
      self.categoryLabel, self.categoryView,
      self.photoLabel, self.pickedPictureCollectionView,
      self.friendLabel, self.choiceFriendButton, self.friendDivider,
      self.dateLabel, self.choiceDateButton, self.dateDivider,
      self.emotionLabel, self.emotionStackView,
      self.memoTextView, self.memoDivider,
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
    
    self.titleDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    self.titleTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
    }
    
    self.titleDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleTextField.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.titleDivider.snp.bottom).offset(40)
    }
    
    self.categoryView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.width.equalTo(self.view.frame.width)
      make.top.equalTo(self.categoryLabel.snp.bottom).offset(16)
    }
    
    self.photoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.categoryView.snp.bottom).offset(24)
    }
    
    self.pickedPictureCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.photoLabel.snp.bottom).offset(16)
      make.height.equalTo(110)
    }
    
    self.friendLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.pickedPictureCollectionView.snp.bottom).offset(40)
    }
    
    self.choiceFriendButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendLabel.snp.bottom).offset(16)
    }
        
    self.friendDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.choiceFriendButton.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.dateLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendDivider.snp.bottom).offset(40)
    }
    
    self.choiceDateButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.dateLabel.snp.bottom).offset(16)
    }
    
    self.dateDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.choiceDateButton.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.emotionLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.dateDivider.snp.bottom).offset(40)
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
    
    self.memoDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.memoTextView.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.pinTimelineButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.memoDivider.snp.bottom).offset(40)
      make.bottom.equalToSuperview().inset(85)
    }
  }
  
  // MARK: - BIND
  
  func bind(reactor: NewGiftViewReactor) {
    
    // MARK: - ACTION
    
    // 받은 선물 버튼 클릭
    self.giftReceivedButton.rx.tap
      .map { NewGiftViewReactor.Action.giftReceivedButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 준 선물 버튼 클릭
    self.giftGivenButton.rx.tap
      .map { NewGiftViewReactor.Action.giftGivenButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 제목 텍스트 필드
    self.titleTextField.rx.text
      .orEmpty
      .map { NewGiftViewReactor.Action.titleTextFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 날짜 선택 버튼 클릭
    self.choiceDateButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        
      }
      .disposed(by: self.disposeBag)
    
    // MARK: - STATE
    
    // 선물 종류 토글
    reactor.state.map { $0.isReceivedGift }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
      .drive(with: self) {
        if $1 {
          $0.giftReceivedButton.isSelected = true
          $0.giftGivenButton.isSelected = false
        } else {
          $0.giftReceivedButton.isSelected = false
          $0.giftGivenButton.isSelected = true
        }
      }
      .disposed(by: self.disposeBag)
    
    // FriendLabel Text 변경
    reactor.state.map { $0.isReceivedGift }
      .distinctUntilChanged()
      .map { $0 ? "준 사람" : "받은 사람" }
      .bind(to: self.friendLabel.rx.text)
      .disposed(by: self.disposeBag)
    
    //
  }
  
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
  
  // MARK: - SELECTORS
  
  @objc
  private func didChangedDate() {
    
  }
}

// MARK: - HELPERS

private extension NewGiftViewController {
  func giftButton(_ title: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.baseBackgroundColor = .favorColor(.white)
    config.attributedTitle = AttributedString(
      title,
      attributes: .init([
        .font: UIFont.favorFont(.bold, size: 22)
      ])
    )
    
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.titleAndLine)
      default:
        break
      }
    }
    
    return button
  }
  
  func label(_ title: String) -> UILabel {
    let lb = UILabel()
    lb.textColor = .favorColor(.titleAndLine)
    lb.text = title
    lb.font = .favorFont(.bold, size: 18)
    
    return lb
  }
  
  func choiceButton(_ title: String, isRight: Bool) -> FavorPlainButton {
    let button = FavorPlainButton(with: .main(title, isRight: isRight))
    button.configurationUpdateHandler = {
      switch $0.state {
      case .normal:
        $0.configuration?.baseForegroundColor = .favorColor(.explain)
        $0.configuration?.baseBackgroundColor = .favorColor(.white)
      case .selected:
        $0.configuration?.baseForegroundColor = .favorColor(.icon)
        $0.configuration?.baseBackgroundColor = .favorColor(.white)
      default:
        break
      }
    }
    return button
  }
  
  func makeEmotionButton(_ image: String) -> UIButton {
    let button = UIButton()
    button.setImage(UIImage(named: image), for: .normal)
    
    return button
  }
}
