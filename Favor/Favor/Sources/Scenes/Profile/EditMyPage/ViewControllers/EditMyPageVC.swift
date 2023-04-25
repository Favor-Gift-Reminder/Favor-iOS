//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import SnapKit

final class EditMyPageViewController: BaseViewController, View {
  typealias PreferenceDataSource = RxCollectionViewSectionedReloadDataSource<EditMyPagePreferenceSection>

  // MARK: - Constants

  private enum Metric {
    static let profileImageViewSize = 120.0
  }

  // MARK: - Properties

  private let preferenceDataSource = PreferenceDataSource(
    configureCell: { _, collectionView, indexPath, reactor in
      let cell = collectionView.dequeueReusableCell(for: indexPath) as EditMyPagePreferenceCell
      cell.reactor = reactor
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        for: indexPath
      ) as EditMyPageSectionHeader
      let headerTitle = dataSource[indexPath.section].header
      header.bind(with: headerTitle)
      return header
    }
  )
  private lazy var adapter = Adapter(dataSource: self.preferenceDataSource)

  // MARK: - UI Components

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.contentInsetAdjustmentBehavior = .never
    return scrollView
  }()

  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    stackView.alignment = .center
    return stackView
  }()

  // Profile Background
  private let profileBackgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "MyPageHeaderPlaceholder")
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  private let profileBackgroundDimmingView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.black)
    view.layer.opacity = 0.3
    return view
  }()
  private let profileBackgroundImageButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.background.cornerRadius = 0
    config.image = .favorIcon(.gallery)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 36)
      .withTintColor(.favorColor(.white))
    config.imagePlacement = .all

    let button = UIButton(configuration: config)
    return button
  }()

  // Profile Image
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .favorColor(.line3)
    imageView.image = .favorIcon(.friend)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: Metric.profileImageViewSize / 2)
      .withTintColor(.favorColor(.white))
    imageView.contentMode = .center
    imageView.layer.cornerRadius = Metric.profileImageViewSize / 2
    imageView.clipsToBounds = true
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  private let profileImageDimmingView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.black)
    view.layer.opacity = 0.3
    return view
  }()
  private let profileImageButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.cornerRadius = Metric.profileImageViewSize / 2
    config.background.backgroundColor = .clear
    config.image = .favorIcon(.gallery)?
      .withRenderingMode(.alwaysTemplate)
      .resize(newWidth: 36)
      .withTintColor(.favorColor(.white))

    let button = UIButton(configuration: config)
    return button
  }()

  // Name
  private let nameTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.titleLabelText = "이름"
    textField.placeholder = "이름"
    return textField
  }()

  // ID
  private let idTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.textField.keyboardType = .asciiCapable
    textField.titleLabelText = "ID"
    textField.placeholder = "@favor"
    return textField
  }()

  // Preference
  private lazy var preferenceCollectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.adapter.build(
        scrollDirection: .horizontal,
        header: FavorCompositionalLayout.BoundaryItem.header(height: .absolute(33))
      )
    )

    // Register
    collectionView.register(cellType: EditMyPagePreferenceCell.self)
    collectionView.register(
      supplementaryViewType: EditMyPageSectionHeader.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )

    collectionView.showsVerticalScrollIndicator = false
//    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()
  private var collectionViewHeight: Constraint?

  // MARK: - Life Cycle

  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    // Action

    // State
    reactor.state.map { $0.preferenceSection }
      .bind(to: self.preferenceCollectionView.rx.items(dataSource: self.preferenceDataSource))
      .disposed(by: self.disposeBag)
  }

  public func bind(reactor: EditMyPageViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.nameTextField.rx.text
      .orEmpty
      .subscribe(with: self, onNext: { _, text in
        print(text)
      })
      .disposed(by: self.disposeBag)

    self.profileBackgroundImageButton.rx.tap
      .subscribe(onNext: {
        print("Background")
      })
      .disposed(by: self.disposeBag)

    self.profileImageButton.rx.tap
      .subscribe(onNext: {
        print("Image")
      })
      .disposed(by: self.disposeBag)

    // State

  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.stackView)

    [
      self.profileBackgroundDimmingView,
      self.profileBackgroundImageButton
    ].forEach {
      self.profileBackgroundImageView.addSubview($0)
    }

    [
      self.profileImageDimmingView,
      self.profileImageButton
    ].forEach {
      self.profileImageView.addSubview($0)
    }

    [
      self.profileBackgroundImageView,
      self.profileImageView,
      self.nameTextField,
      self.idTextField,
      self.preferenceCollectionView
    ].forEach {
      self.stackView.addArrangedSubview($0)
    }
    self.stackView.setCustomSpacing(-60, after: self.profileBackgroundImageView)
  }

  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }

    self.profileBackgroundImageView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(300)
    }
    [self.profileBackgroundDimmingView, self.profileBackgroundImageButton].forEach {
      $0.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    }

    self.profileImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.profileImageViewSize)
      make.centerX.equalToSuperview()
    }
    [self.profileImageDimmingView, self.profileImageButton].forEach {
      $0.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    }

    [self.nameTextField, self.idTextField].forEach {
      $0.snp.makeConstraints { make in
        make.directionalHorizontalEdges.equalToSuperview().inset(20)
      }
    }

    self.preferenceCollectionView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview()
      self.collectionViewHeight = make.height.equalTo(0).priority(.low).constraint
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewController {
  
}
