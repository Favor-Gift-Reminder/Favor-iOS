//
//  AppStep.swift
//  Favor
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import RxFlow

enum AppStep: Step {
  // MARK: - Auth
  case authIsRequired
  case authIsComplete
  case signUpIsRequired
  case signInIsRequired
  case setProfileIsRequired
  case termIsRequired
  
  // MARK: - Onboarding
  case onboardingIsRequired
  case onboardingIsComplete
  
  // MARK: - Main
  case dashBoardIsRequired
  
  // MARK: - Home
  case homeIsRequired
  
  // MARK: - Search
  case searchIsRequired
  case searchResultIsRequired
  
  // MARK: - Test
  case testIsRequired
}
