//
//  PHPickerManager.swift
//  Favor
//
//  Created by 이창준 on 2023/01/18.
//

import OSLog
import PhotosUI
import UniformTypeIdentifiers

import RxSwift

public protocol PHPickerManagerDelegate: AnyObject {
  func pickerManager(didFinishPicking image: UIImage?)
}

public final class PHPickerManager {
  public typealias Selections = [String: PHPickerResult]
  
  // MARK: - Properties
  
  public weak var delegate: PHPickerManagerDelegate?
  private var selections: Selections = [:]
  private var selectedAssetIdentifiers: [String] = []
  
  // MARK: - Initializer
  
  public init() {}
  
  // MARK: - Functions
  
  /// PHPickerViewController를 VC에 `present`합니다.
  ///
  /// VC는 PHPickerManager를 초기화할 때 지정해줄 수 있습니다.
  public  func present(
    filter: PHPickerFilter = .images,
    selectionLimit: Int,
    completion: (() -> Void)? = nil
  ) {
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.filter = filter
    config.selection = .ordered
    config.selectionLimit = selectionLimit
    if selectionLimit != 1 {
      config.preselectedAssetIdentifiers = self.selectedAssetIdentifiers
    }
    let picker = PHPickerViewController(configuration: config)
    picker.modalPresentationStyle = .overFullScreen
    picker.delegate = self
    self.delegate = UIApplication.shared.topViewController() as? PHPickerManagerDelegate
    UIApplication.shared.topViewController()?.present(picker, animated: true) {
      if let completion {
        completion()
      }
    }
  }
  
  /// 이미지 선택 결과를 전달하기 위한 Helper 메서드
  private func fetch(_ pickerResult: PHPickerResult) async throws -> UIImage? {
    let itemProvider = pickerResult.itemProvider
    
    if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
      let livePhoto = try await itemProvider.loadObject(ofClass: PHLivePhoto.self)
      let image = livePhoto.value(forKey: "imageData") as? UIImage
      return image
    } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
      let image = try await itemProvider.loadObject(ofClass: UIImage.self)
      return image
    } else {
      if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
        let data = try await itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier)
        let image = UIImage(data: data)
        return image
      } else {
        return nil
      }
    }
  }
}

extension PHPickerManager: PHPickerViewControllerDelegate {
  public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    Task {
      for result in results {
        let image = try await self.fetch(result)
        self.delegate?.pickerManager(didFinishPicking: image)
      }
    }
    UIApplication.shared.topViewController()?.dismiss(animated: true)
  }
}
