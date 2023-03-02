//
//  Networkable.swift
//  Favor
//
//  Created by 이창준 on 2023/03/01.
//

import Moya

/// `MoyaProvider` 객체를 생성하여 반환하는 작업을 지원하는 프로토콜
///
/// **Example**
/// ```
/// struct UserAPI: Networkable {
///   typealias Target = UserTarget
///
///   static func fetchUserRequest(request: UserRequest, completion: @escaping (_ succeed: User?, _ failed: Error?) -> Void {
///     self.makeProvider().request(.one(request)) { result in
///       // Handle response
///     }
///   }
/// }
/// ```
protocol Networkable {
  associatedtype Target: TargetType
  static func makeProvider() -> MoyaProvider<Target>
}

extension Networkable {
  /// `Target`에 맞는`MoyaProvider` 객체를 생성하고, 고정적으로 들어가는 Plugins들을 주입합니다.
  static func makeProvider() -> MoyaProvider<Target> {
    // Plugins

    return MoyaProvider<Target>(plugins: [])
  }
}
