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

  enum Action {
    case doneButtonDidTap
    case titleDidUpdate(String?)
    case categoryDidUpdate(String?)
    case dateDidUpdate(Date?)
    case deleteButtonDidTap
  }

  enum Mutation {
    case updateAnniversaryTitle(String?)
    case updateAnniversaryCategory(String)
    case updateAnniversaryDate(Date?)
  }

  struct State {
    var viewType: AnniversaryManagementViewController.ViewType
    var anniversaryNo: Int?
    var anniversaryTitle: String?
    var anniversaryCategory: String?
    var anniversaryDate: Date?
    var anniversaryIsPinned: Bool = false
    var sections: [Section] = [.name, .category, .date]
    var items: [Item]
    var isDoneButtonEnabled: Bool = false
  }

  // MARK: - Initializer

  /// ViewType이 `.edit`일 경우 사용되는 생성자
  init(with anniversary: Anniversary) {
    self.initialState = State(
      viewType: .edit,
      anniversaryNo: anniversary.anniversaryNo,
      anniversaryTitle: anniversary.title,
      anniversaryCategory: "생일/축하",
      anniversaryDate: anniversary.date,
      anniversaryIsPinned: anniversary.isPinned,
      items: [.name(anniversary.title), .category, .date(anniversary.date)]
    )
  }

  /// ViewType이 `.new`일 경우 사용되는 생성자
  init() {
    self.initialState = State(
      viewType: .new,
      items: [.name(nil), .category, .date(nil)]
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .doneButtonDidTap:
      switch self.currentState.viewType {
      case .new:
        return self.requestNewAnniversary()
          .asObservable()
          .flatMap { (anniversary: Anniversary) -> Observable<Mutation> in
            let message: ToastMessage = .anniversaryAdded(anniversary.title)
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
        guard let anniversaryNo = self.currentState.anniversaryNo else { return .empty() }
        let anniversary = Anniversary(
          anniversaryNo: anniversaryNo,
          title: self.currentState.anniversaryTitle ?? "",
          date: self.currentState.anniversaryDate ?? .distantPast,
          isPinned: self.currentState.anniversaryIsPinned
        )
        return self.requestPatchAnniversary(anniversary)
          .asObservable()
          .flatMap { (anniversary: Anniversary) -> Observable<Mutation> in
            let message: ToastMessage = .anniversaryModifed(anniversary.title)
            self.steps.accept(AppStep.anniversaryManagementIsComplete(message))
            return .empty()
          }
          .catch { error in
            os_log(.error, "\(error.localizedDescription)")
            return .empty()
          }
      }

    case .titleDidUpdate(let title):
      return .just(.updateAnniversaryTitle(title))

    case .categoryDidUpdate(let category):
      return .just(.updateAnniversaryCategory(category ?? ""))

    case .dateDidUpdate(let date):
      return .just(.updateAnniversaryDate(date))

    case .deleteButtonDidTap:
      guard let anniversaryNo = self.currentState.anniversaryNo else { return .empty() }
      return self.requestDeleteAnniversary(anniversaryNo)
        .asObservable()
        .flatMap { (anniversary: Anniversary) -> Observable<Mutation> in
          let message: ToastMessage = .anniversaryDeleted(anniversary.title)
          self.steps.accept(AppStep.anniversaryManagementIsComplete(message))
          return .empty()
        }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateAnniversaryTitle(let title):
      newState.anniversaryTitle = title

    case .updateAnniversaryCategory(let category):
      newState.anniversaryCategory = category

    case .updateAnniversaryDate(let date):
      newState.anniversaryDate = date
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      let isTitleEmpty = (state.anniversaryTitle ?? "").isEmpty
      newState.isDoneButtonEnabled = !isTitleEmpty && state.anniversaryDate != nil
      
      return newState
    }
  }
}

// MARK: - Privates

private extension AnniversaryManagementViewReactor {
  func requestNewAnniversary() -> Single<Anniversary> {
    return Single<Anniversary>.create { single in
      guard let title = self.currentState.anniversaryTitle else {
        single(.failure(FavorError.optionalBindingFailure(self.currentState.anniversaryTitle)))
        return Disposables.create()
      }
      guard let date = self.currentState.anniversaryDate else {
        single(.failure(FavorError.optionalBindingFailure(self.currentState.anniversaryDate)))
        return Disposables.create()
      }

      let networking = AnniversaryNetworking()
      let requestDTO = AnniversaryRequestDTO(anniversaryTitle: title, anniversaryDate: date.toDTODateString())

      let disposable = networking.request(.postAnniversary(requestDTO, userNo: UserInfoStorage.userNo))
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<AnniversaryResponseDTO> = try APIManager.decode(response.data)
            let anniversary = responseDTO.data.toDomain()
            single(.success(anniversary))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }

  func requestPatchAnniversary(_ anniversary: Anniversary) -> Single<Anniversary> {
    return Single<Anniversary>.create { single in
      let networking = AnniversaryNetworking()
      let requestDTO = AnniversaryUpdateRequestDTO(
        anniversaryTitle: anniversary.title,
        anniversaryDate: anniversary.date.toDTODateString(),
        isPinned: anniversary.isPinned
      )
      let disposable = networking.request(.patchAnniversary(requestDTO, anniversaryNo: anniversary.anniversaryNo))
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<AnniversaryResponseDTO> = try APIManager.decode(response.data)
            let anniversary = responseDTO.data.toDomain()
            single(.success(anniversary))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }

  func requestDeleteAnniversary(_ anniversaryNo: Int) -> Single<Anniversary> {
    return Single<Anniversary>.create { single in
      let networking = AnniversaryNetworking()
      let disposable = networking.request(.deleteAnniversary(anniversaryNo: anniversaryNo))
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<AnniversaryResponseDTO> = try APIManager.decode(response.data)
            let anniversary = responseDTO.data.toDomain()
            single(.success(anniversary))
          } catch {
            single(.failure(error))
          }
        }, onFailure: { error in
          single(.failure(error))
        })

      return Disposables.create {
        disposable.dispose()
      }
    }
  }
}