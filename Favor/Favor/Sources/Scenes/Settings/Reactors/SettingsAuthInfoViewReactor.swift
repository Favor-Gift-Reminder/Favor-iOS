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
    case signOutButtonDidTap
    case deleteAccountDidTap
  }

  public enum Mutation {

  }

  public struct State {

  }

  // MARK: - Initializer

  init(keychain: KeychainManager) {
    self.keychain = keychain
    self.initialState = State()
  }

  // MARK: - Functions

  public func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .signOutButtonDidTap:
      self.handleSignOut()
      return .empty()

    case .deleteAccountDidTap:
      return self.handleDeleteAccount()
        .asObservable()
        .flatMap { _ -> Observable<Mutation> in
          self.handleSignOut()
          return .empty()
        }
        .catch { error in
          if let error = error as? APIError {
            os_log(.error, "\(error.description)")
          } else if let error = error as? KeychainManager.KeychainError {
            os_log(.error, "\(error)")
          }
          return .error(error)
        }
    }
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
      let disposable = networking.request(.deleteUser(userNo: UserInfoStorage.userNo))
        .take(1)
        .asSingle()
        .subscribe(onSuccess: { response in
          do {
            let responseDTO: ResponseDTO<UserResponseDTO> = try APIManager.decode(response.data)
            single(.success(User(dto: responseDTO.data)))
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
