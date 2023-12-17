//
//  AuthTermVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/19.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import RxCocoa
import SnapKit

public final class AuthTermViewController: BaseViewController, View {
  typealias TermDataSource = UICollectionViewDiffableDataSource<AuthTermSection, AuthTermSectionItem>

  // MARK: - Constants

  private enum Metric {
    static let topSpacing: CGFloat = 64.0
    static let profileImageViewSize: CGFloat = 100.0
    static let cellHeight: CGFloat = 32.0
    static let cellSpacing: CGFloat = 16.0
    static let bottomSpacing: CGFloat = 32.0
  }

  // MARK: - Properties

  private var dataSource: TermDataSource?

  private lazy var composer: Composer<AuthTermSection, AuthTermSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    return composer
  }()
  
  // MARK: - UI Components
  
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .favorIcon(.friend)?
      .withTintColor(.white)
      .resize(newWidth: 50)
    imageView.backgroundColor = .favorColor(.divider)
    imageView.layer.cornerRadius = Metric.profileImageViewSize / 2
    imageView.layer.masksToBounds = true
    imageView.contentMode = .center
    imageView.layer.borderWidth = 3.5
    imageView.layer.borderColor = UIColor.white.cgColor
    return imageView
  }()
  
  private let userCircleImageView: UIImageView = {
    let imageView = UIImageView(image: .favorIcon(.user_circle))
    imageView.layer.borderColor = UIColor.favorColor(.main).cgColor
    imageView.layer.borderWidth = 3.5
    imageView.backgroundColor = .clear
    imageView.layer.cornerRadius = 53.5
    return imageView
  }()
  
  private let welcomeLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textAlignment = .center
    label.font = .favorFont(.bold, size: 22)
    label.text = "이름님\n환영합니다!"
    return label
  }()

  private lazy var acceptAllView: TermAcceptAllView = {
    let view = TermAcceptAllView()
    view.delegate = self
    return view
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.isScrollEnabled = false
    collectionView.contentMode = .bottom
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()
  private var collectionViewHeight: Constraint?

  private let startButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main("확인"))
    button.isEnabled = false
    return button
  }()

  // MARK: - Life Cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupDataSource()
    self.composer.compose()
  }

  // MARK: - Binding

  public func bind(reactor: AuthTermViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.itemSelected
      .map { Reactor.Action.itemSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.startButton.rx.tap
      .map { Reactor.Action.nextButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.userProfile }
      .filter { $0 != nil }
      .bind(with: self, onNext: { owner, image in
        owner.profileImageView.contentMode = .scaleAspectFill
        owner.profileImageView.image = image
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.userName }
      .bind(with: self, onNext: { owner, userName in
        owner.welcomeLabel.text = "\(userName)님\n환영합니다"
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isAllAccepted }
      .bind(with: self, onNext: { owner, isAccepted in
        owner.acceptAllView.updateCheckButton(isAllAccepted: isAccepted)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.termItems }
      .asDriver(onErrorRecover: { _ in return .never() })
      .drive(with: self, onNext: { (owner: AuthTermViewController, items: [AuthTermSectionItem]) in
        var snapshot = NSDiffableDataSourceSnapshot<AuthTermSection, AuthTermSectionItem>()
        snapshot.appendSections([.term])
        snapshot.appendItems(items, toSection: .term)

        let cellsHeight: CGFloat = CGFloat(items.count) * Metric.cellHeight
        let spacingsHeight: CGFloat = CGFloat(items.count - 1) * Metric.cellSpacing
        let height: CGFloat = cellsHeight + spacingsHeight
        DispatchQueue.main.async {
          owner.collectionViewHeight?.update(offset: height)
          owner.dataSource?.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isNextButtonEnabled }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self, onNext: { owner, isEnabled in
        owner.startButton.isEnabled = isEnabled
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isLoading }
      .bind(to: self.rx.isLoading)
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions
  
  // MARK: - UI Setups
  
  public override func setupLayouts() {
    [
      self.userCircleImageView,
      self.profileImageView,
      self.welcomeLabel,
      self.acceptAllView,
      self.collectionView,
      self.startButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  public override func setupConstraints() {
    self.userCircleImageView.snp.makeConstraints { make in
      make.size.equalTo(107.0)
      make.center.equalTo(self.profileImageView)
    }
    
    self.profileImageView.snp.makeConstraints { make in
      make.top.equalTo(self.view.layoutMarginsGuide).inset(Metric.topSpacing)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(Metric.profileImageViewSize)
    }
    
    self.welcomeLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.profileImageView.snp.bottom).offset(32)
    }

    self.acceptAllView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.collectionView.snp.top).offset(-Metric.cellSpacing)
      make.height.equalTo(Metric.cellHeight)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.startButton.snp.top).offset(-80)
      self.collectionViewHeight = make.height.equalTo(32).constraint
    }
    
    self.startButton.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(Metric.bottomSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}

// MARK: - Privates

private extension AuthTermViewController {
  func setupDataSource() {
    let termCellRegistration = UICollectionView.CellRegistration
    <AuthTermCell, AuthTermSectionItem> { [weak self] cell, _, item in
      guard self != nil else { return }
      cell.bind(terms: item.terms)
    }

    self.dataSource = TermDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        return collectionView.dequeueConfiguredReusableCell(
          using: termCellRegistration, for: indexPath, item: item)
      }
    )
  }
}

// MARK: - Accept All View

extension AuthTermViewController: TermAcceptAllViewDelegate {
  public func acceptAllDidSelected() {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.acceptAllDidTap)
  }
}
