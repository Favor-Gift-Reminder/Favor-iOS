//
//  FavorButton.swift
//
//
//  Created by 김응철 on 10/12/23.
//

import UIKit

import SnapKit

public class FavorButton: UIButton {
  
  // MARK: - UI Components
  
  private let bottomBorderLine: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.isHidden = true
    return view
  }()
  
  private let leftProfileView: FavorProfilePhotoView = {
    let view = FavorProfilePhotoView(.verySmall)
    view.baseBackgroundColor = .favorColor(.line3)
    view.isUserInteractionEnabled = false
    view.isHidden = true 
    return view
  }()
  
  // MARK: - Properties
  
  /// 버튼의 타이틀 `String`
  public var title: String = "" {
    willSet {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .center
      paragraphStyle.lineBreakStrategy = .hangulWordPriority
      self.configuration?.attributedTitle = AttributedString(
        newValue,
        attributes: .init([
          .font: self.font,
          .foregroundColor: self.baseForegroundColor,
          .paragraphStyle: paragraphStyle
        ])
      )
    }
  }
  
  public var emotion: FavorEmotion?
  
  /// 버튼의 `CornerRadius`
  public var cornerRadius: CGFloat = 0 {
    willSet { self.configuration?.background.cornerRadius = newValue }
  }
  
  /// 버튼의 `UIFont`
  public var font: UIFont = .favorFont(.bold, size: 20.0) {
    willSet { self.configuration?.attributedTitle?.font = newValue }
  }
  
  /// 버튼의 `BackgroundColor`
  public var baseBackgroundColor: UIColor? {
    willSet { self.configuration?.baseBackgroundColor = newValue }
  }
  
  /// 버튼의 `ForegroundColor`
  public var baseForegroundColor: UIColor? {
    willSet { self.configuration?.baseForegroundColor = newValue }
  }
  
  /// 버튼의 `EdgeInset`
  public var edgeInsets: NSDirectionalEdgeInsets = .zero {
    willSet { self.configuration?.contentInsets = newValue }
  }
  
  /// 버튼의 `ShadowOpacity`
  public var shadowOpacity: Float = 0 {
    willSet { self.layer.shadowOpacity = newValue }
  }
  
  /// 버튼의 `ShadowRadius`
  public var shadowRadius: CGFloat = 0 {
    willSet { self.layer.shadowRadius = newValue }
  }
  
  /// 버튼의 `ShadowOffset`
  public var shadowOffset: CGSize = .zero {
    willSet { self.layer.shadowOffset = newValue }
  }
  
  /// 버튼의 `SubTitle`
  public var subTitle: String = "" {
    willSet {
      self.configuration?.attributedSubtitle = AttributedString(
        newValue,
        attributes: .init([
          .font: self.subTitleFont,
          .foregroundColor: self.subTitleColor
        ])
      )
    }
  }
  
  /// 버튼의 `SubTitleFont`
  public var subTitleFont: UIFont? {
    willSet { self.configuration?.attributedSubtitle?.font = newValue }
  }
  
  /// 버튼의 `SubTitleColor`
  public var subTitleColor: UIColor? {
    willSet { self.configuration?.attributedSubtitle?.foregroundColor = newValue }
  }
  
  /// 버튼의 `title`과 `subTitle`사이의 `Padding`
  public var titlePadding: CGFloat = 0 {
    willSet { self.configuration?.titlePadding = newValue }
  }
  
  /// 버튼의 `UIImage`
  public var image: UIImage? {
    willSet { self.configuration?.image = newValue }
  }
  
  /// 버튼의 `title`과 `image`사이의 `Padding`
  public var imagePadding: CGFloat = 0 {
    willSet { self.configuration?.imagePadding = newValue }
  }
  
  /// 버튼의 `contentInset`
  public var contentInset: NSDirectionalEdgeInsets = .zero {
    willSet { self.configuration?.contentInsets = newValue }
  }
  
  /// 버튼의 `BottomBorderLine`
  public var isHiddenBottomBorderLine: Bool = true {
    willSet { self.bottomBorderLine.isHidden = newValue }
  }
  
  /// 이미지 크기 조절 할 수 있는 `CGFloat`
  public var imageSize: CGFloat = 0 {
    willSet { self.configuration?.image = self.configuration?.image?.resize(newWidth: newValue) }
  }
  
  /// 타이틀의 `Alignment`
  public var titleAlignment: UIButton.Configuration.TitleAlignment = .center {
    willSet { self.configuration?.titleAlignment = newValue }
  }
  
  /// 이미지의 `Placement`
  public var imagePlacement: NSDirectionalRectEdge = .leading {
    willSet { self.configuration?.imagePlacement = newValue }
  }
  
  /// 버튼의 `BorderWidth`
  public var borderWidth: CGFloat = 0.0 {
    willSet { self.configuration?.background.strokeWidth = newValue }
  }
  
  /// 버튼의 `BorderColor`
  public var borderColor: UIColor = .white {
    willSet { self.configuration?.background.strokeColor = newValue }
  }
  
  public var hasLeftPhotoView: Bool = false {
    willSet {
      self.leftProfileView.isHidden = !newValue
      if newValue {
        self.contentInset = .init(top: 8.5, leading: 34.0, bottom: 8.5, trailing: 12.0)
      }
    }
  }
  
  // MARK: - Init
  
  public init(_ title: String = "", image: UIImage? = nil) {
    self.title = title
    self.image = image
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.setupConfiguration()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.baseBackgroundColor = .white
    self.font = .favorFont(.bold, size: 20.0)
  }
  
  func setupLayouts() {
    [
      self.bottomBorderLine,
      self.leftProfileView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.bottomBorderLine.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(1.0)
    }
    
    self.leftProfileView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(12.0)
    }
  }
  
  /// 사용자의 정보를 토대로 `Configuration`을 업데이트합니다.
  private func setupConfiguration() {
    var config = UIButton.Configuration.filled()
    config.attributedTitle = AttributedString(self.title)
    config.image = self.image
    config.imagePlacement = .leading
    config.imagePadding = 6.0
    self.configuration = config
  }
  
  // MARK: - Update
  
  public func updateEmotion(_ emotion: FavorEmotion?, size: CGFloat) {
    self.emotion = emotion
    self.image = emotion?.image?.resize(newWidth: size)
  }
  
  public func updateProfileImage(_ mapper: CacheKeyMapper) {
    self.leftProfileView.updateProfileImage(mapper)
  }
}
