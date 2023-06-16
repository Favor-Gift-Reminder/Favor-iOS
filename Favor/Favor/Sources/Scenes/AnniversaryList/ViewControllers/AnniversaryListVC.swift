//
//  AnniversaryListVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import OSLog
import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class AnniversaryListViewController: BaseAnniversaryListViewController, View {

  // MARK: - Constants

  // MARK: - Properties
  
  private let anniversaryListType: AnniversaryListType

  // MARK: - UI Components
  
  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.icon)
    config.updateAttributedTitle("편집", font: .favorFont(.bold, size: 18))
    let button = UIButton(configuration: config)
    return button
  }()
  
  public lazy var floatyButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = 28
    config.baseBackgroundColor = .favorColor(.main)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.add)?.resize(newWidth: 20).withTintColor(.favorColor(.white))
    let button = UIButton(configuration: config)
    return button
  }()
  
  // MARK: - Initializer
  
  init(anniversaryListType: AnniversaryListType) {
    self.anniversaryListType = anniversaryListType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

  // MARK: - Binding
  
  func bind(reactor: AnniversaryListViewReactor) {
    // Action
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<AnniversaryListSection, AnniversaryListSectionItem>()
        snapshot.appendSections(sectionData.sections)
        snapshot.appendItems(sectionData.items)
        snapshot.reloadSections(sectionData.sections)
        DispatchQueue.main.async {
          owner.dataSource.apply(
            snapshot,
            animatingDifferences: true
          )
        }
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  override func transfer(_ model: (any CellModel)?, from cell: UICollectionViewCell) {
    guard
      let model = model as? AnniversaryListCellModel,
      let reactor = self.reactor
    else { return }
    reactor.action.onNext(.pinButtonDidTap(model.item))
  }
  
  // MARK: - UI Setups
  
  override func setupStyles() {
    super.setupStyles()
    
    /// 선택된 친구가 유저일 경우 UI를 변경합니다.
    if case AnniversaryListType.friend(_, true) = self.anniversaryListType {
      self.floatyButton.isHidden = true
      self.editButton.isHidden = true
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.floatyButton)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.floatyButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(22)
      make.trailing.equalTo(self.view.layoutMarginsGuide)
      make.width.height.equalTo(56)
    }
  }
}

// MARK: - Privates

private extension AnniversaryListViewController {
  func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.editButton.toBarButtonItem(), animated: false)
  }
}
