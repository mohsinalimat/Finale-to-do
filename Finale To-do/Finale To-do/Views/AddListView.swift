//
//  AddListView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/18/22.
//

import Foundation
import UIKit

class AddListView: UIView, UITextFieldDelegate {
    
    let padding = 16.0
    let rowHeight = 45.0
    
    let newTaskList: TaskList
    
    var blackoutPanel: UIView!
    var contentView: UIView!
    var inputField: UITextField!
    var iconView: UIImageView!
    var createButton: UIButton!
    var colorPickerView: ColorIconPickerView!
    
    let placeholders: [String] = ["Travel plan" , "Final project" , "Grocery list", "Work", "Family", "Sports club", "Hobbies", "Chores", "Shopping list"]
    
    let icons: [String] = ["folder.fill", "book.closed.fill", "heart.fill", "paperplane.fill", "calendar", "rectangle.fill.on.rectangle.fill", "trash.fill", "alarm.fill", "hourglass", "bolt.fill", "lightbulb.fill", "bag.fill", "tray.full.fill", "archivebox.fill", "graduationcap.fill", "briefcase.fill"]
    
    let colors: [UIColor] = [UIColor.defaultColor, UIColor(hex: "5243AA"), UIColor(hex: "87007A"), UIColor(hex: "DE0B0B"), UIColor(hex: "FF991F"), UIColor(hex: "00875A"), UIColor(hex: "008716"), UIColor(hex: "00A3BF")]
    
