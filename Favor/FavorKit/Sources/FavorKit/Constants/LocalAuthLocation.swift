//
//  LocalAuthLocation.swift
//  Favor
//
//  Created by 이창준 on 6/30/23.
//

import Foundation

public enum LocalAuthLocation {
  case launch, settingsCheckOld, settingsNew, settingsConfirmNew(String)
}
