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
  // MARK: - Root
  case splashIsRequired
  case splashIsComplete
  
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
  case localAuthIsRequired(LocalAuthRequest)
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
  case reminderIsComplete
  case newReminderIsRequired
  case reminderDetailIsRequired(Reminder)
  case reminderEditIsRequired(Reminder)
  case reminderEditIsComplete(ToastMessage)
  
  // MARK: - MyPage
  case myPageIsRequired
  case editMyPageIsRequired(User)
  case editMyPageIsComplete
  
  // MARK: - FriendList
  case friendListIsRequired
  case editFriendIsRequired
  case friendListIsComplete
  
  // MARK: - FriendSelector
  case friendSelectorIsRequired([Friend] = [], viewType: FriendSelectorViewReactor.ViewType)
  case friendSelectorIsComplete([Friend])
  
  // MARK: - FriendPage
  case friendManagementIsRequired(FriendManagementViewController.ViewControllerType)
  case friendManagementIsComplete(String)
  case friendPageIsRequired(Friend)
  
  // MARK: - AnniversaryList
  case anniversaryListIsRequired(AnniversaryListType)
  case anniversaryListIsComplete
  case editAnniversaryListIsRequired([Anniversary])
  case newAnniversaryIsRequired
  case anniversaryManagementIsRequired(Anniversary)
  case anniversaryManagementIsComplete(ToastMessage)
  
  // MARK: - Gift
  case giftDetailIsRequired(Gift)
  case giftDetailFriendsBottomSheetIsRequired([Friend])
  case giftDetailIsComplete(Gift)
  case giftDetailPhotoIsRequired(Int, Int)
  case giftShareIsRequired(Gift)
  
  // MARK: - GiftManagement
  case giftManagementIsRequired(Gift? = nil)
  case giftManagementIsCompleteWithNoChanges
  case newGiftIsComplete
  case editGiftIsComplete(Gift)

  // MARK: - Settings
  case settingsIsRequired
  case authInfoIsRequired // 로그인 정보
  // 비밀번호 변경 (newPasswordIsRequired)
  case appPrivacyIsRequired // 앱 잠금
  case devTeamInfoIsRequired // 팀
  case devTeamSupportIsRequired // 개발자 응원하기
  case serviceUsageTermIsRequired // 서비스 이용약관
  case privateInfoManagementTermIsRequired // 개인정보 처리방침
  case openSourceUsageIsRequired // 오픈소스 라이선스
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
  
  // MARK: - ImagePicker
  case imagePickerIsRequired(PHPickerManager, selectionLimit: Int)
  case imagePickerIsComplete

  // MARK: - Placeholder
  case doNothing
}
