//
//  AppStep.swift
//  Favor
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import FavorKit
import RxFlow

enum AppStep: Step {
  case imagePickerIsRequired(PHPickerManager)

  // MARK: - Root
  case rootIsRequired

  // MARK: - Auth
  case authIsRequired
  case findPasswordIsRequired
  case validateEmailCodeIsRequired(String)
  case newPasswordIsRequired
  case signUpIsRequired
  case signInIsRequired
  case setProfileIsRequired
  case termIsRequired(String)
  
  // MARK: - Onboarding
  case onboardingIsRequired
  case onboardingIsComplete
  
  // MARK: - Main
  case tabBarIsRequired
  
  // MARK: - Home
  case homeIsRequired
  case filterIsRequired
  
  // MARK: - Search
  case searchIsRequired
  case searchResultIsRequired

  // MARK: - Reminder
  case reminderIsRequired
  
  // MARK: - MyPage
  case myPageIsRequired
  case editMyPageIsRequired
  
  // MARK: - Test
  case testIsRequired
}
