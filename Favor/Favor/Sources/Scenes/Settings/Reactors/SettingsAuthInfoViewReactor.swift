//
//  SettingsAuthInfoViewReactor.swift
//  Favor
//
//  Created by 이창준 on 6/29/23.
//

import OSLog

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

public final class SettingsAuthInfoViewReactor: Reactor, Stepper {

  // MARK: - Properties

  public var initialState: State
  public let steps = PublishRelay<Step>()
  private var keychain: KeychainManager

  public enum Action {
    case signoutButtonDidTap
    case deleteAccountDidTap
    case signoutDidRequested
    case deleteAccountDidRequested
  }

  public enum Mutation {
    case pulseSignout
    case pulseDeleteAccount
  }

  public struct State {
    @Pulse var signoutPulse: Bool = false
    @Pulse var deleteAccountPulse: Bool = false
  }

  // MARK: - Initializer

  init(keychain: KeychainManager) {
    self.keychain = keychain
    self.initialState = State()
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .signoutButtonDidTap:
      return .just(.pulseSignout)

    case .deleteAccountDidTap:
      return .just(.pulseDeleteAccount)

    case .signoutDidRequested:
      self.handleSignOut()
      return .empty()

    case .deleteAccountDidRequested:
      return self.handleDeleteAccount()
        .asObservable()
        .flatMap { _ -> Observable<Mutation> in
          self.handleSignOut()
          return .empty()
        }
        .catch { error in
          return .error(error)
        }
    }
  }

  public func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .pulseSignout:
      newState.signoutPulse = true

    case .pulseDeleteAccount:
      newState.deleteAccountPulse = true
    }

    return newState
  }
}

// MARK: - Privates

private extension SettingsAuthInfoViewReactor {
  func handleSignOut() {
    FTUXStorage.authState = .undefined
    UserInfoStorage.userNo = -1
    do {
      try self.keychain.deleteAll()
    } catch {
      os_log(.error, "\(error)")
    }
    self.steps.accept(AppStep.wayBackToRootIsRequired)
  }

  func handleDeleteAccount() -> Single<User> {
    return Single<User>.create { single in
      let networking = UserNetworking()
      let disposable = networking.request(.deleteUser)
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<UserSingleResponseDTO> = try APIManager.decode(response.data)
            single(.success(User(singleDTO: responseDTO.data)))
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
