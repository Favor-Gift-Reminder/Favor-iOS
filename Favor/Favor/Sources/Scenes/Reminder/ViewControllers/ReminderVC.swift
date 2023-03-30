//
//  ReminderVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxCocoa
import RxDataSources
import SnapKit

final class ReminderViewController: BaseViewController, View {
  typealias ReminderDataSource = RxCollectionViewSectionedReloadDataSource<ReminderSection.ReminderSectionModel>

  // MARK: - Constants

  // MARK: - Properties

  private lazy var dataSource = ReminderDataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case .reminder(let reactor):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ReminderCell
        cell.reactor = reactor
        return cell
      }
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        for: indexPath
      ) as ReminderHeaderView
      let sectionItem = dataSource[indexPath.section]
      header.updateTitle(sectionItem.model.headerTitle)
      return header
    }
  )

  // MARK: - UI Components

  private lazy var selectDateButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.imagePlacement = .trailing
    config.imagePadding = 10
    config.image = .favorIcon(.down)

    let button = UIButton(configuration: config)
    return button
  }()

  private lazy var newReminderButton = FavorBarButtonItem(.addNoti)

  private lazy var emptyImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.deselect)?
      .withTintColor(.favorColor(.explain))
      .withAlignmentRectInsets(UIEdgeInsets(top: -35, left: -35, bottom: -35, right: -35))
    return imageView
  }()

  private lazy var emptyLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    label.text = "이벤트가 없습니다."
    return label
  }()

  private lazy var emptyContainerStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    return stackView
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: self.view.bounds,
      collectionViewLayout: self.setupCollectionViewLayout()
    )

    // register
    collectionView.register(cellType: FavorEmptyCell.self)
    collectionView.register(cellType: ReminderCell.self)
    collectionView.register(
      supplementaryViewType: ReminderHeaderView.self,
      ofKind: ReminderHeaderView.reuseIdentifier
    )

    collectionView.backgroundColor = .favorColor(.white)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()

  // MARK: - Life Cycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding

  override func bind() {
    guard let reactor = self.reactor else { return }

    reactor.state
      .map { state -> [ReminderSection.ReminderSectionModel] in
        [state.upcomingSection, state.pastSection]
          .compactMap { section -> ReminderSection.ReminderSectionModel? in
            guard !section.items.isEmpty else { return nil }
            return section
          }
      }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }

  func bind(reactor: ReminderViewReactor) {
    // Action
    self.rx.viewWillAppear
      .map { _ in Reactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.selectDateButton.rx.tap
      .map { Reactor.Action.selectDateButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.selectedDate }
      .asDriver(onErrorRecover: { _ in return .never()})
      .drive(with: self, onNext: { owner, date in
        owner.updateSelectedDate(to: date)
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  private func updateSelectedDate(to date: DateComponents) {
    guard let dateString = date.toYearMonthString() else { return }

    var container = AttributeContainer()
    container.font = .favorFont(.bold, size: 22)

    self.selectDateButton.configurationUpdateHandler = { button in
      button.configuration?.attributedTitle = AttributedString(dateString, attributes: container)
    }
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    [
      self.emptyImageView,
      self.emptyLabel
    ].forEach {
      self.emptyContainerStack.addArrangedSubview($0)
    }

    [
      self.emptyContainerStack,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  override func setupConstraints() {
    self.emptyImageView.snp.makeConstraints { make in
      make.width.height.equalTo(150)
    }

    self.emptyContainerStack.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}

// MARK: - Privates

private extension ReminderViewController {
  func setupNavigationBar() {
    let leftButton = UIBarButtonItem(customView: self.selectDateButton)
    self.navigationItem.setLeftBarButton(leftButton, animated: false)
    self.navigationItem.setRightBarButton(self.newReminderButton, animated: false)
  }

  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
      guard
        let sectionType = self?.dataSource[sectionIndex].model
      else { fatalError("Fatal error occured while setting up section datas.") }

      return self?.createCollectionViewLayout(sectionType: sectionType)
    })
    layout.register(
      PastSectionBackgroundView.self,
      forDecorationViewOfKind: PastSectionBackgroundView.reuseIdentifier
    )
    return layout
  }

  func createCollectionViewLayout(sectionType: ReminderSectionType) -> NSCollectionLayoutSection {
    // Item
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(95))
    )

    // Group
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(95)),
      subitems: [item]
    )

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 44, trailing: 20)

    let backgroundView = NSCollectionLayoutDecorationItem.background(
      elementKind: PastSectionBackgroundView.reuseIdentifier
    )
    if sectionType == .past {
      section.decorationItems = [backgroundView]
    }

    // header
    section.boundarySupplementaryItems = [
      self.createHeader(sectionType: sectionType)
    ]

    return section
  }

  func createHeader(sectionType: ReminderSectionType) -> NSCollectionLayoutBoundarySupplementaryItem {
    return NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: sectionType.headerHeight),
      elementKind: ReminderHeaderView.reuseIdentifier,
      alignment: .top
    )
  }
}
