//
//  FriendListModifyingViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/05/10.
//

import UIKit

import FavorKit
import ReactorKit
import SnapKit

final class FriendListModifyingViewController: BaseFriendListViewController, View {

  // MARK: - Constants

  // MARK: - Properties

  // MARK: - UI Components

  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.composer.compose()
  }
  
  // MARK: - Binding
  
  func bind(reactor: FriendListModifyingViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot: NSDiffableDataSourceSnapshot<FriendSection, FriendSectionItem> = .init()
        snapshot.appendSections(sectionData.sections)
        guard
          let friendItems = sectionData.items.first,
          let friendSection = sectionData.sections.first
        else { return }
        snapshot.appendItems(friendItems, toSection: friendSection)
        owner.dataSource.apply(snapshot, animatingDifferences: true)
        owner.collectionView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  /// 삭제 버튼 클릭 이벤트 메서드입니다.
  override func cellButtonDidTap<T>(with data: T) {
    guard
      let reactor = self.reactor,
      let data = data as? Friend
    else { return }
    
    // 친구 삭제 확인 팝업을 띄웁니다.
    let popup = NewAlertPopup(
      .onlyTitle(title: "삭제하시겠습니까?",
      .init(reject: "취소", accept: "삭제"))
    )
    popup.modalPresentationStyle = .overFullScreen
    self.present(popup, animated: false)
    
    // 삭제 버튼을 눌렸을 때 실행되는 클로저입니다.
    popup.accpetButtonCompletion = {
      reactor.action.onNext(.deleteButtonDidTap(data))
    }
  }

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}
