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


enum AppIcon: Int, Codable, CaseIterable {
    case classic = 0
    case dark = 1
    case red = 2
    case purple = 3
    case orange = 4
    case black = 5
    case classicFilled = 6
    case darkmodeFilled = 7
    case redFilled = 8
    case purpleFilled = 9
    case orangeFilled = 10
    case blackFilled = 12
    
    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .dark: return "Dark"
        case .red: return "Red"
        case .purple: return "Violet"
        case .orange: return "Orange"
        case .black: return "Black"
        case .classicFilled: return "Classic Filled"
        case .darkmodeFilled: return "Dark Filled"
        case .redFilled: return "Red Filled"
        case .purpleFilled: return "Violet Filled"
        case .orangeFilled: return "Orange Filled"
        case .blackFilled: return "Black Filled"
        }
    }
    
    var name: String? {
        switch self {
        case .classic: return nil
        case .dark: return "dark"
        case .red: return "red"
        case .purple: return "purple"
        case .orange: return "orange"
        case .black: return "black"
        case .classicFilled: return "classicFilled"
        case .darkmodeFilled: return "darkmodeFilled"
        case .redFilled: return "redFilled"
        case .purpleFilled: return "purpleFilled"
        case .orangeFilled: return "orangeFilled"
        case .blackFilled: return "blackFilled"
        }
    }

    var preview: UIImage {
        switch self {
        case .classic: return UIImage(imageLiteralResourceName: "classic@3x.png")
        case .dark: return UIImage(imageLiteralResourceName: "dark@3x.png")
        case .red: return UIImage(imageLiteralResourceName: "red@3x.png")
        case .purple: return UIImage(imageLiteralResourceName: "purple@3x.png")
        case .orange: return UIImage(imageLiteralResourceName: "orange@3x.png")
        case .black: return UIImage(imageLiteralResourceName: "black@3x.png")
        case .classicFilled: return UIImage(imageLiteralResourceName: "classicFilled@3x.png")
        case .darkmodeFilled: return UIImage(imageLiteralResourceName: "darkmodeFilled@3x.png")
        case .redFilled: return UIImage(imageLiteralResourceName: "redFilled@3x.png")
        case .purpleFilled: return UIImage(imageLiteralResourceName: "purpleFilled@3x.png")
        case .orangeFilled: return UIImage(imageLiteralResourceName: "orangeFilled@3x.png")
        case .blackFilled: return UIImage(imageLiteralResourceName: "blackFilled@3x.png")
        }
        
    }
    
}
