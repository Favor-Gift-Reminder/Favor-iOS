//
//  AuthValidationManager.swift
//  Favor
//
//  Created by 이창준 on 2023/02/25.
//

enum ValidationResult {
  case empty, invalid, valid
}

protocol ValidationManager {
  var type: AuthType { get }
  func validate(_ content: String) -> ValidationResult
}

/// 로그인, 회원가입 화면에서 이메일 / 비밀번호 / 비밀번호 확인란에 입력된 텍스트와 관련된 메서드들을 담당합니다.
/// > Usage Example:
///
/// ``` Swift
/// AuthValidationManager(.email).validate("favor@abc.com")
/// ```
final class AuthValidationManager: ValidationManager {

  // MARK: - Properties

  var type: AuthType

  // MARK: - Initializer

  init(type: AuthType) {
    self.type = type
  }

  // MARK: - Functions

  /// **이메일**이나 **비밀번호** 필드의 값이 기준에 맞는지 검증합니다.
  /// - Parameters:
  ///   - content: 텍스트 필드에 입력된 텍스트
  /// - Returns: 검증 결과 (`.empty`, `.invalid`, `.valid`)
  func validate(_ content: String) -> ValidationResult {
    guard !content.isEmpty else { return .empty }
    guard content.range(
      of: self.type.regex,
      options: .regularExpression
    ) != nil else { return .invalid }
    return .valid
  }

  /// **비밀번호 확인** 필드의 값을 비밀번호와 비교합니다.
  /// - Parameters:
  ///   - content: 비밀번호 확인 필드에 입력된 텍스트
  ///   - criterion: 비교 기준이 되는 비밀번호 텍스트
  /// - Returns: 비밀번호 일치 여부
  func confirm(_ content: String, with criterion: String) -> ValidationResult {
    guard !content.isEmpty else { return .empty }
    guard content == criterion else { return .invalid }
    return .valid
  }

  /// 검증 결과에 따라 유저에게 도움이 되는 문장을 반환합니다.
  /// - Parameters:
  ///   - result: 검증 결과
  /// - Returns: 검증 결과와 텍스트필드 타입에 따른 안내 문구
  func description(for result: ValidationResult) -> String {
    switch result {
    case .empty: return self.type.emptyDescription
    case .invalid: return self.type.invalidDescription
    case .valid: return self.type.validDescription
    }
  }
}
