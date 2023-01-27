//
//  AppStepper.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import RxCocoa
import RxFlow
import RxSwift

class AppStepper: Stepper {
  
  // MARK: - Properties
  
  let steps = PublishRelay<Step>()
  private let disposeBag = DisposeBag()
  
  var initialStep: Step {
    FavorStep.signInIsRequired
  }
  
  // MARK: - Initializer
  
  init() { }
  
  // MARK: - Functions
  
  func readyToEmitSteps() {
    //
  }
  
}
