//
//  ReminderDetailViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/04/06.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class ReminderDetailViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  private let fetcher = Fetcher<Reminder>()
  private var workBench = RealmWorkbench()

  enum Action {
    case viewNeedsLoaded
    case editButtonDidTap
    case deleteButtonDidTap
  }

  enum Mutation {
    case updateReminder(Reminder)
  }

  struct State {
    var reminder: Reminder
  }

  // MARK: - Initializer

  init(reminder: Reminder) {
    self.initialState = State(
      reminder: reminder
    )
    self.setupFetcher()
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      return self.fetcher.fetch()
        .compactMap { $0.results.first }
        .flatMap { reminder -> Observable<Mutation> in
          return .just(.updateReminder(reminder))
        }
      
    case .editButtonDidTap:
      self.steps.accept(AppStep.reminderEditIsRequired(self.currentState.reminder))
      return .empty()
      
    case .deleteButtonDidTap:
      return self.requestDeleteReminder()
        .flatMap { _ -> Observable<Mutation> in
          self.steps.accept(AppStep.reminderDetailIsComplete)
          return .empty()
        }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateReminder(let reminder):
      newState.reminder = reminder
    }
    
    return newState
  }
}

private extension ReminderDetailViewReactor {
  func setupFetcher() {
    self.fetcher.onRemote = {
      let networking = ReminderNetworking()
      return networking.request(.getReminder(reminderNo: self.currentState.reminder.identifier))
        .asSingle()
        .map(ResponseDTO<ReminderSingleResponseDTO>.self)
        .map { return [Reminder(singleDTO: $0.data)] }
    }
    self.fetcher.onLocal = {
      return await self.workBench.values(ReminderObject.self)
        .filter { $0.reminderNo == self.currentState.reminder.identifier }
        .map { Reminder(realmObject: $0) }
    }
    self.fetcher.onLocalUpdate = { _, remoteReminder in
      guard let reminder = remoteReminder.first else { return }
      try await self.workBench.write { transaction in
        transaction.update(reminder.realmObject())
      }
    }
  }
  
  func requestDeleteReminder() -> Observable<Void> {
    let reminder = self.currentState.reminder
    return Observable<Void>.create { observer in
      let networking = ReminderNetworking()
      return networking.request(.deleteReminder(reminderNo: reminder.identifier))
        .subscribe { _ in
          Task {
            try await self.workBench.write { transaction in
              transaction.delete(reminder.realmObject())
              observer.onNext(())
              observer.onCompleted()
            }
          }
        }
    }
  }
}
