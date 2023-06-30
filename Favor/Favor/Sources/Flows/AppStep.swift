//
//  AppStep.swift
//  Favor
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import FavorKit
import RxFlow

public enum AppStep: Step {
  case imagePickerIsRequired(PHPickerManager)

  // MARK: - Root
  case splashIsRequired

  // MARK: - Onboarding
  case onboardingIsRequired
  case onboardingIsComplete

  // MARK: - Auth
  case authIsRequired
  case findPasswordIsRequired
  case validateEmailCodeIsRequired(String)
  case newPasswordIsRequired
  case newPasswordIsComplete
  case signUpIsRequired
  case signInIsRequired
  case setProfileIsRequired(User)
  case termIsRequired(User)
  case authIsComplete

  // MARK: - Local Auth
  case localAuthIsRequired(LocalAuthLocation)
  case localAuthIsComplete

  // MARK: - Main
  case dashboardIsRequired
  
  // MARK: - Home
  case homeIsRequired
  
  // MARK: - Search
  case searchIsRequired
  case searchIsComplete
  case searchResultIsRequired(String)
  case searchResultIsComplete
  case searchCategoryResultIsRequired(FavorCategory)
  case searchEmotionResultIsRequired(FavorEmotion)

  // MARK: - Reminder
  case reminderIsRequired
  case newReminderIsRequired
  case newReminderIsComplete
  case reminderDetailIsRequired(Reminder)
  case reminderEditIsRequired(Reminder)
  case reminderIsComplete
  
  // MARK: - MyPage
  case myPageIsRequired
  case editMyPageIsRequired(User)
  case editMyPageIsComplete

  // MARK: - FriendList
  case friendListIsRequired
  case editFriendIsRequired
  case friendListIsComplete
  
  // MARK: - FriendPage
  case friendManagementIsRequired(FriendManagementViewController.ViewControllerType)
  case friendPageIsRequired(Friend)
  
  // MARK: - AnniversaryList
  case anniversaryListIsRequired(AnniversaryListType)
  case anniversaryListIsComplete
  case editAnniversaryListIsRequired([Anniversary])
  case newAnniversaryIsRequired
  case anniversaryManagementIsRequired(Anniversary)
  case anniversaryManagementIsComplete(ToastMessage)

  // MARK: - Gift
  case giftManagementIsRequired(Gift? = nil)
  case giftManagementIsCompleteWithNoChanges
  case newGiftIsComplete(Gift)
  case editGiftIsComplete(Gift)
  case newGiftFriendIsRequired
  case giftDetailIsRequired(Gift)
  case giftDetailFriendsBottomSheetIsRequired([Friend])
  case giftDetailIsComplete(Gift)
  case giftDetailPhotoIsRequired(Int, Int)
  case giftShareIsRequired(Gift)

  // MARK: - Settings

  case settingsIsRequired
  case authInfoIsRequired
  case devTeamInfoIsRequired
  case devTeamSupportIsRequired
  case serviceUsageTermIsRequired
  case privateInfoManagementTermIsRequired
  case openSourceUsageIsRequired
  case wayBackToRootIsRequired

  // MARK: - BottomSheet
  case memoBottomSheetIsRequired(String?)
  case memoBottomSheetIsComplete(String?)
  case filterBottomSheetIsRequired(SortType)
  case filterBottomSheetIsComplete(SortType)
  case anniversaryBottomSheetIsRequired(AnniversaryCategory?)
  case anniversaryBottomSheetIsComplete(AnniversaryCategory)
  
  // MARK: - Popup
  case alertPopupIsRequired(AlertPopup.PopupType)
  case alertPopupIsComplete(isConfirmed: Bool)

  // MARK: - Placeholder
  case doNothing
}
