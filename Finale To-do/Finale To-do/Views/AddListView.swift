//
//  AddListView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/16/22.
//

import Foundation
import UIKit

class AddListView: UIView, UITextFieldDelegate {
    
    let padding = 16.0
    let rowHeight = 36.0
    
    
    var blackoutPanel: UIView!
    var contentView: UIView!
    var inputField: UITextField!
    var colorSwatches = [Swatch]()
    var iconSwatches = [Swatch]()
    
    let placeholders: [String] = ["Work", "Family", "Sports club", "Hobbies", "Home", "Shopping list"]
    
    let icons: [String] = ["folder.fill", "book.closed.fill", "heart.fill", "paperplane.fill", "calendar", "rectangle.fill.on.rectangle.fill", "trash.fill", "alarm.fill", "hourglass", "bolt.fill", "person.fill", "bag.fill", "tray.full.fill", "archivebox.fill", "graduationcap.fill", "briefcase.fill"]
    
    let colors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.defaultColor, UIColor.cyan, UIColor.yellow, UIColor.black, UIColor.green, UIColor.white, UIColor.red, UIColor.blue, UIColor.defaultColor, UIColor.cyan, UIColor.yellow, UIColor.black, UIColor.green, UIColor.white]
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height+10, width: frame.width, height: frame.height))
        contentView.layer.cornerRadius = 30
        contentView.backgroundColor = .defaultColor.thirdColor
        contentView.layer.shadowOffset = CGSize.zero
        contentView.layer.shadowRadius = 7
        contentView.layer.shadowOpacity = 0.5
        
        let handleWidth = 50.0
        let handle = UIView(frame: CGRect(x: 0.5*(frame.width-handleWidth), y: padding, width: handleWidth, height: 3))
        handle.layer.cornerRadius = 1.5
        handle.backgroundColor = .defaultColor.secondaryColor
        
        contentView.addSubview(handle)
        
        let headerTitle = UILabel(frame: CGRect(x: padding, y: handle.frame.maxY+padding*0.5, width: frame.width-padding*2, height: rowHeight*0.5))
        headerTitle.text = "Create new list"
        headerTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        headerTitle.textAlignment = .center
        headerTitle.textColor = .white
        
        contentView.addSubview(headerTitle)
        
        let titleLabel = DrawTitle(frame: frame, prevFrame: headerTitle.frame, title: "Title")
        contentView.addSubview(titleLabel)
        
        inputField = UITextField(frame: CGRect(x: padding, y: titleLabel.frame.maxY+padding*0.3, width: frame.width-padding*2, height: rowHeight))
        inputField.delegate = self
        inputField.textColor = .white
        inputField.attributedPlaceholder = NSAttributedString(
            string: placeholders[Int.random(in: 0..<placeholders.count)],
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        inputField.backgroundColor = .defaultColor.secondaryColor
        inputField.layer.cornerRadius = 10
        inputField.setLeftPaddingPoints(padding*0.5)
        
        contentView.addSubview(inputField)
        
        let colorLabel = DrawTitle(frame: frame, prevFrame: inputField.frame, title: "Color")
        contentView.addSubview(colorLabel)
        
        let colorSwatches = DrawSwatches(frame: frame, prevFrame: colorLabel.frame, color: true)
        contentView.addSubview(colorSwatches)
        
        let iconLabel = DrawTitle(frame: frame, prevFrame: colorSwatches.frame, title: "Icon")
        contentView.addSubview(iconLabel)
        
        let iconSwatches = DrawSwatches(frame: frame, prevFrame: iconLabel.frame, icon: true)
        contentView.addSubview(iconSwatches)
        
        let buttonWidth = (frame.width-padding*3)*0.5
        let cancelButton = UIButton(frame: CGRect(x: padding, y: iconSwatches.frame.maxY+padding*2, width: buttonWidth, height: rowHeight))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.backgroundColor = .systemGray
        cancelButton.addTarget(self, action: #selector(Dismiss), for: .touchUpInside)
        
        let createButton = UIButton(frame: CGRect(x: padding*2+cancelButton.frame.width, y: cancelButton.frame.origin.y, width: buttonWidth, height: rowHeight))
        createButton.setTitle("Create", for: .normal)
        createButton.layer.cornerRadius = 8
        createButton.backgroundColor = .defaultColor
        createButton.isEnabled = inputField.text != ""
        
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        
        blackoutPanel = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blackoutPanel.backgroundColor = .black
        blackoutPanel.alpha = 0
        
//        self.addSubview(blackoutPanel)
        self.addSubview(contentView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
            blackoutPanel.alpha = 0.5
            contentView.frame.origin.y -= contentView.frame.height+10
        }, completion: { [self] _ in
            inputField.becomeFirstResponder()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func DrawTitle(frame: CGRect, prevFrame: CGRect, title: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: padding, y: prevFrame.maxY+padding, width: frame.width-padding*2, height: rowHeight))
        label.textColor = .white
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        return label
    }
    
    func DrawSwatches(frame: CGRect, prevFrame: CGRect, color: Bool = false, icon: Bool = false) -> UIView {
        let spacing = 10.0
        
        let nRows = 2
        let nColumns = 8
        
        let containerWidth = frame.width-padding*2
        let swatchSize = (containerWidth - spacing*CGFloat(nColumns-1) ) / CGFloat(nColumns)
        
        let containerView = UIView(frame: CGRect(x: padding, y: prevFrame.maxY+padding*0.3, width: containerWidth, height: swatchSize*2+spacing))
        
        for row in 0..<nRows {
            for column in 0..<nColumns {
                let swatch = Swatch(
                    frame: CGRect(
                        x: CGFloat(column)*spacing + swatchSize*CGFloat(column),
                        y: CGFloat(row)*spacing + swatchSize*CGFloat(row),
                        width: swatchSize,
                        height: swatchSize),
                    index: column + row*8,
                    addListView: self,
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
    
    func SelectColor(index: Int) {
        for swatch in colorSwatches {
            swatch.isSelected = false
        }
        colorSwatches[index].isSelected = true
    }
    func SelectIcon(index: Int) {
        for swatch in iconSwatches {
            swatch.isSelected = false
        }
        iconSwatches[index].isSelected = true
    }
    
    @objc func Dismiss () {
        inputField.resignFirstResponder()
        print("ASD")
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [self] in
            contentView.frame.origin.y = UIScreen.main.bounds.height + 10
            blackoutPanel.alpha = 0
        }, completion: { [self] _ in
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
            let imageSize = getImageFrameSize(image: UIImage(systemName: icon)!, targetSize: CGSize(width: frame.width*0.6, height: frame.height*0.6))
            
            let iconView = UIImageView(frame: CGRect(x: 0.5*(frame.width-imageSize.width), y: 0.5*(frame.height-imageSize.height), width: imageSize.width, height: imageSize.height))
            iconView.image = UIImage(systemName: icon)
            iconView.tintColor = .white
            iconView.isUserInteractionEnabled = false
            self.addSubview(iconView)
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Select))
        self.addGestureRecognizer(tap)
        
        isSelected = false
    }
    
    func SetColors () {
        self.backgroundColor = isSelected ? .white : color == .clearInteractive ? .defaultColor : color
        insideCircle.backgroundColor = isSelected ? .defaultColor.thirdColor : .clear
        colorCircle.backgroundColor = color == .clearInteractive ? .defaultColor : color
    }
    
    @objc func Select() {
        print("ASD")
        if color == UIColor.clearInteractive {
            addListView.SelectIcon(index: index)
        } else {
            addListView.SelectColor(index: index)
        }
    }

    
    func getImageFrameSize(image: UIImage, targetSize: CGSize) -> CGSize {
        let scaleFactorWidth = targetSize.width / image.size.width
        let scaleFactorHeight = targetSize.height / image.size.height
        
        if scaleFactorWidth < scaleFactorHeight {
            return CGSize(width: targetSize.width, height: image.size.height*scaleFactorWidth)
        } else {
            return CGSize(width: image.size.width*scaleFactorHeight, height: targetSize.height)
        }
    }


    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