    init(frame: CGRect, taskList: TaskList = TaskList(name: "", primaryColor: .defaultColor, systemIcon: "folder.fill")) {
        self.newTaskList = TaskList(name: taskList.name, primaryColor: taskList.primaryColor, systemIcon: taskList.systemIcon, id: taskList.id)
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height+10, width: frame.width, height: frame.height))
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = ThemeManager.currentTheme.tintedBackgroundColor
        contentView.AddStandardShadow()
        
        let panelWidth = (frame.width-padding*2)*0.8-padding
        let iconWidth = rowHeight
        let inputFieldWidth = panelWidth - iconWidth
        let createButtonWidth = (frame.width-padding*2)-panelWidth-padding
        let leftPadding = 8.0
        
        let panel = UIView (frame: CGRect(x: padding, y: padding, width: panelWidth, height: rowHeight))
        panel.backgroundColor = ThemeManager.currentTheme.sidemenuSelectionColor
        panel.layer.cornerRadius = 10
        
        inputField = UITextField(frame: CGRect(x: iconWidth, y: 0, width: inputFieldWidth-leftPadding*2, height: rowHeight))
        inputField.delegate = self
        inputField.textColor = .white
        inputField.attributedPlaceholder = NSAttributedString(
            string: placeholders[Int.random(in: 0..<placeholders.count)],
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        inputField.addTarget(self, action: #selector(DetectTextFieldChange), for: .editingChanged)
        inputField.becomeFirstResponder()
        inputField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CloseColorIconPicker)))
        inputField.text = newTaskList.name
        
        panel.addSubview(inputField)
        
        iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: iconWidth, height: rowHeight))
        iconView.image = UIImage(systemName: newTaskList.systemIcon)
        iconView.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        iconView.tintColor = newTaskList.primaryColor
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OpenColorIconPicker)))
        iconView.contentMode = .scaleAspectFit
        
        panel.addSubview(iconView)
        
        contentView.addSubview(panel)
        
        createButton = UIButton(frame: CGRect(x: panel.frame.maxX + padding, y: panel.frame.origin.y, width: createButtonWidth, height: rowHeight))
        createButton.layer.cornerRadius = 10
        createButton.isEnabled = inputField.text != ""
        createButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: taskList.primaryColor)
        createButton.alpha = createButton.isEnabled ? 1 : 0.5
        createButton.addTarget(self, action: #selector(CreateOrUpdateTaskList), for: .touchUpInside)
        
        let buttonImageView = UIImageView(frame: CGRect(x: 0.43*(createButton.frame.width-createButtonWidth*0.5), y: 0.5*(createButton.frame.height-rowHeight), width: createButtonWidth*0.5, height: rowHeight))
        buttonImageView.image = UIImage(systemName: "paperplane.fill")
        buttonImageView.contentMode = .scaleAspectFit
        buttonImageView.tintColor = .white
        buttonImageView.transform = buttonImageView.transform.rotated(by: .pi * 0.25).scaledBy(x: 0.8, y: 0.8)
        
        createButton.addSubview(buttonImageView)
        contentView.addSubview(createButton)
        
        blackoutPanel = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blackoutPanel.backgroundColor = .black
        blackoutPanel.alpha = 0
        blackoutPanel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Dismiss)))
        
        self.addSubview(blackoutPanel)
        self.addSubview(contentView)
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func SetTaskListIcon () {
        iconView.image = UIImage(systemName: newTaskList.systemIcon)
    }
    
    @objc func KeyboardWillShow (_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            App.instance.ZoomOutContainterView()
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
                let y = UIScreen.main.bounds.height - App.instance.view.safeAreaInsets.bottom - keyboardHeight - frame.height*0.052
                blackoutPanel.alpha = 0.5
                contentView.frame.origin.y = y
            }
        }
    }
    
    @objc func DetectTextFieldChange() {
        createButton.isEnabled = inputField.text != ""
        createButton.alpha = createButton.isEnabled ? 1 : 0.5
        
        newTaskList.name = inputField.text!
        
        if colorPickerView != nil { colorPickerView.Dismiss() }
    }
    
    @objc func OpenColorIconPicker () {
        if colorPickerView != nil {
            CloseColorIconPicker()
            return
        }
        let height = rowHeight*3
        let width = (frame.width-padding*2)*0.9
        colorPickerView = ColorIconPickerView(frame: CGRect(x: padding - width*0.425, y: contentView.frame.minY - height*0.5, width: width, height: height), icons: icons, colors: colors, addListView: self)
        self.addSubview(colorPickerView)
    }
    @objc func CloseColorIconPicker() {
        if colorPickerView == nil { return }
        colorPickerView.Dismiss()
    }
    
    @objc func CreateOrUpdateTaskList(){
        if newTaskList.id == App.mainTaskList.id {
            UpdateOldTaskList(oldTaskList: App.mainTaskList)
            return
        }
        for taskList in App.userTaskLists {
            if taskList.id == newTaskList.id {
                UpdateOldTaskList(oldTaskList: taskList)
                return
            }
        }
        CreateNewTaskList()
    }
    
    func CreateNewTaskList () {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        App.instance.CreateNewTaskList(taskList: newTaskList)
        CloseView()
    }
    func UpdateOldTaskList(oldTaskList: TaskList){
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        App.instance.EditTaskList(oldTaskList: oldTaskList, updatedTaskList: newTaskList)
        CloseView()
    }
    
    func CloseView () {
        inputField.resignFirstResponder()
        if colorPickerView != nil { colorPickerView.Dismiss() }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
            contentView.frame.origin.y = UIScreen.main.bounds.height + 10
            blackoutPanel.alpha = 0
        }, completion: { [self] _ in
            self.removeFromSuperview()
        })
        
        App.instance.ZoomInContainterView()
    }
    
    @objc func Dismiss () {
        if colorPickerView == nil {
            CloseView()
        } else {
            colorPickerView.Dismiss()
        }
    }
    
    func SelectColor(index: Int) {
        for swatch in colorPickerView.colorSwatches {
            swatch.isSelected = false
        }
        colorPickerView.colorSwatches[index].isSelected = true
        
        newTaskList.primaryColor = colors[index]
        
        iconView.tintColor = newTaskList.primaryColor
    }
    func SelectIcon(index: Int) {
        for swatch in colorPickerView.iconSwatches {
            swatch.isSelected = false
        }
        colorPickerView.iconSwatches[index].isSelected = true
        
        newTaskList.systemIcon = icons[index]
        
        SetTaskListIcon()
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColorIconPickerView: UIView {
    
    let padding = 12.0
    
    let icons: [String]
    let colors: [UIColor]
    let addListView: AddListView
    
    var iconSwatches = [Swatch]()
    var colorSwatches = [Swatch]()
    
    init(frame: CGRect, icons: [String], colors: [UIColor], addListView: AddListView) {
        self.icons = icons
        self.colors = colors
        self.addListView = addListView
        
        let spacing = 6.0
        
        let containerWidth = frame.width-padding*2
        let swatchSize = (containerWidth - spacing*CGFloat(7) ) / CGFloat(8)
        let colorContainerHeight = swatchSize
        let iconContainerHeight = swatchSize*2+spacing
        
        let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y-((colorContainerHeight+iconContainerHeight)+padding*4-frame.height), width: frame.width, height: (colorContainerHeight+iconContainerHeight)+padding*4)
        super.init(frame: newFrame)
        
        self.backgroundColor = ThemeManager.currentTheme.sidemenuSelectionColor
        self.layer.cornerRadius = 10
        
        let colorsContainer = DrawSwatches(prevFrameMaxY: 0, swatchSize: swatchSize, nRows: 1, nColumns: 8, spacing: spacing, containerWidth: containerWidth, containerHeight: colorContainerHeight, color: true)
        let iconContainer = DrawSwatches(prevFrameMaxY: colorsContainer.frame.maxY+padding, swatchSize: swatchSize, nRows: 2, nColumns: 8, spacing: spacing, containerWidth: containerWidth, containerHeight: iconContainerHeight, icon: true)
        
        self.addSubview(colorsContainer)
        self.addSubview(iconContainer)
        
        self.frame.origin.y += padding*2
        ShowViewAnimation()
    }
    
    func ShowViewAnimation () {
        self.transform = CGAffineTransform(scaleX: 0, y: 0);
        self.layer.anchorPoint = CGPoint(x: 0.075, y: 1)
        self.alpha = 0
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1);
            self.alpha = 1
            self.frame.origin.y -= self.padding*2
        }, completion: {_ in })
    }
    
    func DrawSwatches(prevFrameMaxY: CGFloat, swatchSize: CGFloat, nRows: Int, nColumns: Int, spacing: CGFloat, containerWidth: CGFloat, containerHeight: CGFloat, color: Bool = false, icon: Bool = false) -> UIView {
        
        let containerView = UIView(frame: CGRect(x: padding, y: prevFrameMaxY+padding, width: containerWidth, height: containerHeight))
        
        for row in 0..<nRows {
            for column in 0..<nColumns {
                let swatch = Swatch(
                    frame: CGRect(
                        x: CGFloat(column)*spacing + swatchSize*CGFloat(column),
                        y: CGFloat(row)*spacing + swatchSize*CGFloat(row),
                        width: swatchSize,
                        height: swatchSize),
                    index: column + row*8,
                    addListView: addListView,
                    color: color ? colors[column + row*8] : .clearInteractive,
                    icon: icon ? icons[column + row*8] : ""
                )
                if color { colorSwatches.append(swatch) }
                else if icon { iconSwatches.append(swatch) }

                containerView.addSubview(swatch)
            }
        }
        
        return containerView
    }
    
    func Dismiss () {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01);
            self.alpha = 0
            self.frame.origin.y += self.padding*2
        }, completion: {_ in
            self.addListView.colorPickerView = nil
            self.removeFromSuperview()
        })
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class Swatch: UIView {
    
    let addListView: AddListView
    let color: UIColor
    let icon: String
    let index: Int
    
    private var _isSelected = false
    var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            SetColors()
        }
    }
    
    var insideCircle: UIView!
    var colorCircle: UIView!
    
    init(frame: CGRect, index: Int, addListView: AddListView, color: UIColor = UIColor.clearInteractive, icon: String = "") {
        self.color = color
        self.icon = icon
        self.index = index
        self.addListView = addListView
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.width*0.5
        
        insideCircle = UIView(frame: CGRect(x: 2, y: 2, width: frame.width-4, height: frame.height-4))
        insideCircle.layer.cornerRadius = insideCircle.frame.width*0.5
        insideCircle.isUserInteractionEnabled = false
        
        self.addSubview(insideCircle)
        
        colorCircle = UIView(frame: CGRect(x: 4, y: 4, width: frame.width-8, height: frame.height-8))
        colorCircle.layer.cornerRadius = colorCircle.frame.width*0.5
        colorCircle.isUserInteractionEnabled = false
        
        self.addSubview(colorCircle)
        
        if icon != "" {
            let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            iconView.image = UIImage(systemName: icon)
            iconView.contentMode = .scaleAspectFit
            iconView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            iconView.tintColor = .white
            iconView.isUserInteractionEnabled = false
            self.addSubview(iconView)
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Select))
        self.addGestureRecognizer(tap)
        
        if icon != "" {
            isSelected = addListView.newTaskList.systemIcon == icon
        } else {
            isSelected = addListView.newTaskList.primaryColor == color
        }
    }
    
    func SetColors () {
        self.backgroundColor = isSelected ? .white : color == .clearInteractive ? .defaultColor : color
        insideCircle.backgroundColor = isSelected ? .defaultColor.dark : .clear
        colorCircle.backgroundColor = color == .clearInteractive ? .defaultColor : color
    }
    
    @objc func Select() {
        if color == UIColor.clearInteractive {
            addListView.SelectIcon(index: index)
        } else {
            addListView.SelectColor(index: index)
        }
    }


    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
