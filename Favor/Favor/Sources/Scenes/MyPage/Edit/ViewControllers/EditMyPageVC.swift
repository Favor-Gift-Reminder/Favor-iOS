//
//  EditMyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import ReactorKit
import RxDataSources
import SnapKit

final class EditMyPageViewController: BaseViewController, View {
  typealias SelectFavorDataSource = RxCollectionViewSectionedReloadDataSource<SelectFavorSection>

  // MARK: - Constants

  // MARK: - Properties

  let dataSource = SelectFavorDataSource(
    configureCell: { _, collectionView, indexPath, reactor in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: FavorCell.reuseIdentifier,
        for: indexPath
      ) as? FavorCell else { return UICollectionViewCell() }
      cell.reactor = reactor
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: MyPageSectionHeaderView.reuseIdentifier,
          for: indexPath
        ) as? MyPageSectionHeaderView else { return UICollectionReusableView() }
        header.reactor = MyPageSectionHeaderReactor(title: dataSource.sectionModels[indexPath.item].header)
        return header
      case UICollectionView.elementKindSectionFooter:
        guard let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: MyPageSectionFooterView.reuseIdentifier,
          for: indexPath
        ) as? MyPageSectionFooterView else { return UICollectionReusableView() }
        footer.setupDescription("최대 5개까지 선택할 수 있습니다.")
        return footer
      default:
        return UICollectionReusableView()
      }
    }
  )

  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.alwaysBounceVertical = true
    scrollView.contentInsetAdjustmentBehavior = .never
    return scrollView
  }()

  private lazy var backgroundImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .systemBlue
    config.background.cornerRadius = 0

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var profileImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = 60
    config.baseBackgroundColor = .systemYellow

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var nameTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.titleLabelText = "이름"
    textField.placeholder = "이름"
    return textField
  }()

  private lazy var idTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.textField.keyboardType = .asciiCapable
    textField.titleLabelText = "ID"
    textField.placeholder = "@ID1234"
    return textField
  }()

  private lazy var textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 40
    stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    stackView.isLayoutMarginsRelativeArrangement = true
    [
      self.nameTextField,
      self.idTextField
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    return stackView
  }()

  private lazy var favorSelectionCollectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.setupCollectionViewLayout()
    )

    // CollectionView Cell
    collectionView.register(
      FavorCell.self,
      forCellWithReuseIdentifier: FavorCell.reuseIdentifier
    )

    // Header
    collectionView.register(
      MyPageSectionHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: MyPageSectionHeaderView.reuseIdentifier
    )
    // Footer
    collectionView.register(
      MyPageSectionFooterView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: MyPageSectionFooterView.reuseIdentifier
    )

    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: EditMyPageReactor) {
    // Action
    Observable.just(())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.nameTextField.rx.text
      .orEmpty
      .subscribe(with: self, onNext: { _, text in
        print(text)
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.sections }
      .do {
        print($0)
      }
      .asObservable()
      .bind(to: self.favorSelectionCollectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupStyles() {
    super.setupStyles()
  }

  override func setupLayouts() {
    self.view.addSubview(self.scrollView)

    [
      self.backgroundImageButton,
      self.profileImageButton,
      self.textFieldStackView,
      self.favorSelectionCollectionView
    ].forEach {
      self.scrollView.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.backgroundImageButton.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(297)
    }

    self.profileImageButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.backgroundImageButton.snp.bottom)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(120)
    }

    self.textFieldStackView.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageButton.snp.bottom).offset(40)
      make.centerX.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
    }

    self.favorSelectionCollectionView.snp.makeConstraints { make in
      make.top.equalTo(self.textFieldStackView.snp.bottom).offset(40)
      make.width.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(232)
    }

    self.scrollView.snp.makeConstraints { make in
      make.bottom.equalTo(self.favorSelectionCollectionView.snp.bottom)
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewController {
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    // Layout
    let layout = UICollectionViewCompositionalLayout.init(sectionProvider: { [weak self] sectionIndex, _ in
      return self?.createCollectionViewLayoutSection(sectionIndex: sectionIndex)
    })
    return layout
  }

  func createCollectionViewLayoutSection(sectionIndex: Int) -> NSCollectionLayoutSection {
    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .estimated(30),
        heightDimension: .absolute(32)
      )
    )

    // Group
    let innerGroup = self.createCompositionalGroup(
      direction: .horizontal,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(32)
      ),
      subItem: item,
      count: 6
    )
    innerGroup.interItemSpacing = .fixed(10)

    let outerGroup = self.createCompositionalGroup(
      direction: .vertical,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(116)
      ),
      subItem: innerGroup,
      count: 3
    )
    outerGroup.interItemSpacing = .fixed(10)

    // Section
    let section = NSCollectionLayoutSection(group: outerGroup)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

    // Header
    section.boundarySupplementaryItems.append(self.createHeader())
    section.boundarySupplementaryItems.append(self.createFooter())

    return section
  }

  func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    return NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(40)
      ),
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
  }

  func createFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
    return NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(39)
      ),
      elementKind: UICollectionView.elementKindSectionFooter,
      alignment: .bottom
    )
  }

  func createCompositionalGroup(
    direction: ScrollDirection,
    layoutSize: NSCollectionLayoutSize,
    subItem: NSCollectionLayoutItem,
    count: Int
  ) -> NSCollectionLayoutGroup {
    var group: NSCollectionLayoutGroup
    if #available(iOS 16.0, *) {
      switch direction {
      case .vertical:
        group = NSCollectionLayoutGroup.vertical(
          layoutSize: layoutSize,
          repeatingSubitem: subItem,
          count: count
        )
      case .horizontal:
        group = NSCollectionLayoutGroup.horizontal(
          layoutSize: layoutSize,
          repeatingSubitem: subItem,
          count: count
        )
      }
    } else {
      switch direction {
      case .horizontal:
        group = NSCollectionLayoutGroup.horizontal(
          layoutSize: layoutSize,
          subitem: subItem,
          count: count
        )
      case .vertical:
        group = NSCollectionLayoutGroup.vertical(
          layoutSize: layoutSize,
          subitem: subItem,
          count: count
        )
      }
    }
    return group
  }
}
