//
//  ReminderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import Foundation
import OSLog
import UIKit.UIImage

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderViewReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  private let workbench = RealmWorkbench()
  private let reminderFetcher = Fetcher<Reminder>()
  
  enum Action {
    case viewNeedsLoaded
    case selectedDateDidChange(DateComponents)
    case reminderDidSelected(ReminderSection.ReminderSectionItem)
    case newReminderButtonDidTap
  }

  enum Mutation {
    case updateSelectedDate(DateComponents)
    case updateIsReminderEmpty(Bool)
    case updateUpcoming(ReminderSection.ReminderSectionModel)
    case updatePast(ReminderSection.ReminderSectionModel)
    case updateLoading(Bool)
  }

  struct State {
    var selectedDate: DateComponents = DateComponents(
      year: Int(Date().toYearString()),
      month: Int(Date().toMonthString())
    )
    var isReminderEmpty: Bool = true
    var upcomingSection = ReminderSection.ReminderSectionModel(
      model: .upcoming,
      items: []
    )
    var pastSection = ReminderSection.ReminderSectionModel(
      model: .past,
      items: []
    )
    var isLoading: Bool = false
  }

  // MARK: - Initializer

  init() {
    self.initialState = State()
    self.setupReminderFetcher()
  }

  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.reminderFetcher.fetch()
        .flatMap { (status, reminders) -> Observable<Mutation> in
          let filteredReminders = reminders.filter {
            let isYearMatch = $0.date.currentYear == self.currentState.selectedDate.year
            let isMonthMatch = $0.date.currentMonth == self.currentState.selectedDate.month
            return isYearMatch && isMonthMatch
          }
          let (upcomingSection, pastSection) = self.extractUpcoming(from: filteredReminders)
          return .concat([
            .just(.updateUpcoming(upcomingSection)),
            .just(.updatePast(pastSection)),
            .just(.updateLoading(status == .inProgress)),
            .just(.updateIsReminderEmpty(
              upcomingSection.items.isEmpty && pastSection.items.isEmpty
            ))
          ])
        }

    case .selectedDateDidChange(let selectedDate):
      return .just(.updateSelectedDate(selectedDate))
      
    case .reminderDidSelected(let item):
      switch item {
      case .reminder(let reactor):
        self.steps.accept(AppStep.reminderDetailIsRequired(reactor.currentState.reminderData))
      }
      return .empty()

    case .newReminderButtonDidTap:
      os_log(.debug, "New Reminder button did tap.")
      self.steps.accept(AppStep.newReminderIsRequired)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateIsReminderEmpty(let isReminderEmpty):
      newState.isReminderEmpty = isReminderEmpty

    case .updateUpcoming(let upcomingSection):
      newState.upcomingSection = upcomingSection

    case .updatePast(let pastSection):
      newState.pastSection = pastSection

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .updateSelectedDate(let selectedDate):
      newState.selectedDate = selectedDate
    }

    return newState
  }
}

// MARK: - Fetcher

private extension ReminderViewReactor {
  func setupReminderFetcher() {
    // onRemote
    self.reminderFetcher.onRemote = {
      let networking =  UserNetworking()
      let reminders = networking.request(.getAllReminderList)
        .flatMap { reminders -> Observable<[Reminder]> in
          let responseData = reminders.data
          do {
            let responseDTO: ResponseDTO<[ReminderResponseDTO]> = try APIManager.decode(responseData)
            return .just(responseDTO.data.map { Reminder(singleDTO: $0) })
          } catch {
            return .just([])
          }
        }
        .asSingle()
      return reminders
    }
    // onLocal
    self.reminderFetcher.onLocal = {
      return await self.workbench.values(ReminderObject.self)
        .map { Reminder(realmObject: $0) }
    }
    // onLocalUpdate
    self.reminderFetcher.onLocalUpdate = { _, remoteReminders in
      try await self.workbench.write { transaction in
        transaction.update(remoteReminders.map { $0.realmObject() })
      }
    }
  }
}

// MARK: - Privates

private extension ReminderViewReactor {
  func extractUpcoming(
    from reminders: [Reminder]
  ) -> (ReminderSection.ReminderSectionModel, ReminderSection.ReminderSectionModel) {
    let (upcomingReminders, pastReminders) = reminders.sort()
    
    let upcomingItems = upcomingReminders.map { data in
      let reactor = ReminderCellReactor(reminder: data)
      return ReminderSection.ReminderSectionItem.reminder(reactor)
    }
    let pastItems = pastReminders.map { data in
      let reactor = ReminderCellReactor(reminder: data)
      return ReminderSection.ReminderSectionItem.reminder(reactor)
    }

    let upcomingSection = ReminderSection.ReminderSectionModel(
      model: .upcoming,
      items: upcomingItems
    )
    let pastSection = ReminderSection.ReminderSectionModel(
      model: .past,
      items: pastItems
    )

    return (upcomingSection, pastSection)
  }
}
