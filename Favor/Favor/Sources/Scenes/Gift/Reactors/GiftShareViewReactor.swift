//
//  GiftShareViewReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/05/30.
//

import UIKit

import FavorKit
import FavorNetworkKit
import ReactorKit
import RxCocoa
import RxFlow

final class GiftShareViewReactor: Reactor, Stepper {

  // MARK: - Properties

  var initialState: State
  var steps = PublishRelay<Step>()

  enum Action {
    case instagramButtonDidTap(UIImage?, UIImage)
    case photosButtonDidTap
  }

  enum Mutation {

  }

  struct State {
    var gift: Gift
  }

  // MARK: - Initializer

  init(gift: Gift) {
    self.initialState = State(
      gift: gift
    )
  }

  // MARK: - Functions

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .instagramButtonDidTap(background, sticker):
      self.share(to: .instagram(background, sticker))
      return .empty()

    case .photosButtonDidTap:
      return .empty()
    }
  }
}

// MARK: - Privates

private extension GiftShareViewReactor {

  // MARK: - Constants

  // MARK: - Functions

  private func share(to target: ShareTarget) {
    switch target {
    case let .instagram(background, sticker):
      Task {
        await self.shareToInstagram(background: background, sticker: sticker)
      }
    case .photos:
      return
    }
  }

  @MainActor
  private func shareToInstagram(background: UIImage?, sticker: UIImage?) {
    if
      let background, let sticker,
      let imageData = background.pngData(),
      let stickerData = sticker.pngData() {
      self.backgroundImage(
        backgroundImage: imageData,
        stickerImage: stickerData,
        appID: URLSchemes.instagramStory.url
      )
    }
  }

  @MainActor
  private func backgroundImage(backgroundImage: Data, stickerImage: Data, appID: String) {
    if let url = URL(string: appID) {
      if UIApplication.shared.canOpenURL(url) {
        let pasteboardItems = [
          [
            "com.instagram.sharedSticker.backgroundImage": backgroundImage,
            "com.instagram.sharedSticker.stickerImage": stickerImage
          ]
        ]

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
          .expirationDate: Date(timeIntervalSinceNow: 60 * 5)
        ]

        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

        UIApplication.shared.open(url, options: [:])
      } else {
        // Error Handling
      }
    }
  }
}
