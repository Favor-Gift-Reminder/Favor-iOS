//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxGesture
import SnapKit

final class MyPageViewController: BaseProfileViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.edit)?.withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()
  
  private let settingButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.setting)?.withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()
  
  private let favorLabelButton: UIButton = {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = UIFont.favorFont(.bold, size: 22.0)
    config.attributedTitle = AttributedString("Favor", attributes: container)
    config.baseForegroundColor = .favorColor(.white)
    let button = UIButton(configuration: config)
    button.isUserInteractionEnabled = false
    return button
  }()
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.setupNavigationBar()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 스크롤
    self.collectionView.rx.contentOffset
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, offset in
        owner.updateProfileViewLayout(by: offset, name: self.reactor?.currentState.userName ?? "")
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Binding
  
  func bind(reactor: MyPageViewReactor) {
    // MARK: - Action
    // View 진입
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // 편집 버튼 Tap
    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 설정 버튼 Tap
    self.settingButton.rx.tap
      .map { Reactor.Action.settingButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // Cell 선택
    self.collectionView.rx.itemSelected
      .map { indexPath -> Reactor.Action in
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .doNothing }
        switch item {
        case .profileSetupHelper(.anniversary):
          return .profileSetupCellDidTap(.anniversary)
        case .friends(let friend):
          return .friendCellDidTap(friend)
        default:
          return .doNothing
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // MARK: - State
    reactor.state.map { $0.userName }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, name in
        owner.profileView.rx.name.onNext(name)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.userID }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, id in
        owner.profileView.rx.id.onNext(id)
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.backgroundURL ?? "" }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, url in
        let user = owner.reactor?.currentState.user ?? .init()
        owner.profileView.updateBackgroundImage(url, mapper: .init(user: user, subpath: .background(url)))
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.profileURL ?? "" }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, url in
        let user = owner.reactor?.currentState.user ?? .init()
        owner.profileView.updateProfileImage(url, mapper: .init(user: user, subpath: .profilePhoto(url)))
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, items in
          snapshot.appendItems(items, toSection: sectionData.sections[idx])
        }
        DispatchQueue.main.async {
          if let header = self.giftStatsHeader {
            header.configure(with: owner.reactor?.currentState.user ?? .init())
          }
          owner.dataSource.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  private func setupNavigationBar() {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    let rightBarItems = [self.settingButton.toBarButtonItem(), self.editButton.toBarButtonItem()]
    self.navigationItem.setRightBarButtonItems(rightBarItems, animated: false)
  }
  
  override func injectReactor(to view: UICollectionReusableView) {
    guard
      let view = view as? ProfileGiftStatsCollectionHeader,
      let reactor = self.reactor
    else { return }
    view.reactor = ProfileGiftStatsCollectionHeaderReactor(user: reactor.currentState.user)
  }
  
  /// 더보기 버튼을 클릭할 때의 이벤트 메서드입니다.
  override func headerRightButtonDidTap(at section: ProfileSection) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.headerRightButtonDidTap(section))
  }
  
  /// `ProfileSetup`의 바로가기 버튼을 클릭할 때의 이벤트 메서드입니다.
  override func profileSetupGoButtonDidTap(
    at type: ProfileHelperType
  ) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.profileSetupCellDidTap(type))
  }
}
