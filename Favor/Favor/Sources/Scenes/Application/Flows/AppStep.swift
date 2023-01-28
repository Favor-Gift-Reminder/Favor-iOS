//
//  AppStep.swift
//  Favor
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import RxFlow

enum AppStep: Step {
  case homeIsRequired
  case onboardingIsRequired
  case authIsRequired
  case mainIsRequired
}
