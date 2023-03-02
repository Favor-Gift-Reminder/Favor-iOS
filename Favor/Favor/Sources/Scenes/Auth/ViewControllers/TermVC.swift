//
//  TermVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/19.
//

import UIKit

import ReactorKit
import Reusable
import RxCocoa
import RxDataSources
import SnapKit

final class TermViewController: BaseViewController, View {


  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
    static let cellHeight = 44.0
    static let bottomSpacing = 32.0
  }

  // MARK: - Properties

  let dataSource = RxTableViewSectionedReloadDataSource<TermSection>(
    configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(for: indexPath) as AcceptTermCell
      cell.bind(terms: item)
      return cell
    }
  )

  // MARK: - UI Components

  private lazy var logoImage: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "app.gift.fill")
    imageView.tintColor = .favorColor(.black)
    return imageView
  }()

  private lazy var welcomeLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textAlignment = .center
    label.font = .favorFont(.bold, size: 22)
    label.text = "이름 님\n환영합니다"
    return label
  }()

  private lazy var acceptAllView = AcceptAllView()

  private lazy var termTableView: SelfSizingTableView = {
    let tableView = SelfSizingTableView(frame: .zero, style: .plain)
    tableView.register(cellType: AcceptTermCell.self)
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.isScrollEnabled = false
    tableView.alwaysBounceVertical = false
    tableView.separatorStyle = .none
    return tableView
  }()

  private lazy var startButton: LargeFavorButton = {
    let button = LargeFavorButton(with: .main("시작하기"))
    button.isEnabled = false
    return button
  }()

  // MARK: - Life Cycle

  // MARK: - Binding

  func bind(reactor: TermViewReactor) {
    self.termTableView.rx.setDelegate(self).disposed(by: self.disposeBag)

    // Action
    Observable.just(())
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.termTableView.rx.itemSelected
      .bind(with: self, onNext: { owner, indexPath in
        owner.termTableView.deselectRow(at: indexPath, animated: false)
        guard let cell = owner.termTableView.cellForRow(
          at: indexPath
        ) as? AcceptTermCell else { return }
        cell.isChecked.toggle()
      })
      .disposed(by: self.disposeBag)

    // State
    reactor.state.map { $0.userName }
      .bind(with: self, onNext: { owner, userName in
        owner.welcomeLabel.text = "\(userName) 님\n환영합니다"
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.termSections }
      .bind(to: self.termTableView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.logoImage,
      self.welcomeLabel,
      self.acceptAllView,
      self.termTableView,
      self.startButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.logoImage.snp.makeConstraints { make in
      make.width.height.equalTo(70)
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.layoutMarginsGuide).inset(Metric.topSpacing)
    }
    
    self.welcomeLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.logoImage.snp.bottom).offset(28)
    }

    self.acceptAllView.snp.makeConstraints { make in
      make.bottom.equalTo(self.termTableView.snp.top)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.height.equalTo(Metric.cellHeight)
    }

    self.termTableView.snp.makeConstraints { make in
      make.bottom.equalTo(self.startButton.snp.top).offset(-56)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
    
    self.startButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(Metric.bottomSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
}

extension TermViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Metric.cellHeight
  }
}
