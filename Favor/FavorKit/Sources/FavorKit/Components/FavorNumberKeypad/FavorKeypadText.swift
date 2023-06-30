//
//  FavorKeypadText.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import UIKit

import SnapKit

public final class FavorKeypadText: UIView {

  // MARK: - Constants

  private enum Metric {
    static let size: CGFloat = 30.0
    static let imageViewSize: CGFloat = 10.0
  }

  // MARK: - UI Components

  private let hiddenImageView: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: "circle.fill")?
      .resize(newWidth: Metric.imageViewSize)
      .withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.contentInsets = .zero

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.divider)
      case .selected:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    button.isUserInteractionEnabled = false
    button.contentMode = .center
    return button
  }()

  private let numberLabel: UILabel = {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 24)
    label.textColor = .favorColor(.icon)
    label.textAlignment = .center
    return label
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

  public func updateText(with input: KeypadInput) {
    self.hiddenImageView.isHidden = input.isLastInput
    self.numberLabel.isHidden = !input.isLastInput
    self.hiddenImageView.isSelected = input.data != nil
    self.numberLabel.text = "\(input.data ?? -1)"
  }
}

extension FavorKeypadText: BaseView {
  public func setupStyles() { }

  public func setupLayouts() {
    [
      self.hiddenImageView,
      self.numberLabel
    ].forEach {
      self.addSubview($0)
    }
  }

  public func setupConstraints() {
    self.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.size)
    }

    self.hiddenImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(Metric.imageViewSize)
    }

    self.numberLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
