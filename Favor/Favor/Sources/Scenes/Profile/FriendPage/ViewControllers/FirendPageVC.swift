//
//  FirendPageVC.swift
//  Favor
//
//  Created by 김응철 on 2023/05/28.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit
import Then

final class FriendPageViewController: BaseProfileViewController, View {
  typealias DataSource = UICollectionViewDiffableDataSource<ProfileSection, ProfileSectionItem>
  
  // MARK: - UI Components
  
  private let moreButton: UIButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.more)
    $0.configuration = config
  }
  
  // MARK: - Properties
  
  private let friend: Friend
  
  /// 유저가 유저인지 판별해주는 계산 프로퍼티입니다.
  private var isUser: Bool { self.friend.isUser  }
  
  // MARK: - Initializer
  
  init(with friend: Friend) {
    self.friend = friend
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    if !self.isUser {
      self.profileView.idLabel.isHidden = true
      self.profileView.nameLabel.textColor = .favorColor(.black)
      self.profileView.rx.backgroundImage.onNext(nil)
    }
  }
  
  override func setupNavigationBar() {
    super.setupNavigationBar()
    
    self.navigationItem.rightBarButtonItem = self.moreButton.toBarButtonItem()
  }
  
  // MARK: - Bind
  
  func bind(reactor: FriendPageViewReactor) {
    // MARK: - Action
    
    // View 진입
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .map { _ in FriendPageViewReactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 스크롤
    self.collectionView.rx.contentOffset
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, offset in
        owner.updateProfileViewLayout(by: offset)
      })
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .map { indexPath -> FriendPageViewReactor.Action in
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .doNothing }
        switch item {
        case .memo(let memo):
          return FriendPageViewReactor.Action.memoCellDidTap(memo)
        case .anniversarySetupHelper:
          return FriendPageViewReactor.Action.anniversarySetupHelperCellDidTap
        default:
          return .doNothing
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // MARK: - State
    
    reactor.state.map { $0.friend.name }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, name in
        owner.profileView.rx.name.onNext(name)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapShot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileSectionItem>()
        snapShot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, items in
          snapShot.appendItems(items, toSection: sectionData.sections[idx])
        }
        owner.dataSource.apply(snapShot)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  override func headerRightButtonDidTap(at section: ProfileSection) {
    super.headerRightButtonDidTap(at: section)
    
    switch section {
    case .anniversaries:
      self.reactor?.action.onNext(.moreAnniversaryDidTap)
    default:
      break
    }
  }
  
  func memoBottomSheetCompletion(memo: String?) {
    self.reactor?.action.onNext(.memoDidChange(memo))
  }
}
