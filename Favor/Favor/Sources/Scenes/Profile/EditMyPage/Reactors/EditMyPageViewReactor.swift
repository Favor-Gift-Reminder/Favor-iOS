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
    static let numberOfFavors = 18
    static let maximumSelectedFavor = 5
  }

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case viewNeedsLoaded
    case cancelButtonDidTap
    case doneButtonDidTap
    case profileHeaderDidTap(EditMyPageProfileHeader.ImageType)
    case imageDidFetched(UIImage)
    case nameTextFieldDidUpdate(String?)
    case searchIDTextFieldDidUpdate(String?)
    case favorDidSelected(Int)
    case doNothing
  }

  enum Mutation {
    case updateImageType(EditMyPageProfileHeader.ImageType)
    case updateImage(UIImage)
    case updateName(String?)
    case updateSearchID(String?)
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
    var name: String?
    var searchID: String?
  }

  // MARK: - Initializer

  init(user: User) {
    self.initialState = State(
      user: user,
      nameItems: [.textField(text: user.name, placeholder: "이름")],
      idItems: [.textField(text: user.searchID, placeholder: "ID")]
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
      let favors = currentState.favorItems.compactMap { item -> String? in
        guard
          case let EditMyPageSectionItem.favor(isSelected, favor) = item,
          isSelected
        else { return nil }
        return favor.rawValue
      }
      let networking = UserNetworking()
      // TODO: Cache Image
      return networking.request(.patchUser(
        name: self.currentState.name ?? "",
        userId: self.currentState.searchID ?? "",
        favorList: favors
      ))
      .flatMap { _ -> Observable<Mutation> in
        self.steps.accept(AppStep.editMyPageIsComplete)
        return .empty()
      }
      
    case .profileHeaderDidTap(let imageType):
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
      newState.favorItems = favorItems
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
