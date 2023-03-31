//
//  NewGiftVC.swift
//  Favor
//
//  Created by 김응철 on 2023/02/05.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RSKPlaceholderTextView
import RxDataSources
import RxGesture
import RxSwift
import SnapKit

final class NewGiftViewController: BaseViewController, View {
  
  typealias DataSource = RxCollectionViewSectionedReloadDataSource<NewGiftPhotoSection.NewGiftPhotoSectionModel>
  
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
    tf.rightView = UIImageView(image: .favorIcon(.birth))
    
    return tf
  }()
  
  private lazy var photoCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 6)
    layout.itemSize = CGSize(width: 100, height: 100)
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .favorColor(.white)
    cv.showsHorizontalScrollIndicator = false
    cv.register(cellType: NewGiftEmptyCell.self)
    cv.register(cellType: NewGiftPhotoCell.self)
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
    tv.backgroundColor = .favorColor(.white)
    tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    return tv
  }()
    
  private let pinTimelineButton: UIButton = {
    var config = UIButton.Configuration.plain()
    var titleContainer = AttributeContainer()
    titleContainer.font = .favorFont(.bold, size: 18)
    titleContainer.foregroundColor = .favorColor(.icon)
    config.attributedTitle = AttributedString(
      "타임라인 고정",
      attributes: titleContainer
    )
    config.background.backgroundColor = .white
    let pinImage = UIImage.favorIcon(.pin)?
      .resize(newWidth: 18)
    config.imagePadding = 10
    config.imagePlacement = .trailing
    config.image = pinImage
    config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    let button = UIButton(configuration: config)
    
    button.configurationUpdateHandler = {
      var config = $0.configuration
      switch $0.state {
      case .normal:
        $0.configuration?.image = pinImage?.withTintColor(.favorColor(.line3))
      case .selected:
        $0.configuration?.image = pinImage?.withTintColor(.favorColor(.icon))
      default:
        break
      }
    }
    return button
  }()
  
  private let doneButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.attributedTitle = AttributedString(
      "완료",
      attributes: .init([
        .font: UIFont.favorFont(.bold, size: 18)
      ])
    )
    let btn = UIButton(configuration: config)
    btn.configurationUpdateHandler = {
      switch $0.state {
      case .disabled:
        config.baseForegroundColor = .favorColor(.line2)
      case .normal:
        config.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    return btn
  }()
  
  private let categoryView: FavorCategoryView = {
    let view = FavorCategoryView()
    view.configureCategory(.lightGift)
    return view
  }()
  
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
  private lazy var emotionLabel = self.label("메모")
  
  // Button
  private lazy var giftReceivedButton = self.giftButton("받은 선물")
  private lazy var giftGivenButton = self.giftButton("준 선물")
  private lazy var datePickerTextField = FavorDatePickerTextField()
  private lazy var emotionButton1 = self.makeEmotionButton("🥹")
  private lazy var emotionButton2 = self.makeEmotionButton("🥹")
  private lazy var emotionButton3 = self.makeEmotionButton("🥹")
  private lazy var emotionButton4 = self.makeEmotionButton("🥹")
  private lazy var emotionButton5 = self.makeEmotionButton("🥹")
  
  private let choiceFrinedView = NewGiftChoiceFriendView()
  
  // MARK: - PROPERTIES
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .favorColor(.white)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
  }
  
  override func setupLayouts() {
    self.scrollView.addSubview(contentsView)
    self.view.addSubview(self.scrollView)
    
    [
      self.giftReceivedButton,
      self.giftGivenButton,
      self.titleLabel,
      self.titleDivider,
      self.titleTextField,
      self.titleDivider,
      self.categoryLabel,
      self.categoryView,
      self.photoLabel,
      self.photoCollectionView,
      self.friendLabel,
      self.choiceFrinedView,
      self.friendDivider,
      self.dateLabel,
      self.datePickerTextField,
      self.dateDivider,
      self.emotionLabel,
      self.emotionStackView,
      self.memoTextView,
      self.memoDivider,
      self.pinTimelineButton,
      self.datePickerTextField,
    ].forEach {
      self.contentsView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.scrollView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
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
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.photoLabel.snp.bottom).offset(16)
      make.height.equalTo(100)
    }
    
    self.friendLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.photoCollectionView.snp.bottom).offset(40)
    }
    
    self.choiceFrinedView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendLabel.snp.bottom).offset(16)
    }
        
    self.friendDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.choiceFrinedView.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    self.dateLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.friendDivider.snp.bottom).offset(40)
    }
    
    self.datePickerTextField.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(self.dateLabel.snp.bottom).offset(16)
    }
    
    self.dateDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(self.datePickerTextField.snp.bottom).offset(16)
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
    
    // 빈 화면 터치
    self.view.rx.tapGesture { gesture, _ in
      gesture.cancelsTouchesInView = false
    }
    .when(.recognized)
    .bind(with: self) { owner, _ in
      owner.view.endEditing(true)
    }
    .disposed(by: self.disposeBag)
    
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
    
    // 셀 선택
    self.photoCollectionView.rx.itemSelected
      .map { $0.item }
      .map { NewGiftViewReactor.Action.cellSelected(index: $0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 카테고리 변경
    self.categoryView.currentCategory
      .map { NewGiftViewReactor.Action.categoryDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 타임라인 고정 토글
    self.pinTimelineButton.rx.tap
      .withUnretained(self)
      .do { $0.0.pinTimelineButton.isSelected.toggle() }
      .map { $0.0.pinTimelineButton.isSelected }
      .map { NewGiftViewReactor.Action.pinToggle($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // MARK: - STATE
    
    let dataSource = DataSource { _, collectionView, indexPath, item in
      switch item {
      case .empty:
        let cell = collectionView.dequeueReusableCell(for: indexPath) as NewGiftEmptyCell
        return cell
      case .photo(let image):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as NewGiftPhotoCell
        cell.imageView.image = image
        
        cell.removeButtonDidTap = { [weak self] in
          self?.reactor?.action.onNext(.photoRemoveButtonDidTap(index: indexPath.item))
        }
        
        return cell
      }
    }
    
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
    
    // DataSource Binding
    reactor.state.map { [$0.newGiftPhotoSection] }
      .bind(to: self.photoCollectionView.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
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
  
  func makeEmotionButton(_ image: String) -> UIButton {
    let button = UIButton()
    button.setImage(UIImage(named: image), for: .normal)
    
    return button
  }
}
