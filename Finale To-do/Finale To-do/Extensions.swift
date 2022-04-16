//
//  Extensions.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/14/22.
//

import Foundation
import UIKit

extension UIColor {
    public static var defaultColor: UIColor {
        return UIColor(hex: "3255CC")
    }
    
    public static var clearInteractive: UIColor {
        return UIColor.white.withAlphaComponent(0.00001)
    }
    
    var secondaryColor: UIColor {
        return self.withAlphaComponent(0.3)
    }
    
    var thirdColor: UIColor {
        return self.lerp(second: .black, percentage: 0.5)
    }
    
    convenience init(hex: String) {
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    func lerp (second: UIColor, percentage: CGFloat) -> UIColor {
        return UIColor(red: (1-percentage)*self.components.red + percentage*second.components.red, green: (1-percentage)*self.components.green + percentage*second.components.green, blue: (1-percentage)*self.components.blue + percentage*second.components.blue, alpha: (1-percentage)*self.components.alpha + percentage*second.components.alpha)
    }
}

struct Color : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

extension String: Error {}
