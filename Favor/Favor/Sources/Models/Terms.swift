//
//  Terms.swift
//  Favor
//
//  Created by 이창준 on 2023/03/03.
//

public struct Terms {
  /// 약관 내용
  let title: String
  /// 필수 / 선택 동의
  let isRequired: Bool
  /// 동의 / 미동의 여부
  var isAccepted: Bool = false
  /// URL
  let url: String
  let index: Int
}

extension Terms: Hashable {
  public static func == (lhs: Terms, rhs: Terms) -> Bool {
    return lhs.index == rhs.index && lhs.isAccepted == rhs.isAccepted
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.index)
    hasher.combine(self.isAccepted)
  }
}
