//
//  ProfileSetupHelperCellReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/02/15.
//

import UIKit

import ReactorKit

final class ProfileSetupHelperCellReactor: Reactor {

  // MARK: - Constants

  public enum ProfileHelperType {
    case favor, anniversary

    public var iconImage: UIImage? {
      switch self {
      case .favor: return .favorIcon(.heartedPerson)
      case .anniversary: return .favorIcon(.heartedPerson)
      }
    }

    public var description: String {
      switch self {
      case .favor: return "5가지 취향 키워드를 등록해보세요."
      case .anniversary: return "공유하고 싶은 기념일을 등록해보세요."
      }
    }
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var type: ProfileHelperType
  }
  
  // MARK: - Initializer
  
  init(_ type: ProfileHelperType) {
    self.initialState = State(
      type: type
    )
  }
  
  
  // MARK: - Functions
  

}
