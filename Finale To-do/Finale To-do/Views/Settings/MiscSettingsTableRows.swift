//
//  MiscSettingsTableRows.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/29/22.
//

import Foundation
import UIKit

class SettingsAppBadgeCountView: UIView {
    
    static let height: CGFloat = 406
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
        
        titleLabel.text = "App badge number"
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
        
        var i = 0
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: "None", index: i, isSelected: true, isNone: true, onSelect: SelectOption, onDeselect: DeselectOption)
        )
        i += 1
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: "Notifications", index: i, isSelected: false, isNone: false, onSelect: SelectOption, onDeselect: DeselectOption)
        )
        i += 1
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: "Tasks today", index: i, isSelected: false, isNone: false, onSelect: SelectOption, onDeselect: DeselectOption)
        )
        i += 1
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: "Overdue tasks", index: i, isSelected: false, isNone: false, onSelect: SelectOption, onDeselect: DeselectOption)
        )
        i += 1
        selectionRows.append(
            SettingsSelectionRow(frame: CGRect(x: 0, y: Double(i)*selectionRowHeight, width: rowWidth, height: selectionRowHeight), title: "Upcoming tasks", index: i, isSelected: false, isNone: false, onSelect: SelectOption, onDeselect: DeselectOption)
        )
    }
    
    func SelectOption(index: Int) {
        selectionRows.first?.isSelected = false
        if index == 0 {
            for selectionRow in selectionRows {
                selectionRow.isSelected = false
            }
        }
        selectionRows[index].isSelected = true
    }
    
    func DeselectOption (index: Int) {
        if index == 0 { return }
        var nSelected = 0
        for row in selectionRows { nSelected += row.isSelected ? 1 : 0}
        if nSelected == 1 { return }
        selectionRows[index].isSelected = false
    }
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


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
