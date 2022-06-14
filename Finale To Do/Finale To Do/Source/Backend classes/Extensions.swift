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
        return UIColor(hex: "0962E5")
    }
    
    public static var clearInteractive: UIColor {
        return UIColor.white.withAlphaComponent(0.00001)
    }
    
    var light: UIColor {
        return self.lerp(second: .white, percentage: 0.35)
    }
    
    var light2: UIColor {
        return self.lerp(second: .white, percentage: 0.5)
    }
    
    var light3: UIColor {
        return self.lerp(second: .white, percentage: 0.65)
    }
    
    var light4: UIColor {
        return self.lerp(second: .white, percentage: 0.8)
    }
    
    var dark: UIColor {
        return self.lerp(second: .black, percentage: 0.35)
    }
    
    var dark2: UIColor {
        return self.lerp(second: .black, percentage: 0.5)
    }
    
    var dark3: UIColor {
        return self.lerp(second: .black, percentage: 0.65)
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
    
    var hexStringFromColor: String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
     }
}

struct CodableColor : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

extension String: Error {}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    func get(_ components: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(components, from: self)
    }
}


extension UIView {
    
    func AddStandardShadow() {
        AppConfiguration.AddStandardShadow(view: self)
    }
    
    func Shadow(radius: CGFloat, opacity: Float) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
    }
    
    func DebugSubviews (excluseSelf: Bool = false, parentColor: UIColor = .blue, color: UIColor = .red) {
        for view in self.subviews { view.DebugSubviews(parentColor: color) }
        if !excluseSelf { self.Debug(color: parentColor) }
    }
    
    func Debug(color: UIColor = .red) {
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
    
    func renderImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    
}

extension NSMutableAttributedString {
    
    func SetColor(color: UIColor) {
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.length))
    }
    
    func Strikethrough () {
        self.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: self.length))
    }
    
}


extension Calendar {
    func daysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}


extension UIFont {
    //Family: Rubik Font names: ["RubikRoman-Regular", "Rubik-Light", "RubikRoman-Medium", "RubikRoman-SemiBold", "RubikRoman-Bold", "RubikRoman-ExtraBold", "RubikRoman-Black"]
    
    static func Rubik (weight: UIFont.Weight = .regular, size: CGFloat) -> UIFont {
        switch weight {
        case .regular: return UIFont(name: "RubikRoman-Regular", size: size)!
        case .light: return UIFont(name: "Rubik-Light", size: size)!
        case .medium: return UIFont(name: "RubikRoman-Medium", size: size)!
        case .semibold: return UIFont(name: "RubikRoman-SemiBold", size: size)!
        case .bold: return UIFont(name: "RubikRoman-Bold", size: size)!
        case .black: return UIFont(name: "RubikRoman-Black", size: size)!
        default: return UIFont(name: "RubikRoman-Regular", size: size)!
        }
    }
    
    static var Rubik: UIFont {
        return Rubik(size: 17)
    }
    
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

import StoreKit

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            requestReview(in: scene)
        }
    }
}


extension Date {

  static func today() -> Date {
      return Date()
  }

  func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.next,
               weekday,
               considerToday: considerToday)
  }

  func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.previous,
               weekday,
               considerToday: considerToday)
  }

  func get(_ direction: SearchDirection,
           _ weekDay: Weekday,
           considerToday consider: Bool = false) -> Date {

    let dayName = weekDay.rawValue

    let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

    let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

    let calendar = Calendar(identifier: .gregorian)

    if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
      return self
    }

    var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
    nextDateComponent.weekday = searchWeekdayIndex

    let date = calendar.nextDate(after: self,
                                 matching: nextDateComponent,
                                 matchingPolicy: .nextTime,
                                 direction: direction.calendarSearchDirection)

    return date!
  }

}

// MARK: Helper methods
extension Date {
  func getWeekDaysInEnglish() -> [String] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar.weekdaySymbols
  }

  enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
  }

  enum SearchDirection {
    case next
    case previous

    var calendarSearchDirection: Calendar.SearchDirection {
      switch self {
      case .next:
        return .forward
      case .previous:
        return .backward
      }
    }
  }
}
