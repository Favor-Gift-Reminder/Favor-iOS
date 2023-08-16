//
//  FavorSwitch.swift
//  Favor
//
//  Created by 이창준 on 2023/03/15.
//

import UIKit

import SnapKit

public protocol FavorSwitchDelegate: AnyObject {
  func switchDidToggled(to state: Bool)
}

public final class FavorSwitch: UIButton {
  public typealias SwitchColor = (bar: UIColor, thumb: UIColor)

  // MARK: - Constants

  // MARK: - Properties

  public weak var delegate: FavorSwitchDelegate?

  private var animator: UIViewPropertyAnimator?

  public var isOn: Bool = false {
    willSet { self.animateState(to: newValue) }
    didSet { self.delegate?.switchDidToggled(to: self.isOn) }
  }
  
  /// Switch가 켜졌을 때의 색상
  public var onTintColor: SwitchColor = (.favorColor(.main), .favorColor(.white))

  /// Switch가 꺼졌을 때의 색상
  public var offTintColor: SwitchColor = (.favorColor(.line3), .favorColor(.white))

  /// Thumb와 Bar의 top, bottom 간격
  public var thumbVerticalPadding: CGFloat = 2.0

  /// Thumb와 Bar의 leading, trailing 간격
  public var thumbHorizontalPadding: CGFloat = 2.0

  private var thumbOnLocation: CGFloat {
    self.frame.width - (self.thumbView.frame.width / 2) - self.thumbHorizontalPadding
  }

  private var thumbOffLocation: CGFloat {
    (self.thumbView.frame.width / 2) + self.thumbHorizontalPadding
  }

  public var duration: TimeInterval = 0.2

  // MARK: - UI Components

  private lazy var barView = {
    let view = UIView()
    view.clipsToBounds = true
    return view
  }()

  private lazy var thumbView = {
    let view = UIView()
    view.clipsToBounds = true
    return view
  }()

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

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.isOn.toggle()
  }

  public override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    self.updateShape()
  }
}

// MARK: - UI Setup

extension FavorSwitch: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    self.addSubview(self.barView)
    self.barView.addSubview(self.thumbView)
  }

  public func setupConstraints() {
    self.barView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.thumbView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview().inset(self.thumbVerticalPadding)
      make.centerX.equalTo(self.thumbOffLocation)
      make.width.equalTo(self.thumbView.snp.height)
    }
  }
}

// MARK: - Privates

private extension FavorSwitch {
  func animateState(to isOn: Bool) {
    self.layoutIfNeeded()
    let centerX = isOn ? self.thumbOnLocation : self.thumbOffLocation
    self.animator = UIViewPropertyAnimator(
      duration: self.duration,
      curve: .easeInOut,
      animations: {
        self.updateShape()
        self.updateColor(isOn)
        self.thumbView.snp.updateConstraints { make in
          make.centerX.equalTo(centerX).priority(.required)
        }
        self.layoutSubviews()
        self.barView.layoutSubviews()
      }
    )
    self.animator?.startAnimation()
  }

  func updateShape() {
    self.barView.layer.cornerRadius = self.barView.frame.height / 2
    self.thumbView.layer.cornerRadius = self.thumbView.frame.height / 2
  }

  func updateColor(_ isOn: Bool) {
    if isOn {
      self.barView.backgroundColor = self.onTintColor.bar
      self.thumbView.backgroundColor = self.onTintColor.thumb
    } else {
      self.barView.backgroundColor = self.offTintColor.bar
      self.thumbView.backgroundColor = self.offTintColor.thumb
    }
  }
}
