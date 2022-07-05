//
//  AppUpdatedViewController.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/15/22.
//

import Foundation
import UIKit

class AppUpdatedViewController: UIViewController {
    
    let padding = 16.0
    let changeLog: ChangeLog
    
    init(changeLog: ChangeLog) {
        self.changeLog = changeLog
        super.init(nibName: nil, bundle: nil)
        
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        self.view.backgroundColor = .systemBackground
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0.4*frameHeight, width: frameWidth-padding*2, height: 26))
        titleLabel.attributedText = titleLabelText
        titleLabel.textAlignment = .center
        titleLabel.font = .Rubik(weight: .semibold, size: 26)
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: titleLabel.frame.maxY + padding, width: frameWidth-padding*2, height: 26))
        descriptionLabel.text = "Here is what's new:"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .Rubik(size: 16)
        
        let imageSize = frameWidth*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frameWidth-imageSize), y: titleLabel.frame.origin.y - padding*4 - imageSize, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "Welcome Screen")
        imageView.contentMode = .scaleAspectFit
        
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        
        let continueButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        continueButton.backgroundColor = .defaultColor
        continueButton.setTitle("Great!", for: .normal)
        continueButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(ContinueButtonTap), for: .touchUpInside)
        continueButton.titleLabel!.font = .Rubik(size: 18)
        
        let maxHeight = continueButton.frame.origin.y - descriptionLabel.frame.maxY - padding*2
        let maxWidth = frameWidth-padding*4
        let logsLabel = UILabel(frame: CGRect(x: padding*2, y: descriptionLabel.frame.maxY + padding, width: maxWidth, height: maxHeight))
        logsLabel.text = changeLogsText
        logsLabel.font = .Rubik(size: 16)
        logsLabel.numberOfLines = 0
        logsLabel.sizeToFit()
        if logsLabel.frame.height > maxHeight {
            logsLabel.frame.size = CGSize(width: maxWidth, height: maxHeight)
            logsLabel.adjustsFontSizeToFitWidth = true
        }
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(logsLabel)
        self.view.addSubview(continueButton)
    }
    
    @objc func ContinueButtonTap () {
        self.dismiss(animated: true)
    }
    
    var changeLogsText: String {
        var output = ""
        for log in changeLog.change_logs {
            output += "- \(log)\n\n"
        }
        if output.count > 2 { output.removeLast(); output.removeLast() }
        return output
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var titleLabelText: NSMutableAttributedString {
        var attString = NSMutableAttributedString(string: "Finale To Do")
        attString.SetColor(color: .defaultColor)
        attString.append(NSAttributedString(string: " was updated"))
        return attString
    }
}
