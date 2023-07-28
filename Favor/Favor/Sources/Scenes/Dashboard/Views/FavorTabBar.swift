//
//  FavorTabBar.swift
//  Favor
//
//  Created by 김응철 on 6/19/23.
//

import UIKit

import FavorKit
import RxSwift
import SnapKit

protocol FavorTabBarDelegate: AnyObject {
  func didTapAddGiftButton()
}

final class FavorTabBar: UITabBar {
  
  // MARK: - UI Components
  
  private lazy var homeButton = self.makeButton(.favorIcon(.home))
  private lazy var friendButton = self.makeButton(.favorIcon(.friend))
  
  private lazy var middleButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.main)
    config.image = .favorIcon(.tabbar)
    config.background.cornerRadius = 20.0
    let button = UIButton(configuration: config)
    button.addTarget(self, action: #selector(self.didTapMiddleButton), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Properties
  
  var selectedIndex: Int = 0 {
    didSet { self.updateUI() }
  }
  
  var isDrawn: Bool = false
  weak var eventDelegate: FavorTabBarDelegate?
  
  // MARK: - DrawCycle
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    if !self.isDrawn {
      self.setupShapeLayer()
      self.setupMiddleButton()
      self.isDrawn = true
    }
  }
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  /// 중앙에 위치한 새로운 선물 등록하기 버튼을 설정하는 메서드입니다.
  private func setupMiddleButton() {
    self.addSubview(self.middleButton)
    self.middleButton.frame.size = CGSize(width: 40, height: 40)
    self.middleButton.center = CGPoint(x: self.frame.width / 2, y: 0)
  }
  
  /// 전체적인 레이어를 조정하는 메서드입니다.
  private func setupShapeLayer() {
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = self.drawPath()
    shapeLayer.fillColor = UIColor.favorColor(.white).cgColor
    // Shadow
    shapeLayer.shadowColor = UIColor.favorColor(.black).cgColor
    shapeLayer.shadowOffset = CGSize(width: 0, height: -1)
    shapeLayer.shadowOpacity = 0.03
    self.layer.insertSublayer(shapeLayer, at: 0)
  }
  
  /// 테두리 레이어를 그리는 메서드입니다.
  private func drawPath() -> CGPath {
    /// 전체 너비 값의 중간 값입니다.
    let centerWidth: CGFloat = self.frame.width / 2
    /// 모서리에 `CornerRadius`값 입니다.
    let borderCornerRadius: CGFloat = 12.0
    /// 중앙의 커브가 시작 지점부터 끝 지점까지의 너비 값입니다.
    let circleCurveWidth: CGFloat = 64.0
    /// 첫 번쨰 커브가 시작되는 좌표입니다.
    let startCurvePoint = CGPoint(x: centerWidth - (circleCurveWidth / 2), y: 0)
    /// 반원이 시작되는 좌표입니다.
    let startSemiCirclePoint = CGPoint(x: startCurvePoint.x + 8, y: 7)
    /// 반원의 중간 부분의 좌표입니다.
    let middleSemiCirclePoint = CGPoint(x: centerWidth, y: 25)
    /// 반원의 끝 부분의 좌표입니다.
    let endSemiCirclePoint = CGPoint(x: centerWidth + (circleCurveWidth / 2) - 8, y: 7)
    /// 마지막으로 최종 커브가 종료되는 좌표입니다.
    let endCurvePoint = CGPoint(x: centerWidth + (circleCurveWidth / 2), y: 0)
    /// 오른쪽 상단의 모서리 좌표입니다.
    let topRightPoint = CGPoint(x: self.frame.maxX, y: 0)
    /// 오른쪽 하단의 모서리 좌표입니다.
    let bottomRightPoint = CGPoint(x: self.frame.maxX, y: self.frame.maxY)
    /// 왼쪽 하단의 모서리 좌표입니다.
    let bottomLeftPoint = CGPoint(x: 0, y: self.frame.maxY)
        
    // 1. 선을 그리기 시작합니다.
    let bezPath = UIBezierPath()
    bezPath.move(to: CGPoint(x: borderCornerRadius, y: 0))
    bezPath.addLine(to: CGPoint(x: centerWidth - (circleCurveWidth / 2), y: 0))
    // 2. 첫 번째 커브가 시작되는 구간입니다.
    bezPath.addCurve(
      to: startSemiCirclePoint,
      controlPoint1: CGPoint(x: startCurvePoint.x + 5, y: 0),
      controlPoint2: CGPoint(x: startSemiCirclePoint.x - 0.7, y: 4.8)
    )
    // 3. 반원이 시작되는 구간입니다. 반원의 중간 지점에서 종료됩니다.
    bezPath.addCurve(
      to: middleSemiCirclePoint,
      controlPoint1: CGPoint(x: startSemiCirclePoint.x + 3, y: startSemiCirclePoint.y + 10),
      controlPoint2: CGPoint(x: middleSemiCirclePoint.x - 12, y: middleSemiCirclePoint.y)
    )
    // 4. 반원이 중간 지점부터 끝 부분까지 반원을 그립니다.
    bezPath.addCurve(
      to: endSemiCirclePoint,
      controlPoint1: CGPoint(x: middleSemiCirclePoint.x + 12, y: middleSemiCirclePoint.y),
      controlPoint2: CGPoint(x: endSemiCirclePoint.x - 3, y: endSemiCirclePoint.y + 10)
    )
    // 5. 반원의 끝 부분부터 커브가 종료되는 좌표까지 커브를 그립니다.
    bezPath.addCurve(
      to: endCurvePoint,
      controlPoint1: CGPoint(x: endSemiCirclePoint.x + 0.7, y: 4.8),
      controlPoint2: CGPoint(x: endCurvePoint.x - 5, y: 0)
    )
    // 6. 나머지 선분과 테두리의 CornerRadius를 적용한 모서리를 그립니다.
    bezPath.addLine(to: CGPoint(x: self.frame.maxX - borderCornerRadius, y: 0))
    bezPath.addCurve(
      to: CGPoint(x: topRightPoint.x, y: borderCornerRadius),
      controlPoint1: CGPoint(x: topRightPoint.x - borderCornerRadius + 6.63, y: 0),
      controlPoint2: CGPoint(x: topRightPoint.x, y: 5.37)
    )
    bezPath.addLine(to: bottomRightPoint)
    bezPath.addLine(to: bottomLeftPoint)
    bezPath.addLine(to: CGPoint(x: 0, y: borderCornerRadius))
    bezPath.addCurve(
      to: CGPoint(x: borderCornerRadius, y: 0),
      controlPoint1: CGPoint(x: 0, y: 5.37),
      controlPoint2: CGPoint(x: 5.37, y: 0)
    )
    bezPath.close()
    
    return bezPath.cgPath
  }
  
  /// 버튼을 만들어냅니다.
  private func makeButton(_ icon: UIImage?) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.baseBackgroundColor = .clear
    config.image = icon?
      .resize(newWidth: 24.0)
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = {
      let image: UIImage? = icon?
        .resize(newWidth: 24.0)
      switch $0.state {
      case .selected:
        $0.configuration?.image = image?.withTintColor(.favorColor(.main))
      default:
        $0.configuration?.image = image?.withTintColor(.favorColor(.nav))
      }
    }
    return button
  }
  
  /// 인덱스가 바뀔 때 마다 UI를 업데이트합니다.
  private func updateUI() {
    self.homeButton.isSelected = false
    self.friendButton.isSelected = false
    if self.selectedIndex == 0 {
      self.homeButton.isSelected = true
    } else {
      self.friendButton.isSelected = true
    }
  }
  
  /// 터치 영역을 조절하는 메서드입니다.
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if self.isHidden {
      return super.hitTest(point, with: event)
    }
    let from = point
    let to = self.middleButton.center
    
    // 피타고라스 법칙을 이용하여 중앙 버튼의 터치를 감지합니다.
    return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
    <= 20 ? self.middleButton :super.hitTest(point, with: event)
  }
  
  /// 중앙 버튼이 터치될 때 불려지는 메서드입니다.
  @objc private func didTapMiddleButton() {
    self.eventDelegate?.didTapAddGiftButton()
  }
}

// MARK: - Setup

extension FavorTabBar: BaseView {
  func setupStyles() {
    self.backgroundColor = .clear
    self.barTintColor = .clear
  }
  
  func setupLayouts() {
    [
      self.homeButton,
      self.friendButton
    ].forEach {
      self.insertSubview($0, at: 0)
    }
  }
  
  func setupConstraints() {
    self.homeButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12.0)
      make.leading.equalToSuperview().inset(70.0)
    }
    
    self.friendButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12.0)
      make.trailing.equalToSuperview().inset(70.0)
    }
  }
}
