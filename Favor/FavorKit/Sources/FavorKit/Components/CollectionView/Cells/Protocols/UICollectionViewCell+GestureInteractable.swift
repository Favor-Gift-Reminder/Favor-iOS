//
//  UICollectionViewCell+GestureInteractable.swift
//  Favor
//
//  Created by 이창준 on 2023/05/11.
//

import UIKit

import RxSwift

public protocol GestureInteractable: AnyObject where Self: UICollectionViewCell {

  // MARK: - Properties

  var disposeBag: DisposeBag { get set }

  // MARK: - UI Components

  var containerView: UIView { get set }
}
