//
//  ReminderEditViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/02.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderEditViewReactor: Reactor, Stepper {
  
  // MARK: - Constatns
  
  public enum EditType {
    case edit, new
  }
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  let networking = ReminderNetworking()
  let workBranch = RealmWorkbench()
  
  enum Action {
    case viewDidLoad
    case friendSelectorButtonDidTap
    case doneButtonDidTap
    case titleTextFieldDidUpdate(String)
    case memoTextViewDidUpdate(String)
    case datePickerDidUpdate(Date?)
    case notifyTimePickerDidUpdate(Date?)
    case notifySwitchDidToggle(Bool)
    case notifyDateDidUpdate(NotifyDays)
    case friendDidChange(Friend)
  }
  
  enum Mutation {
    case updateReminderDate(Date?)
    case updateNotifyTime(Date?)
    case updateNotifyDay(NotifyDays)
    case updateTitle(String)
    case updateFriend(Friend)
    case updateMemo(String)
    case updateShouldNotify(Bool)
    case updateLoading(Bool)
  }
  
  struct State {
    var type: EditType
    var reminder: Reminder
    var isEnabledDoneButton: Bool = false
    var currentFriend: Friend?
    var currentTitle: String = ""
    var currentDate: Date?
    var currentAlarmTime: Date?
    var currentNotifyDay: NotifyDays?
    var currentMemo: String = ""
    var shouldNotify: Bool = false
    var isLoading: Bool = false
  }
  
  // MARK: - Initializer
  
  /// type이 `.edit`일 경우 사용합니다.
  init(_ type: EditType = .edit, reminder: Reminder) {
    // TODO: 리마인더의 관련된 친구 객체를 넣어줘야합니다. (서버에 요청 중)
    self.initialState = State(
      type: type,
      reminder: reminder,
      currentTitle: reminder.name,
      currentDate: reminder.date,
      currentAlarmTime: reminder.notifyDate.toTimeString().toDate("a h시 mm분"),
      currentNotifyDay: reminder.date.toNotifyDays(reminder.notifyDate)
    )
  }
  
  /// type이 `.new`일 경우 사용합니다.
  init(_ type: EditType = .new) {
    self.initialState = State(
      type: type,
      reminder: Reminder()
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .merge(
        .just(.updateReminderDate(self.currentState.reminder.date)),
        .just(.updateNotifyTime(self.currentState.reminder.notifyDate))
      )
      
    case .friendSelectorButtonDidTap:
      self.steps.accept(AppStep.friendSelectorIsRequired([], viewType: .reminder))
      return .empty()
      
    case .doneButtonDidTap:
      return self.requestPostReminder()
        .flatMap { _ -> Observable<Mutation> in
          let message: ToastMessage = .reminderAdded
          // 현재 페이지를 종료합니다.
          self.steps.accept(AppStep.reminderEditIsComplete(message))
          return .empty()
        }
      
    case .datePickerDidUpdate(let date):
      return .just(.updateReminderDate(date))
      
    case .titleTextFieldDidUpdate(let title):
      return .just(.updateTitle(title))
      
    case .memoTextViewDidUpdate(let memo):
      return .just(.updateMemo(memo))

    case .notifyTimePickerDidUpdate(let date):
      return .just(.updateNotifyTime(date))
      
    case .notifyDateDidUpdate(let notifyDay):
      return .just(.updateNotifyDay(notifyDay))

    case .notifySwitchDidToggle(let isOn):
      return .just(.updateShouldNotify(isOn))
      
    case .friendDidChange(let friend):
      return .just(.updateFriend(friend))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateReminderDate(let date):
      newState.reminder.notifyDate = date ?? .distantPast
      newState.currentDate = date

    case .updateMemo(let memo):
      newState.reminder.memo = memo
      newState.currentMemo = memo
      
    case .updateTitle(let title):
      newState.reminder.name = title
      newState.currentTitle = title
      
    case .updateFriend(let friend):
      newState.currentFriend = friend
      
    case .updateNotifyTime(let time):
      newState.currentAlarmTime = time
      
    case .updateNotifyDay(let notifyDay):
      newState.currentNotifyDay = notifyDay
      
    case .updateShouldNotify(let shouldNotify):
      newState.reminder.shouldNotify = shouldNotify
      newState.shouldNotify = shouldNotify
      
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      if
        state.currentDate != nil,
        state.currentAlarmTime != nil,
        state.currentNotifyDay != nil,
        !state.currentTitle.isEmpty,
        state.currentFriend != nil
      {
        newState.isEnabledDoneButton = true
      } else {
        newState.isEnabledDoneButton = false
      }
      
      return newState
    }
  }
}

// MARK: - Network

private extension ReminderEditViewReactor {
  func requestPostReminder() -> Observable<Void> {
    guard let notifyDay = self.currentState.currentNotifyDay,
          let time = self.currentState.currentAlarmTime,
          let date = self.currentState.currentDate,
          let friend = self.currentState.currentFriend
    else { return .empty() }
    let alarmString = notifyDay.toAlarmDate(date) + " " + time.toDTOTimeString()
    let networking = ReminderNetworking()
    
    let requestDTO = ReminderRequestDTO(
      title: self.currentState.currentTitle,
      reminderDate: date.toDTODateString(),
      isAlarmSet: self.currentState.shouldNotify,
      alarmTime: alarmString,
      reminderMemo: self.currentState.currentMemo
    )
    
    return Observable<Void>.create { observer in
      return networking.request(.postReminder(requestDTO, friendNo: friend.identifier))
        .map(ResponseDTO<ReminderSingleResponseDTO>.self)
        .map { Reminder(singleDTO: $0.data) }
        .subscribe { reminder in
          Task {
            try await self.workBranch.write { transaction in
              transaction.update(reminder.realmObject())
              observer.onNext(())
              observer.onCompleted()
            }
          }
        }
    }
  }
}
