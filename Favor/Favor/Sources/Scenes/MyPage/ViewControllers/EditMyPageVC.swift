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
  typealias FavorSelectionDataSource = RxCollectionViewSectionedReloadDataSource<FavorSelectionSection>
  typealias NewAnniversaryDataSource = RxCollectionViewSectionedReloadDataSource<NewAnniversarySection>

  // MARK: - Constants

  private enum ElementKind {
    static let favorSelectionHeaderElementKind = "favor_selection_header"
    static let favorSelectionFooterElementKind = "favor_selection_footer"
    static let newAnniversaryHeaderElementKind = "new_anniversary_header"
  }

  // MARK: - Properties

  let favorSelectionDataSource = FavorSelectionDataSource(
    configureCell: { _, collectionView, indexPath, reactor in
      let cell = collectionView.dequeueReusableCell(for: indexPath) as FavorPrefersCell
      cell.reactor = reactor
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      switch kind {
      case ElementKind.favorSelectionHeaderElementKind:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as MyPageSectionHeaderView
        header.reactor = MyPageSectionHeaderViewReactor(title: dataSource.sectionModels[indexPath.item].header)
        return header
      case ElementKind.favorSelectionFooterElementKind:
        let footer = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as MyPageSectionFooterView
        footer.setupDescription("최대 5개까지 선택할 수 있습니다.")
        return footer
      default:
        return UICollectionReusableView()
      }
    }
  )

  let newAnniversaryDataSource = NewAnniversaryDataSource(configureCell: { _, collectionView, indexPath, reactor in
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: FavorAnniversaryCell.reuseIdentifier,
      for: indexPath
    ) as? FavorAnniversaryCell else { return UICollectionViewCell() }
    cell.reactor = reactor
    return cell
  }, configureSupplementaryView: { _, collectionView, kind, indexPath in
    guard let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: NewAnniversaryHeaderView.reuseIdentifier,
      for: indexPath
    ) as? NewAnniversaryHeaderView else { return UICollectionReusableView() }
    return header
  })

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
      collectionViewLayout: self.setupFavorSelectionCollectionViewLayout()
    )

    // CollectionView Cell
    collectionView.register(
      FavorPrefersCell.self,
      forCellWithReuseIdentifier: FavorPrefersCell.reuseIdentifier
    )

    // Header
    collectionView.register(
      supplementaryViewType: MyPageSectionHeaderView.self,
      ofKind: ElementKind.favorSelectionHeaderElementKind
    )
    // Footer
    collectionView.register(
      supplementaryViewType: MyPageSectionFooterView.self,
      ofKind: ElementKind.favorSelectionFooterElementKind
    )

    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()

  private lazy var newAnniversaryCollectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.setupNewAnniversaryCollectionViewLayout()
    )

    // CollectionView Cell
    collectionView.register(
      FavorAnniversaryCell.self,
      forCellWithReuseIdentifier: FavorAnniversaryCell.reuseIdentifier
    )

    // Header
    collectionView.register(
      supplementaryViewType: NewAnniversaryHeaderView.self,
      ofKind: ElementKind.newAnniversaryHeaderElementKind
    )

    collectionView.backgroundColor = .clear
    collectionView.isScrollEnabled = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: EditMyPageViewReactor) {
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
    reactor.state.map { $0.favorSelectionSections }
      .bind(to: self.favorSelectionCollectionView.rx.items(dataSource: self.favorSelectionDataSource))
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.newAnniversarySections }
      .bind(to: self.newAnniversaryCollectionView.rx.items(dataSource: self.newAnniversaryDataSource))
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
      self.favorSelectionCollectionView,
      self.newAnniversaryCollectionView
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

    self.newAnniversaryCollectionView.snp.makeConstraints { make in
      make.top.equalTo(self.favorSelectionCollectionView.snp.bottom).offset(40)
      make.width.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(445)
    }

    self.scrollView.snp.makeConstraints { make in
      make.bottom.equalTo(self.newAnniversaryCollectionView.snp.bottom).offset(40)
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewController {
  func setupFavorSelectionCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    // Layout
    let layout = UICollectionViewCompositionalLayout.init(sectionProvider: { [weak self] sectionIndex, _ in
      return self?.createFavorSelectionCollectionViewSection(sectionIndex: sectionIndex)
    })
    return layout
  }

  func createFavorSelectionCollectionViewSection(sectionIndex: Int) -> NSCollectionLayoutSection {
    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .estimated(30),
        heightDimension: .absolute(32)
      )
    )

    // Group
    let innerGroup = CompositionalLayoutFactory.shared.makeCompositionalGroup(
      direction: .horizontal,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(32)
      ),
      subItem: item,
      count: 6
    )
    innerGroup.interItemSpacing = .fixed(10)

    let outerGroup = CompositionalLayoutFactory.shared.makeCompositionalGroup(
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
    section.boundarySupplementaryItems.append(contentsOf: [
      CompositionalLayoutFactory.shared.make(
        .header,
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(40)
        ),
        kind: ElementKind.favorSelectionHeaderElementKind
      ),
      CompositionalLayoutFactory.shared.make(
        .footer,
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(39)
        ),
        kind: ElementKind.favorSelectionFooterElementKind
      )
    ])

    return section
  }

  func setupNewAnniversaryCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout.init(sectionProvider: { [weak self] _, _ in
      return self?.createNewAnniversaryCollectionViewSection()
    })
    return layout
  }

  func createNewAnniversaryCollectionViewSection() -> NSCollectionLayoutSection {
    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )

    // Group
    let group = CompositionalLayoutFactory.shared.makeCompositionalGroup(
      direction: .horizontal,
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(95)
      ),
      subItem: item,
      count: 1
    )

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

    // Header
    section.boundarySupplementaryItems.append(
      CompositionalLayoutFactory.shared.make(
        .header,
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(140)
        ),
        kind: ElementKind.newAnniversaryHeaderElementKind
      )
    )

    return section
  }
}
