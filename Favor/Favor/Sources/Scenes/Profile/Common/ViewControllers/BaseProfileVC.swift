//
//  BaseProfileVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/18.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import Reusable
import RxDataSources
import SnapKit

public class BaseProfileViewController: BaseViewController {
  typealias ProfileDataSource = UICollectionViewDiffableDataSource<ProfileSection, ProfileSectionItem>

  // MARK: - Constants

  private enum Metric {
    /// 헤더와 컬렉션뷰가 겹치는 높이
    static let profileViewOverliedHeight = 24.0
  }

  // MARK: - Properties
  
  lazy var dataSource: ProfileDataSource = {
    let dataSource = ProfileDataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .anniversarySetupHelper:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileAnniversarySetupHelperCell
          return cell
        case .profileSetupHelper(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileSetupHelperCell
          cell.reactor = reactor
          return cell
        case .favors(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileFavorCell
          cell.reactor = reactor
          return cell
        case .anniversaries(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileAnniversaryCell
          cell.reactor = reactor
          return cell
        case .memo(let memo):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileMemoCell
          cell.configure(with: memo)
          return cell
        case .friends(let reactor):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileFriendCell
          cell.reactor = reactor
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      switch kind {
      case ProfileElementKind.collectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as ProfileGiftStatsCollectionHeader
        self.injectReactor(to: header)
        return header
      case UICollectionView.elementKindSectionHeader:
        let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          for: indexPath
        ) as ProfileSectionHeader
        guard let section = dataSource.sectionIdentifier(for: indexPath.section) else {
          return UICollectionReusableView()
        }
        header.reactor = ProfileSectionHeaderReactor(section: section)
        header.rx.rightButtonDidTap
          .asDriver(onErrorRecover: { _ in return .empty()})
          .drive(with: self, onNext: { owner, _ in
            owner.headerRightButtonDidTap(at: section)
          })
          .disposed(by: header.disposeBag)
        return header
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()

  lazy var composer: Composer<ProfileSection, ProfileSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    let header = UICollectionViewComposableLayout.BoundaryItem.header(
      height: .estimated(128),
      kind: ProfileElementKind.collectionHeader
    )
    composer.configuration = Composer.Configuration(
      scrollDirection: .vertical,
      header: header,
      background: [
        ProfileElementKind.sectionWhiteBackground: ProfileSectionBackgroundView.self
      ]
    )
    return composer
  }()

  // MARK: - UI Components

  let profileView = ProfileView()
  private var profileViewHeightConstraint: Constraint?

  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )
    
    // CollectionViewCell
    collectionView.register(cellType: ProfileSetupHelperCell.self)
    collectionView.register(cellType: ProfileAnniversarySetupHelperCell.self)
    collectionView.register(cellType: ProfileFavorCell.self)
    collectionView.register(cellType: ProfileAnniversaryCell.self)
    collectionView.register(cellType: ProfileFriendCell.self)
    collectionView.register(cellType: ProfileMemoCell.self)

    // SupplementaryView
    collectionView.register(
      supplementaryViewType: ProfileGiftStatsCollectionHeader.self,
      ofKind: ProfileElementKind.collectionHeader
    )
    collectionView.register(
      supplementaryViewType: ProfileSectionHeader.self,
      ofKind: UICollectionView.elementKindSectionHeader
    )
    
    // Configure
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(
      top: ProfileView.height - Metric.profileViewOverliedHeight,
      left: .zero,
      bottom: .zero,
      right: .zero
    )
    collectionView.contentInsetAdjustmentBehavior = .never
    return collectionView
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.composer.compose()
  }
  
  // MARK: - Functions
  
  /// CollectionView의 contentOffset에 따라 ProfileView의 크기와 흐림도를 업데이트합니다.
  /// - Parameters:
  ///   - offset: CollectionView의 `contentOffset`
  public func updateProfileViewLayout(by offset: CGPoint) {
    /// 둥근 모서리를 제외한 컨텐츠의 최상단과 화면 상단 사이의 거리 (초기값 = ProfileView height)
    let spaceBetweenTopAndContent = abs(offset.y) + Metric.profileViewOverliedHeight
    /// 컨텐츠의 최상단(`GiftStatsHeader`)이 화면 상단보다 아래에 있는 지 여부
    let isContentBelowTopOfScreen = offset.y < 0
    /// ProfileView의 height보다 아래로 더 스크롤 됐는 지 여부
    let isScrollViewInMiddleOfBounds = (offset.y - Metric.profileViewOverliedHeight) > -ProfileView.height
    
    // 컨텐츠가 `ProfileView`의 최대 높이 범위(330) 안에 있는 경우
    // ProfileView의 높이 변화
    if isContentBelowTopOfScreen, isScrollViewInMiddleOfBounds {
      self.profileViewHeightConstraint?.update(offset: spaceBetweenTopAndContent)
      self.profileView.updateBackgroundAlpha(to: spaceBetweenTopAndContent / ProfileView.height)
    }
    // 컨텐츠의 최상단(`GiftStatsHeader`)이 화면의 상단보다 위에 있는 경우
    // contentInset은 `.zero`로 고정하고 ProfileView는 숨겨짐
    else if !isContentBelowTopOfScreen {
      self.profileViewHeightConstraint?.update(offset: 0)
      self.profileView.updateBackgroundAlpha(to: 0)
    }
    // 스크롤뷰가 허용 범위보다 더 스크롤 됐을 경우
    // ProfileView의 크기를 더 크게
    else {
      self.profileViewHeightConstraint?.update(offset: spaceBetweenTopAndContent)
      self.profileView.updateBackgroundAlpha(to: 1)
    }
  }

  public func injectReactor(to view: UICollectionReusableView) { }
  func headerRightButtonDidTap(at section: ProfileSection) { }

  // MARK: - UI Setups

  public override func setupStyles() {
    self.view.backgroundColor = .favorColor(.white)
  }
  
  public override func setupLayouts() {
    [
      self.profileView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }

  public override func setupConstraints() {
    self.profileView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview()
      self.profileViewHeightConstraint = make.height.equalTo(ProfileView.height).constraint
    }

    self.collectionView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
}
