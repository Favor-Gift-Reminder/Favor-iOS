//
//  AppStpper.swift
//  Favor
//
//  Created by 김응철 on 2023/02/02.
//

import Foundation

import RxCocoa
import RxFlow
import RxSwift

public final class AppStepper: Stepper {

  public let steps = PublishRelay<Step>()
  private let disposeBag = DisposeBag()
  
  public var initialStep: Step {
    return AppStep.splashIsRequired
  }
}
