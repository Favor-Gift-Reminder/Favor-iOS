//
//  PHPickerManager.swift
//  Favor
//
//  Created by 이창준 on 2023/01/18.
//

import OSLog
import PhotosUI

public protocol PHPickerManagerDelegate: AnyObject {
  func pickerManager(didFinishPicking selections: PHPickerManager.Selections)
}

public final class PHPickerManager {
  public typealias Selections = [String: PHPickerResult]
  
  // MARK: - Properties
  
  private let target: UIViewController
  public weak var delegate: PHPickerManagerDelegate?
  
  private var selections: Selections = [:]
  private var selectedAssetIdentifiers: [String] = []
  
  // MARK: - Initializer

  private init(_ target: UIViewController) {
    self.target = target
  }
  
  // MARK: - Functions
  
  public static func create(for presentingViewController: UIViewController) -> PHPickerManager {
    let pickerManager = PHPickerManager(presentingViewController)
    pickerManager.delegate = presentingViewController as? PHPickerManagerDelegate
    return pickerManager
  }
  
  /// PHPickerViewController를 VC에 `present`합니다.
  ///
  /// VC는 PHPickerManager를 초기화할 때 지정해줄 수 있습니다.
  public func present(
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
    picker.delegate = self
    self.target.present(picker, animated: true) {
      if let completion {
        completion()
      }
    }
  }
  
  /// 이미지 선택 결과를 전달하기 위한 Helper 메서드
  public static func fetch(
    _ pickerResult: PHPickerResult,
    isLivePhotoEnabled: Bool,
    completion: @escaping ((NSItemProviderReading?, Error?) -> Void)
  ) {
    let itemProvider = pickerResult.itemProvider
    
    if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) && isLivePhotoEnabled {
      itemProvider.loadObject(ofClass: PHLivePhoto.self) { livePhoto, error in
        completion(livePhoto, error)
      }
    } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadObject(ofClass: UIImage.self) { image, error in
        completion(image, error)
      }
    }
  }
}

// MARK: - Delegate

extension PHPickerManager: PHPickerViewControllerDelegate {
  public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    self.target.dismiss(animated: true)
    
    let currentSelections = self.selections
    var newSelections: Selections = [:]
    for result in results {
      let identifier = result.assetIdentifier!
      newSelections[identifier] = currentSelections[identifier] ?? result
    }
    
    self.selections = newSelections
    self.selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
    
    self.delegate?.pickerManager(didFinishPicking: selections)
  }
}
