//
//  AuthStep.swift
//  Favor
//
//  Created by 이창준 on 2023/01/28.
//

import RxFlow

enum AuthStep: Step {
  case selectSignInIsRequired
  case signInIsRequired
  case signUpIsRequired
}
