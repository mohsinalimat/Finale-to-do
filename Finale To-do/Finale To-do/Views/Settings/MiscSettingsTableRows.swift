//
//  MiscSettingsTableRows.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/29/22.
//

import Foundation
import UIKit

//MARK: App Badge Count View

class SettingsAppBadgeCountView: UIView {
    
    static let height: CGFloat = 356
    let selectionRowHeight = 50.0
    
    let padding = 16.0
    var rowWidth: CGFloat!
    let rowHeight: CGFloat
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let appIconView = UIImageView()
    let iconBadgeView = UIView()
    let badgeNumberLabel = UILabel()
    let rowsContainer = UIView()
    
    var selectionRows = [SettingsSelectionRow]()
    
    init() {
        self.rowHeight = SettingsAppBadgeCountView.height
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: rowHeight)))
        
        titleLabel.text = "App Badge Number"
        titleLabel.textColor = .label
        
        subtitleLabel.text = "The number shown on the app's icon."
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        
        appIconView.image = Bundle.main.appIcon
        appIconView.clipsToBounds = true
        appIconView.layer.cornerRadius = 12
        
        iconBadgeView.backgroundColor = .systemRed
        badgeNumberLabel.textColor = .white
        badgeNumberLabel.text = "7"
        badgeNumberLabel.textAlignment = .center
        badgeNumberLabel.font = .systemFont(ofSize: 15)
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(appIconView)
        self.addSubview(iconBadgeView)
        iconBadgeView.addSubview(badgeNumberLabel)
        self.addSubview(rowsContainer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rowWidth = superview!.frame.width
        let paddedRowWidth = rowWidth - padding*2
        self.frame.size.width = rowWidth
        
        titleLabel.frame = CGRect(x: padding, y: padding, width: paddedRowWidth, height: 20)
        subtitleLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.25, width: paddedRowWidth, height: 12)
        
        let iconSize = 60.0
        let badgeSize = iconSize*0.37
        appIconView.frame = CGRect(x: padding, y: subtitleLabel.frame.maxY+padding*1.5, width: iconSize, height: iconSize)
        iconBadgeView.frame = CGRect(x: appIconView.frame.maxX - 0.6*badgeSize, y: appIconView.frame.origin.y-badgeSize*0.4, width: badgeSize, height: badgeSize)
        iconBadgeView.layer.cornerRadius = badgeSize*0.5
        badgeNumberLabel.frame = CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize)
        
        SetupRows()
        for row in selectionRows { rowsContainer.addSubview(row) }
        rowsContainer.frame = CGRect(x: 0, y: appIconView.frame.maxY + padding*0.5, width: rowWidth, height: Double(selectionRows.count)*50.0)
    }
    
    func SetupRows () {
        if selectionRows.count != 0 { return }
        
        for i in 0..<4 {
            selectionRows.append(
                SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: AppBadgeNumberType(rawValue: i)!.str, index: i, isSelected: App.settingsConfig.appBadgeNumberTypes.contains(AppBadgeNumberType(rawValue: i)!), isNone: i == 0, onSelect: SelectOption, onDeselect: DeselectOption)
            )
        }
    }
    
    func SelectOption(index: Int) {
        selectionRows.first?.isSelected = false
        if App.settingsConfig.appBadgeNumberTypes.contains(.None) {
            App.settingsConfig.appBadgeNumberTypes.remove(at: App.settingsConfig.appBadgeNumberTypes.firstIndex(of: .None)!)
        }
        if index == 0 {
            for selectionRow in selectionRows {
                selectionRow.isSelected = false
            }
            App.settingsConfig.appBadgeNumberTypes.removeAll()
        }
        selectionRows[index].isSelected = true
        
        if !App.settingsConfig.appBadgeNumberTypes.contains(AppBadgeNumberType(rawValue: index)!) {
            App.settingsConfig.appBadgeNumberTypes.append(AppBadgeNumberType(rawValue: index)!)
        }
    }
    
    func DeselectOption (index: Int) {
        if index == 0 { return }
        var nSelected = 0
        for row in selectionRows { nSelected += row.isSelected ? 1 : 0}
        if nSelected == 1 { return }
        selectionRows[index].isSelected = false
        if App.settingsConfig.appBadgeNumberTypes.contains(AppBadgeNumberType(rawValue: index)!) {
            App.settingsConfig.appBadgeNumberTypes.remove(at: App.settingsConfig.appBadgeNumberTypes.firstIndex(of: AppBadgeNumberType(rawValue: index)!)!)
        }
    }
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: Settings Selection Row

