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
  
  private lazy var dataSource: ReminderDataSource = ReminderDataSource(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case .reminder(let reminder):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ReminderCell
        cell.cardCellType = .reminder
        cell.configure(reminder)
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
  
  private let newReminderButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.addNoti)
    let button = UIButton(configuration: config)
    return button
  }()
  
  private let monthSelectorButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.pick)
    config.imagePlacement = .trailing
    config.imagePadding = 14.0
    config.buttonSize = .medium
    let button = UIButton(configuration: config)
    return button
  }()
  
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
      frame: .zero,
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.updateNavigationBarColor(.white)
  }

  // MARK: - Binding
  
  override func bind() {
    guard let reactor = self.reactor else { return }

    self.collectionView.rx.modelSelected(ReminderSection.ReminderSectionItem.self)
      .map { item in Reactor.Action.reminderDidSelected(item) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
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
    
    reactor.state.map { (past: $0.pastSection, upcoming: $0.upcomingSection) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, sectionData in
        if sectionData.upcoming.items.isEmpty, !sectionData.past.items.isEmpty {
          owner.updateNavigationBarColor(.favorColor(.card))
        } else {
          owner.updateNavigationBarColor(.white)
        }
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isReminderEmpty }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isEmpty in
        owner.collectionView.isHidden = isEmpty
      })
      .disposed(by: self.disposeBag)
  }

  func bind(reactor: ReminderViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.newReminderButton.rx.tap
      .map { Reactor.Action.newReminderButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.monthSelectorButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        // 월 선택 팝업 창으로 전환합니다.
        let datePickerPopup = ReminderDatePopup(reactor.currentState.selectedDate)
        datePickerPopup.delegate = self
        datePickerPopup.modalPresentationStyle = .overFullScreen
        owner.present(datePickerPopup, animated: false)
      }
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.selectedDate }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, date in
        owner.monthSelectorButton.configuration?.updateAttributedTitle(
          "\(date.year ?? 0)년 \(date.month ?? 0)월",
          font: .favorFont(.bold, size: 18.0)
        )
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isLoading }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isLoading in
        owner.rx.isLoading.onNext(isLoading)
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  private func updateNavigationBarColor(_ color: UIColor) {
    guard let appearance = self.navigationController?.navigationBar.standardAppearance else { return }
    appearance.backgroundColor = color
    self.navigationController?.navigationBar.standardAppearance = appearance
    self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
  }
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
    
    self.setupNavigationBar()
  }
  
  override func setupLayouts() {
    [
      self.emptyImageView,
      self.emptyLabel
    ].forEach {
      self.emptyContainerStack.addArrangedSubview($0)
    }
    
    [
      self.emptyContainerStack,
      self.collectionView,
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
    
    self.monthSelectorButton.snp.makeConstraints { make in
      make.width.equalTo(200.0)
    }
  }
}

// MARK: - Privates

private extension ReminderViewController {
  func setupNavigationBar() {
    self.navigationItem.titleView = self.monthSelectorButton
    self.navigationItem.setRightBarButton(self.newReminderButton.toBarButtonItem(), animated: false)
  }
  
  func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
      let sectionType = self.dataSource[sectionIndex].model
      return self.createCollectionViewLayout(sectionType: sectionType)
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

// MARK: - ReminderDatePikcerPopup

extension ReminderViewController: ReminderDatePopupDelegate {
  /// 팝업이 선택되고 난 후 불려지는 메서드입니다.
  func reminderDatePopupDidClose(_ dateComponents: DateComponents) {
    self.reactor?.action.onNext(.selectedDateDidChange(dateComponents))
  }
}
