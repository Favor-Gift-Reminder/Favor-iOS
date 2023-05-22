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
    case updateAnniversaryTitle(String)
    case updateAnniversaryCategory(String)
    case updateAnniversaryDate(Date)
  }

  struct State {
    var viewType: AnniversaryManagementViewController.ViewType
    var anniversaryTitle: String?
    var anniversaryCategory: String?
    var anniversaryDate: Date?
    var sections: [Section] = [.name, .category, .date]
    var items: [Item]
  }

  // MARK: - Initializer

  /// ViewType이 `.edit`일 경우 사용되는 생성자
  init(with anniversary: Anniversary) {
    self.initialState = State(
      viewType: .edit,
      anniversaryTitle: anniversary.title,
      anniversaryCategory: "생일/축하",
      anniversaryDate: anniversary.date,
      items: [.name(anniversary.title), .category, .date(anniversary.date)]
    )
  }

  /// ViewType이 `.new`일 경우 사용되는 생성자
  init() {
    self.initialState = State(
      viewType: .new,
      items: [.name(""), .category, .date(.now)]
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
            print(anniversary)
            // TODO: 성공 / 실패 여부에 따라 accept / not, accept시 데이터 넘겨 toast 메시지
            self.steps.accept(AppStep.anniversaryManagementIsComplete(anniversary))
            return .empty()
          }
      case .edit:
        return .empty()
      }

    case .titleDidUpdate(let title):
      return .just(.updateAnniversaryTitle(title ?? ""))

    case .categoryDidUpdate(let category):
      return .just(.updateAnniversaryCategory(category ?? ""))

    case .dateDidUpdate(let date):
      return .just(.updateAnniversaryDate(date ?? .distantPast))

    case .deleteButtonDidTap:
      os_log(.debug, "Delete button did tap.")
      return .empty()
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

      return Disposables.create {
        //
      }
    }
  }
}
