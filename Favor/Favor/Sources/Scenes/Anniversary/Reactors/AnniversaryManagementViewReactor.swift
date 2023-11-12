//
//  AnniversaryManagementViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/18.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class AnniversaryManagementViewReactor: Reactor, Stepper {
  typealias Section = AnniversaryManagementSection
  typealias Item = AnniversaryManagementSectionItem

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  private let workBench = RealmWorkbench()

  enum Action {
    case doneButtonDidTap
    case nameDidUpdate(String?)
    case categoryDidUpdate(AnniversaryCategory)
    case dateDidUpdate(Date?)
    case deleteButtonDidTap
  }
  
  enum Mutation {
    case updateAnniversary(Anniversary)
    case updateAnniversaryDate(Date?)
  }
  
  struct State {
    var viewType: AnniversaryManagementViewController.ViewType
    var anniversary: Anniversary
    var anniversaryDate: Date?
    var anniversaryCategory: AnniversaryCategory?
    var sections: [Section] = [.name, .category, .date]
    var items: [Item]
    var isDoneButtonEnabled: Bool = false
  }

  // MARK: - Initializer
  
  /// ViewType이 `.edit`일 경우 사용되는 생성자
  init(with anniversary: Anniversary) {
    self.initialState = State(
      viewType: .edit,
      anniversary: anniversary,
      anniversaryDate: anniversary.date,
      anniversaryCategory: anniversary.category,
      items: [.name(anniversary.name), .category(anniversary.category), .date(anniversary.date)]
    )
  }
  
  /// ViewType이 `.new`일 경우 사용되는 생성자
  init() {
    self.initialState = State(
      viewType: .new,
      anniversary: Anniversary(),
      items: [.name(nil), .category(.birth), .date(nil)]
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    var anniversary = self.currentState.anniversary
    switch action {
    case .doneButtonDidTap:
      switch self.currentState.viewType {
      case .new:
        return self.requestNewAnniversary(with: self.currentState.anniversary)
          .flatMap { (anniversary: Anniversary) -> Observable<Mutation> in
            let message: ToastMessage = .anniversaryAdded(anniversary.name)
            self.steps.accept(AppStep.anniversaryManagementIsComplete(message))
            return .empty()
          }
          .catch { error in
            if let favorError = error as? FavorError {
              os_log(.error, "\(favorError.description)")
            } else {
              os_log(.error, "\(error.localizedDescription)")
            }
            return .empty()
          }
      case .edit:
        return self.requestPatchAnniversary(self.currentState.anniversary)
          .asObservable()
          .flatMap { (anniversary: Anniversary) -> Observable<Mutation> in
            let message: ToastMessage = .anniversaryModifed(anniversary.name)
            self.steps.accept(AppStep.anniversaryManagementIsComplete(message))
            return .empty()
          }
          .catch { error in
            os_log(.error, "\(error.localizedDescription)")
            return .empty()
          }
      }
      
    case .nameDidUpdate(let name):
      anniversary.name = name ?? ""
      return .just(.updateAnniversary(anniversary))
      
    case .categoryDidUpdate(let category):
      anniversary.category = category
      return .just(.updateAnniversary(anniversary))

    case .dateDidUpdate(let date):
      return .just(.updateAnniversaryDate(date))
      
    case .deleteButtonDidTap:
      return self.requestDeleteAnniversary(self.currentState.anniversary.identifier)
        .asObservable()
        .flatMap { _ -> Observable<Mutation> in
          let message: ToastMessage = .anniversaryDeleted(self.currentState.anniversary.name)
          self.steps.accept(AppStep.anniversaryManagementIsComplete(message))
          return .empty()
        }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateAnniversary(let anniversary):
      newState.anniversary = anniversary

    case .updateAnniversaryDate(let date):
      newState.anniversaryDate = date
      if let date {
        newState.anniversary.date = date
      }
    }

    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      let isTitleEmpty = state.anniversary.name.isEmpty
      
      newState.isDoneButtonEnabled = !isTitleEmpty && state.anniversaryDate != nil
      newState.items[1] = .category(state.anniversary.category)

      return newState
    }
  }
}

// MARK: - Privates

private extension AnniversaryManagementViewReactor {
  func requestNewAnniversary(with anniversary: Anniversary) -> Observable<Anniversary> {
    return Observable<Anniversary>.create { observer in
      let networking = AnniversaryNetworking()
      let requestDTO = anniversary.requestDTO()
      
      return networking.request(.postAnniversary(requestDTO))
        .map(ResponseDTO<AnniversarySingleResponseDTO>.self)
        .map { Anniversary(singleDTO: $0.data) }
        .subscribe { anniversary in
          Task {
            try await self.workBench.write { transaction in
              transaction.update(anniversary.realmObject())
              observer.onNext(anniversary)
              observer.onCompleted()
            }
          }
        }
    }
  }
  
  func requestPatchAnniversary(_ anniversary: Anniversary) -> Single<Anniversary> {
    return Single<Anniversary>.create { single in
      let networking = AnniversaryNetworking()
      let requestDTO = AnniversaryUpdateRequestDTO(
        anniversaryTitle: anniversary.name,
        anniversaryDate: anniversary.date.toDTODateString(),
        category: anniversary.category.rawValue,
        isPinned: anniversary.isPinned
      )
      return networking.request(.patchAnniversary(requestDTO, anniversaryNo: anniversary.identifier))
        .asSingle()
        .map(ResponseDTO<AnniversarySingleResponseDTO>.self)
        .map { Anniversary(singleDTO: $0.data) }
        .subscribe(onSuccess: { anniversary in
          Task {
            try await self.workBench.write { transaction in
              transaction.update(anniversary.realmObject())
              DispatchQueue.main.async {
                single(.success(anniversary))
              }
            }
          }
        }, onFailure: { error in
          single(.failure(error))
        })
    }
  }
  
  func requestDeleteAnniversary(_ anniversaryNo: Int) -> Single<Void> {
    return Single<Void>.create { single in
      let networking = AnniversaryNetworking()
      return networking.request(.deleteAnniversary(anniversaryNo: anniversaryNo))
        .asSingle()
        .subscribe(onSuccess: { anniversary in
          Task {
            try await self.workBench.write { transaction in
              transaction.delete(self.currentState.anniversary.realmObject())
              DispatchQueue.main.async {
                single(.success(()))
              }
            }
          }
        }, onFailure: { error in
          single(.failure(error))
        })
    }
  }
}
