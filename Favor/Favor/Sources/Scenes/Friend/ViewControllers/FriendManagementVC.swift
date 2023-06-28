//
//  FriendManagementVC.swift
//  Favor
//
//  Created by 김응철 on 2023/05/19.
//

import UIKit

import FavorKit
import ReactorKit
import Then

public final class FriendManagementViewController: BaseViewController, View {
  
  public enum ViewControllerType {
    case new
    case edit(Friend)
  }
  
  private enum Metric {
    static let topSpacing: CGFloat = 56.0
    static let nameTextFieldTopSpacing: CGFloat = 40.0
  }
  
  // MARK: - UI Components
  
  private let profileImageRegisterButton: FavorProfileImageRegisterButton = {
    let button = FavorProfileImageRegisterButton()
    button.isHiddenPlusView = false
    return button
  }()

  private lazy var nameTextField: FavorTextField = FavorTextField().then {
    $0.titleLabelText = "이름"
    switch self.viewControllerType {
    case .new:
      $0.placeholder = "친구의 이름"
    case .edit:
      break
    }
  }
  
  private lazy var finishButton: UIButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    let title: String
    switch self.viewControllerType {
    case .new: title = "등록"
    case .edit: title = "완료"
    }
    var container: AttributeContainer = AttributeContainer()
    container.font = .favorFont(.bold, size: 18)
    config.attributedTitle = AttributedString(title, attributes: container)
    $0.configuration = config
    $0.configurationUpdateHandler = { button in
      switch button.state {
      case .disabled:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      default:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      }
    }
  }
  
  // MARK: - Properties
  
  private let viewControllerType: ViewControllerType
  
  // MARK: - Initializer
  
  init(_ viewControllerType: ViewControllerType) {
    self.viewControllerType = viewControllerType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  public override func setupStyles() {
    let title: String
    switch self.viewControllerType {
    case .new: title = "새 친구"
    case .edit: title = "프로필 수정"
    }
    self.navigationItem.title = title
    self.view.backgroundColor = .favorColor(.white)
    self.navigationItem.rightBarButtonItem = self.finishButton.toBarButtonItem()
    self.finishButton.isEnabled = false
  }
  
  public override func setupLayouts() {
    [
      self.profileImageRegisterButton,
      self.nameTextField
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  public override func setupConstraints() {
    self.profileImageRegisterButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(Metric.topSpacing)
    }
    
    self.nameTextField.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageRegisterButton.snp.bottom).offset(Metric.nameTextFieldTopSpacing)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }
  }
  
  // MARK: - Bind
  
  public func bind(reactor: FriendManagementViewReactor) {
    
  }
}
