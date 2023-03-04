//
//  Terms.swift
//  Favor
//
//  Created by 이창준 on 2023/03/03.
//

struct Terms {
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
