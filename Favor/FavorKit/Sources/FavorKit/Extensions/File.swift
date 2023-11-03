//
//  File.swift
//
//
//  Created by 김응철 on 11/4/23.
//

import PhotosUI

extension NSItemProvider {
  func loadObject<T>(ofClass: T.Type) async throws -> T where T: NSItemProviderReading {
    return try await withCheckedThrowingContinuation { continuation in
      self.loadObject(ofClass: ofClass) { object, error in
        if let object = object as? T {
          continuation.resume(returning: object)
        } else if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
      }
    }
  }
  
  func loadDataRepresentation(forTypeIdentifier: String) async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
      self.loadDataRepresentation(forTypeIdentifier: forTypeIdentifier) { data, error in
        if let data = data {
          continuation.resume(returning: data)
        } else if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
      }
    }
  }
}
