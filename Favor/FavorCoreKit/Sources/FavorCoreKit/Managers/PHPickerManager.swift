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

public final class PHPickerManager: PHPickerManagerProtocol {
  public var pickedContents = BehaviorRelay<[UIImage]>(value: [])

  public init() { }
  
  /// PHPickerController를 선택한 NavigationController에 present합니다.
  /// - Parameters:
  ///   - navigationController: PHPicker를 present할 NavigationController
  public func presentPHPicker(
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
  
  public func picker(
    _ picker: PHPickerViewController,
    didFinishPicking results: [PHPickerResult]
  ) {
    let cg = CoreGraphicManager()
    let itemProvider = results.first?.itemProvider

    if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
      itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
        if let url {
          let targetSize = CGSize(width: 80, height: 80)
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
        DispatchQueue.main.async {
          picker.dismiss(animated: true)
        }
      }
    }
  }
  
}
