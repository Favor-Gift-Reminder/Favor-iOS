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
  private func fetch(
    _ pickerResult: PHPickerResult,
    completion: @escaping ((UIImage?, Error?) -> Void)
  ) {
    let itemProvider = pickerResult.itemProvider
    
    if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
      itemProvider.loadObject(ofClass: PHLivePhoto.self) { livePhoto, error in
        guard let livePhoto = livePhoto as? PHLivePhoto else {
          completion(nil, error)
          return
        }
        // Live Photo의 이미지 데이터를 JPEG로 변환
        let image = livePhoto.value(forKey: "imageData") as? UIImage
        completion(image, error)
      }
    } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadObject(ofClass: UIImage.self) { image, error in
        guard let image = image as? UIImage else {
          completion(nil, error)
          return
        }
        completion(image, error)
      }
    } else {
      if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
        itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) 
        { data, error in
          guard let data = data else { return completion(nil, error) }
          let image = UIImage(data: data)
          completion(image, nil)
        }
      } else {
        os_log(.error, "사진 변환을 실패했습니다!")
      }
    }
  }
}

extension PHPickerManager: PHPickerViewControllerDelegate {
  public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    let currentSelections = self.selections
    var newSelections: Selections = [:]
    for result in results {
      let identifier = result.assetIdentifier!
      newSelections[identifier] = currentSelections[identifier] ?? result
      self.fetch(result) { image, error in
        if let error = error {
          os_log(.error, "❌ 사진을 가져오는데 실패했습니다! \(error.localizedDescription)")
          return
        }
        self.delegate?.pickerManager(didFinishPicking: image)
      }
    }

    self.selections = newSelections
    self.selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
    UIApplication.shared.topViewController()?.dismiss(animated: true)
  }
}
