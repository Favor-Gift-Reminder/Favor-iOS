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
    config.image = .favorIcon(.more)?.withTintColor(.white)
    $0.configuration = config
  }
  
  private let backButton: FavorButton = {
    let button = FavorButton(image: .favorIcon(.left)?.withTintColor(.white))
    button.baseForegroundColor = .white
    button.baseBackgroundColor = .clear
    button.contentInset = .zero
    return button
  }()
  
  private let deleteFriendButton: FavorButton = {
    let button = FavorButton("친구 끊기")
    button.font = .favorFont(.regular, size: 16)
    button.contentInset = .init(top: 20, leading: 20, bottom: 20, trailing: 52)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .favorColor(.icon)
    button.cornerRadius = 16
    button.shadowOffset = CGSize(width: 0, height: -1)
    button.shadowRadius = 4
    button.shadowOpacity = 0.03
    button.isHidden = true
    button.layer.opacity = 0
    return button
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.setupNavigationBar()
  }
  
  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.moreButton.toBarButtonItem(), animated: true)
    self.navigationItem.setLeftBarButton(self.backButton.toBarButtonItem(), animated: true)
    self.navigationItem.setHidesBackButton(true, animated: true)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.deleteFriendButton)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.deleteFriendButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(10)
      make.top.equalTo(self.view.safeAreaLayoutGuide)
    }
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
    
    self.backButton.rx.tap
      .map { Reactor.Action.backButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.moreButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.animateDeleteFriendButton(owner.deleteFriendButton.isHidden)
      }
      .disposed(by: self.disposeBag)
    
    self.deleteFriendButton.rx.tap
      .map { Reactor.Action.deleteFriendButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 스크롤
    self.collectionView.rx.contentOffset
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, offset in
        owner.updateProfileViewLayout(by: offset, name: reactor.currentState.friend.friendName)
        owner.animateDeleteFriendButton(false)
      })
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.tapGesture { gesture, _ in
      gesture.cancelsTouchesInView = true
    }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.animateDeleteFriendButton(false)
      }
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .map { indexPath -> FriendPageViewReactor.Action in
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .doNothing }
        switch item {
        case .anniversarySetupHelper:
          return FriendPageViewReactor.Action.anniversarySetupHelperCellDidTap
        default:
          return .doNothing
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { $0.friend.friendName }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, name in
        owner.profileView.rx.name.onNext(name)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.friend.friendID }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, id in
        owner.profileView.rx.id.onNext(id)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.friend.profilePhoto?.remote ?? "" }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, url in
        let friend = reactor.currentState.friend
        owner.profileView.updateProfileImage(
          url,
          mapper: .init(friend: friend, subpath: .profilePhoto(url))
        )
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.friend.backgroundPhoto?.remote ?? "" }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, url in
        let friend = reactor.currentState.friend
        owner.profileView.updateBackgroundImage(
          url,
          mapper: .init(friend: friend, subpath: .background(url))
        )
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
        if let header = self.giftStatsHeader {
          header.configure(with: reactor.currentState.friend)
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
    case .memo:
      self.reactor?.action.onNext(.modfiyMemeButtonDidTap)
    default:
      break
    }
  }
  
  override func rightButtonDidTap(anniversary: Anniversary) {
    super.rightButtonDidTap(anniversary: anniversary)
    
    self.reactor?.action.onNext(.addnotiButtonDidTap(anniversary))
  }
  
  override func injectReactor(to view: UICollectionReusableView) {
    guard
      let view = view as? ProfileGiftStatsCollectionHeader,
      let reactor = self.reactor
    else { return }
    view.reactor = ProfileGiftStatsCollectionHeaderReactor(friend: reactor.currentState.friend)
  }
  
  func memoBottomSheetCompletion(memo: String?) {
    guard let memo = memo else { return }
    self.reactor?.action.onNext(.memoDidChange(memo))
  }
  
  func animateDeleteFriendButton(_ isAnimated: Bool) {
    if isAnimated {
      self.deleteFriendButton.isHidden = false
      UIView.animate(
        withDuration: 0.1,
        animations: {
          self.deleteFriendButton.layer.opacity = 1
        }
      )
    } else {
      UIView.animate(
        withDuration: 0.1,
        animations: {
          self.deleteFriendButton.layer.opacity = 0
        },
        completion: { _ in
          self.deleteFriendButton.isHidden = true
        }
      )
    }
  }
}
