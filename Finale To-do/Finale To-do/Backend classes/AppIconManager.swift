//
//  AppIconManager.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/29/22.
//

import Foundation
import UIKit

class AppIconManager {
    var current: AppIcon {
        return AppIcon.allCases.first(where: { $0.name == UIApplication.shared.alternateIconName }) ?? .classic
    }

    static func setIcon(_ appIcon: AppIcon, completion: ((Bool) -> Void)? = nil) {

        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(appIcon.name) { error in
            if let error = error { print("Error setting alternate icon \(appIcon.name ?? ""): \(error.localizedDescription)") }
            completion?(error != nil)
        }
    }
}
