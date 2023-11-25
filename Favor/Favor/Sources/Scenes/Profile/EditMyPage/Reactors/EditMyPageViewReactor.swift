//
//  EditMyPageViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/22.
//

import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class EditMyPageViewReactor: Reactor, Stepper {

  // MARK: - Constants

  private enum Constant {
    static let numberOfFavors = 16
    static let maximumSelectedFavor = 5
  }

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()
  private let workBench = RealmWorkbench()
  private var pickerManager: PickerManager?

  enum Action {
    case viewNeedsLoaded
    case cancelButtonDidTap
    case doneButtonDidTap
    case profileHeaderDidTap(EditMyPageProfileHeader.ImageType)
    case imageDidFetched(UIImage?)
    case nameTextFieldDidUpdate(String)
    case searchIDTextFieldDidUpdate(String)
    case favorDidSelected(Int)
    case doNothing
  }

  enum Mutation {
    case updateImageType(EditMyPageProfileHeader.ImageType)
    case updateImage(UIImage?)
    case updateName(String)
    case updateSearchID(String)
    case updateFavor([EditMyPageSectionItem])
  }

  struct State {
    var user: User
    var items: [[EditMyPageSectionItem]] = []
    var nameItems: [EditMyPageSectionItem] = []
    var idItems: [EditMyPageSectionItem] = []
    var favorItems: [EditMyPageSectionItem] = []
    var lastTappedProfileImage: EditMyPageProfileHeader.ImageType?
    var profileBackgroundImage: UIImage?
    var profilePhotoImage: UIImage?
    var name: String
    var searchID: String
    var favorList: [Favor]
  }

  // MARK: - Initializer
  
  init(user: User) {
    self.initialState = State(
      user: user,
      nameItems: [.textField(text: user.name, placeholder: "이름")],
      idItems: [.textField(text: user.searchID, placeholder: "ID")],
      name: user.name,
      searchID: user.searchID,
      favorList: user.favorList
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewNeedsLoaded:
      let favorItems = Favor.allCases.map { favor -> EditMyPageSectionItem in
        return .favor(isSelected: self.currentState.user.favorList.contains(favor), favor: favor)
      }
      return .just(.updateFavor(favorItems))

    case .cancelButtonDidTap:
      self.steps.accept(AppStep.editMyPageIsComplete)
      return .empty()

    case .doneButtonDidTap:
      return self.requestPatchUser()
        .flatMap { _ -> Observable<Mutation> in
          self.steps.accept(AppStep.editMyPageIsComplete)
          return .empty()
      }
      
    case .profileHeaderDidTap(let imageType):
      let pickerManager = PickerManager()
      self.pickerManager = pickerManager
      self.steps.accept(AppStep.imagePickerIsRequired(pickerManager, selectionLimit: 1))
      return .just(.updateImageType(imageType))
      
    case .imageDidFetched(let image):
      return .just(.updateImage(image))
      
    case .nameTextFieldDidUpdate(let name):
      return .just(.updateName(name))
      
    case .searchIDTextFieldDidUpdate(let searchID):
      return .just(.updateSearchID(searchID))
      
    case .favorDidSelected(let indexPath):
      var favorItems = self.currentState.favorItems
      guard
        indexPath < favorItems.count,
        case let EditMyPageSectionItem.favor(isSelected, favor) = favorItems[indexPath],
        favorItems.count == Constant.numberOfFavors
      else { return .empty() }

      // 이미 선택된 취향의 개수
      let selectedFavorsCount = favorItems.reduce(0) { count, favorItem in
        guard case let EditMyPageSectionItem.favor(isSelected, _) = favorItem else { return count }
        return isSelected ? count + 1 : count
      }
      // 선택된 취향의 개수가 5개 이상이고 선택된 Cell의 취향이 선택되지 않은 상태일 때 (5개 초과의 취향을 선택하고자 할 때)
      if selectedFavorsCount >= Constant.maximumSelectedFavor && !isSelected { return .empty() }
      
      favorItems[indexPath] = EditMyPageSectionItem.favor(isSelected: !isSelected, favor: favor)
      return .just(.updateFavor(favorItems))

    case .doNothing:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .updateImageType(let imageType):
      newState.lastTappedProfileImage = imageType
      
    case .updateImage(let image):
      switch self.currentState.lastTappedProfileImage {
      case .background:
        newState.profileBackgroundImage = image
      case .photo:
        newState.profilePhotoImage = image
      default:
        break
      }
      
    case .updateName(let name):
      newState.name = name
      
    case .updateSearchID(let searchID):
      newState.searchID = searchID
      
    case .updateFavor(let favorItems):
      var favorList: [Favor] = []
      newState.favorItems = favorItems
      favorItems.forEach { item in
        guard
          case let EditMyPageSectionItem.favor(isSelected, favor) = item,
          isSelected
        else { return }
        favorList.append(favor)
      }
      newState.favorList = favorList
    }

    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { (state: State) -> State in
      var newState = state
      newState.items = [state.nameItems, state.idItems, state.favorItems]
      return newState
    }
  }
}

// MARK: - Privates

private extension EditMyPageViewReactor {
  func requestPatchUser() -> Observable<Void> {
    let networking = UserNetworking()
    let name = self.currentState.name
    let userId = self.currentState.searchID
    let favorList = self.currentState.favorList.map { $0.rawValue }
    
    return Observable<Void>.create { observer in
      return self.requestPostProfile()
        .flatMap { _ in self.requestPostBackground() }
        .flatMap { _ in
          networking.request(.patchUser(name: name, userId: userId, favorList: favorList))
        }
        .map(ResponseDTO<UserSingleResponseDTO>.self)
        .map { User(singleDTO: $0.data) }
        .subscribe { user in
          Task {
            try await self.workBench.write { transaction in
              transaction.update(user.realmObject())
              observer.onNext(())
              observer.onCompleted()
            }
          }
        }
    }
  }
  
  func requestPostBackground() -> Observable<Void> {
    guard let image = self.currentState.profileBackgroundImage else { return .just(()) }
    let networking = UserPhotoNetworking()
    return networking.request(.postBackground(file: APIManager.createMultiPartForm(image)))
      .map { _ in }
  }
  
  func requestPostProfile() -> Observable<Void> {
    guard let image = self.currentState.profilePhotoImage else { return .just(()) }
    let networking = UserPhotoNetworking()
    return networking.request(.postProfile(file: APIManager.createMultiPartForm(image)))
      .map { _ in }
  }
}
