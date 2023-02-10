//
//  AppStepper.swift
//  Favor
//
//  Created by 이창준 on 2023/01/27.
//

import RxCocoa
import RxFlow
import RxSwift

final class AppStepper: Stepper {
  
  // MARK: - Properties
  
  let steps = PublishRelay<Step>()
  private let disposeBag = DisposeBag()
  
  var initialStep: Step {
    // TODO: State에 따라서 Step 변경
    return AppStep.onboardingIsRequired
  }
}