class SettingsSelectionRow: UIView {
    
    let index: Int
    
    var OnSelect: (_ index: Int)->Void
    var OnDeselect: (_ index: Int)->Void
    
    var _isSelected: Bool!
    var isSelected: Bool  {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            imageView.image = UIImage(systemName: _isSelected ? isNone ? "circle.inset.filled" : "checkmark.circle.fill" :  "circle")
            imageView.tintColor = isSelected ? .defaultColor : .systemGray
        }
    }
    
    var imageView: UIImageView!
    
    let isNone: Bool
    let padding = 16.0
    
    init(frame: CGRect, title: String, index: Int, isSelected: Bool, isNone: Bool, onSelect: @escaping (_ index: Int)->Void, onDeselect: @escaping (_ index: Int)->Void) {
        self.isNone = isNone
        self.OnSelect = onSelect
        self.OnDeselect = onDeselect
        self.index = index
        super.init(frame: frame)
        
        let rowSize = frame.size
        
        let imageSize = rowSize.width*0.07
        imageView = UIImageView(frame: CGRect(x: padding, y: 0.5*(rowSize.height-imageSize), width: imageSize, height: imageSize))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .defaultColor

        let label = UILabel (frame: CGRect(x: imageView.frame.maxX + padding*0.5, y: 0, width: rowSize.width-padding*2.5-imageView.frame.width, height: rowSize.height))
        label.text = title
        label.textAlignment = .left

        self.addSubview(imageView)
        self.addSubview(label)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        
        self.isSelected = isSelected
    }
    
    @objc func Tap () {
        if isSelected && !isNone { Deselect() } else { Select() }
        
        self.backgroundColor = .systemGray3.withAlphaComponent(0.5)
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = .clear
        }
    }
    
    func Select() {
        OnSelect(index)
    }
    
    func Deselect() {
        OnDeselect(index)
    }
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: App Icon View

class SettingsAppIconView: UIView {
    
    static let height: CGFloat = 152.8
    
    let padding = 16.0
    var rowWidth: CGFloat!
    let rowHeight: CGFloat
    
    let titleLabel = UILabel()
    
    init() {
        self.rowHeight = SettingsAppBadgeCountView.height
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: rowHeight)))
        
        titleLabel.text = "App Icon"
        titleLabel.textColor = .label
        
        self.addSubview(titleLabel)
    }
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rowWidth = superview!.frame.width
        let paddedRowWidth = rowWidth - padding*2
        self.frame.size.width = rowWidth
        
        titleLabel.frame = CGRect(x: padding, y: padding*0.8, width: paddedRowWidth, height: 18)
        
        let cellWidth = 100.0
        let cellHeight = 90.0
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: titleLabel.frame.maxY+padding, width: rowWidth, height: cellHeight + padding))
        scrollView.contentSize = CGSize(width: cellWidth * Double(AppIcon.allCases.count), height: scrollView.frame.height)
        
        for i in 0..<AppIcon.allCases.count {
            let cell = AppIconView(
                frame: CGRect(x: Double(i)*cellWidth, y: 0, width: cellWidth, height: cellHeight),
                icon: AppIcon.allCases[i]
            )
            scrollView.addSubview(cell)
        }
        
        self.addSubview(scrollView)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AppIconView: UIView  {
    
    let icon: AppIcon
    
    let padding = 16.0
    
    init(frame: CGRect, icon: AppIcon) {
        self.icon = icon
        super.init(frame: frame)
        
        let imageSize = 70.0
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frame.width-imageSize), y: 0, width: imageSize, height: imageSize))
        imageView.image = icon.preview
        imageView.layer.cornerRadius = 16
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        imageView.isUserInteractionEnabled = true
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + padding*0.5, width: frame.width, height: 12))
        label.text = icon.displayName
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        
        self.addSubview(imageView)
        self.addSubview(label)
    }
    
    @objc func Tap () {
        AppIconManager.setIcon(icon)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
