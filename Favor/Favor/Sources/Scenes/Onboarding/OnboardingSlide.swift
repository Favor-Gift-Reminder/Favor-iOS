//
//  OnboardingSlide.swift
//  Favor
//
//  Created by 김응철 on 2023/01/15.
//

import UIKit

struct OnboardingSlide {
  let image: UIImage
  let text: String
}

extension OnboardingSlide {
  static func slides() -> [OnboardingSlide] {
    return [
      .init(image: UIImage(), text: "특별한 선물을 받은\n오늘의 감정을 기록해요"),
      .init(image: UIImage(), text: "기억하고 싶은 기념일\n페이버가 대신 챙겨드려요"),
      .init(image: UIImage(), text: "고마운 마음을 담아\n메세지를 전달해요")
    ]
  }
}
