//
//  Extensions.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/14/22.
//

import Foundation
import SwiftUI

extension Color {
    public static var defaultColor: Color {
        return Color(hex: "0962E5")
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {

            #if canImport(UIKit)
            typealias NativeColor = UIColor
            #elseif canImport(AppKit)
            typealias NativeColor = NSColor
            #endif

            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var o: CGFloat = 0

            guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
                // You can handle the failure here as you want
                return (0, 0, 0, 0)
            }

            return (r, g, b, o)
        }
    
    func lerp (second: Color, percentage: CGFloat) -> Color {
        return Color(red: (1.0-percentage)*self.components.red + percentage*second.components.red, green: (1.0-percentage)*self.components.green + percentage*second.components.green, blue: (1.0-percentage)*self.components.blue + percentage*second.components.blue).opacity((1.0-percentage)*self.components.alpha + percentage*second.components.alpha)
    }
    
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    func get(_ components: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(components, from: self)
    }
    
    func nOfDaysInCurrentMonth() -> Int{
        let calendar = Calendar.current

        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count

        return numDays
    }
    
    func isSameDay(compareDate: Date) -> Bool {
        if self.get(.month, calendar: Calendar.current) - compareDate.get(.month, calendar: Calendar.current) != 0 { return false }
        if self.get(.year, calendar: Calendar.current) - compareDate.get(.year, calendar: Calendar.current) != 0 { return false }
        
        return self.get(.day, calendar: Calendar.current) - compareDate.get(.day, calendar: Calendar.current) == 0
    }
}

struct FixedClipped: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content.hidden().layoutPriority(1)
            content.fixedSize(horizontal: true, vertical: false)
        }
        .clipped()
    }
}

extension View {
    func fixedClipped() -> some View {
        self.modifier(FixedClipped())
    }
}
