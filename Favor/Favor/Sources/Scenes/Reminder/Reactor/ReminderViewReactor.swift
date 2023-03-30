//
//  ReminderViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/03/29.
//

import Foundation
import UIKit.UIImage
import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  let reminderFetcher = Fetcher<[Reminder]>()

  enum Action {
    case viewWillAppear
    case selectDateButtonDidTap
  }

  enum Mutation {
    case updateUpcoming(ReminderSection.ReminderSectionModel)
    case updatePast(ReminderSection.ReminderSectionModel)
    case updateLoading(Bool)
  }

  struct State {
    var selectedDate: DateComponents = DateComponents(
      year: Int(Date().toYearString()),
      month: Int(Date().toMonthString())
    )
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
    case .viewWillAppear:
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
            .just(.updateLoading(status == .inProgress))
          ])
        }

    case .selectDateButtonDidTap:
      os_log(.debug, "Select date button did tap.")
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateUpcoming(let upcomingSection):
      newState.upcomingSection = upcomingSection

    case .updatePast(let pastSection):
      newState.pastSection = pastSection

    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
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
      let reminders = networking.request(.getAllReminderList(userNo: 1)) // TODO: UserNo 변경
        .flatMap { reminders -> Observable<[Reminder]> in
          let responseData = reminders.data
          let remote: ResponseDTO<[ReminderResponseDTO.Reminder]> = APIManager.decode(responseData)
          return .just(remote.data.map {
            Reminder(
              reminderNo: $0.reminderNo,
              title: $0.title,
              date: $0.reminderDate.toDate() ?? .now,
              shouldNotify: $0.isAlarmSet,
              friendNo: $0.friendNo
            )
          })
        }
        .asSingle()
      return reminders
    }
    // onLocal
    self.reminderFetcher.onLocal = {
      let reminders = try await RealmManager.shared.read(Reminder.self)
      return await reminders.toArray()
    }
    // onLocalUpdate
    self.reminderFetcher.onLocalUpdate = { reminders in
      os_log(.debug, "💽 ♻️ LocalDB REFRESH: \(reminders)")
      try await RealmManager.shared.updateAll(reminders)
    }
  }
}

// MARK: - Privates

private extension ReminderViewReactor {
  func extractUpcoming(
    from reminders: [Reminder]
  ) -> (ReminderSection.ReminderSectionModel, ReminderSection.ReminderSectionModel) {
    var upcomingReminders: [CardCellData] = []
    var pastReminders: [CardCellData] = []

    reminders.enumerated().forEach { index, reminder in
      let cellData = CardCellData(
        iconImage: UIImage(named: "p\(index + 1)").flatMap { $0 },
        title: reminder.title,
        subtitle: reminder.date.formatted()
      )

      let reminderDateComponents = Calendar.current.dateComponents(
        [.year, .month, .day],
        from: reminder.date
      )
      let currentDateComponents = Calendar.current.dateComponents(
        [.year, .month, .day],
        from: .now
      )
      if reminderDateComponents >= currentDateComponents {
        upcomingReminders.append(cellData)
      } else {
        pastReminders.append(cellData)
      }
    }

    let upcomingItems = upcomingReminders.map { data in
      let reactor = ReminderCellReactor(cellData: data)
      return ReminderSection.ReminderSectionItem.reminder(reactor)
    }
    let pastItems = pastReminders.map { data in
      let reactor = ReminderCellReactor(cellData: data)
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

    print("Upcoming: \(upcomingSection)")
    print("Past: \(pastSection)")
    return (upcomingSection, pastSection)
  }
}
