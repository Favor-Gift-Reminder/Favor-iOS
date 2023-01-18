//
//  PHPickerManager.swift
//  Favor
//
//  Created by 이창준 on 2023/01/18.
//

import OSLog
import PhotosUI

import RxRelay

protocol PHPickerManagerProtocol {
  var pickedContents: BehaviorRelay<[UIImage]> { get }
}

final class PHPickerManager: PHPickerManagerProtocol {
  var pickedContents = BehaviorRelay<[UIImage]>(value: [])
  
  /// PHPickerController를 선택한 NavigationController에 present합니다.
  /// - Parameters:
  ///   - navigationController: PHPicker를 present할 NavigationController
  func presentPHPicker(
    at navigationController: UINavigationController
  ) {
    var config = PHPickerConfiguration()
    config.filter = .images // Filter only images
    let imagePickerController = PHPickerViewController(configuration: config)
    imagePickerController.delegate = self
    navigationController.present(imagePickerController, animated: true)
  }
  
}

extension PHPickerManager: PHPickerViewControllerDelegate {
  
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    let cg = CoreGraphicManager()
    let itemProvider = results.first?.itemProvider

    if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
        if let url {
          let targetSize = CGSize(width: 120.0, height: 120.0)
          guard let downsampledImageData = cg.downsample(
            at: url,
            toSize: targetSize,
            screenScale: UIScreen.main.scale
          ) else { return }
          guard let convertedImage = UIImage(data: downsampledImageData) else { return }
          self.pickedContents.accept([convertedImage])
        }
        if let error {
          os_log(.error, "\(error)")
        }
        picker.dismiss(animated: true)
      }
    }
  }
  
}
