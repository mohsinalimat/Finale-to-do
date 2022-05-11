//
//  WelcomeScreenViewController.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/9/22.
//

import Foundation
import UIKit

class WelcomeScreenNavController: UINavigationController {
    
    init() {
        super.init(rootViewController: WelcomeScreenFirstPage())
        self.isModalInPresentation = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: First page
class WelcomeScreenFirstPage: UIViewController {
    
    let padding = 16.0
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemBackground
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0.35*frameHeight, width: frameWidth-padding*2, height: 26))
        titleLabel.text = "Welcome to"
        titleLabel.textAlignment = .center
        titleLabel.font = .Rubik(weight: .semibold, size: 26)
        
        let finaleLabel = UILabel(frame: CGRect(x: padding, y: titleLabel.frame.maxY+padding*2, width: frameWidth-padding*2, height: 50))
        finaleLabel.text = "Finale"
        finaleLabel.font = .Rubik(weight: .semibold, size: 50)
        finaleLabel.textColor = .defaultColor
        finaleLabel.textAlignment = .center
        
        let imageSize = frameWidth*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frameWidth-imageSize), y: titleLabel.frame.origin.y - padding*2 - imageSize, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "Welcome Screen")
        imageView.contentMode = .scaleAspectFit
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: finaleLabel.frame.maxY + padding*2, width: frameWidth-padding*2, height: 20))
        descriptionLabel.text = "A minimalistic, yet powerful task manager.\n\nLet's make it perfect for you."
        descriptionLabel.font = .Rubik
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(frameWidth-descriptionLabel.frame.width)
        
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        
        let continueButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        continueButton.backgroundColor = .defaultColor
        continueButton.setTitle("Let's do it!", for: .normal)
        continueButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(ContinueButtonTap), for: .touchUpInside)
        continueButton.titleLabel!.font = .Rubik(size: 18)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(finaleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(continueButton)
    }
    
    @objc func SkipButtonTap () {
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func ContinueButtonTap () {
        self.navigationController?.show(WelcomeScreenNamePage(), sender: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



//MARK: Name page
class WelcomeScreenNamePage: UIViewController, UITextFieldDelegate {
    
    let padding = 16.0
    
    var firstNameField: UITextField!
    var lastNameField: UITextField!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemBackground
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0.35*frameHeight, width: frameWidth-padding*2, height: 64))
        titleLabel.text = "Let's get to know\neach other"
        titleLabel.textAlignment = .center
        titleLabel.font = .Rubik(weight: .semibold, size: 26)
        titleLabel.numberOfLines = 2
        
        let imageSize = frameWidth*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frameWidth-imageSize), y: titleLabel.frame.origin.y - padding*2 - imageSize, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "Get to know each other")
        imageView.contentMode = .scaleAspectFit
        
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        let skipButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        skipButton.backgroundColor = UIColor.systemGray3
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(SkipButtonTap), for: .touchUpInside)
        skipButton.titleLabel?.font = .Rubik(size: 18)
        
        let continueButton = UIButton(frame: CGRect(x: padding, y: skipButton.frame.origin.y - padding*0.5 - buttonSize, width: frameWidth-padding*2, height: buttonSize))
        continueButton.backgroundColor = .defaultColor
        continueButton.setTitle("Next", for: .normal)
        continueButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(ContinueButtonTap), for: .touchUpInside)
        continueButton.titleLabel?.font = .Rubik(size: 18)
        
        let firstNameIF = DrawInputField(frame: CGRect(x: padding, y: titleLabel.frame.maxY+padding*2, width: frameWidth-padding*2, height: 40), placeholder: "First Name")
        
        let lastNameIF = DrawInputField(frame: CGRect(x: padding, y: firstNameIF.frame.maxY+padding*0.5, width: frameWidth-padding*2, height: 40), placeholder: "Last Name")
        
        let footerLabel = UILabel(frame: CGRect(x: padding*2, y: lastNameIF.frame.maxY + padding*0.5, width: frameWidth-padding*4, height: 0))
        footerLabel.font = .Rubik(size: 12)
        footerLabel.textColor = .systemGray
        footerLabel.numberOfLines = 0
        footerLabel.text = "Finale uses your name to personalize your experience. You can always change it later."
        footerLabel.sizeToFit()
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(continueButton)
        self.view.addSubview(skipButton)
        self.view.addSubview(firstNameIF)
        self.view.addSubview(lastNameIF)
        self.view.addSubview(footerLabel)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TapAnywhere)))
    }
    
    @objc func SkipButtonTap () {
        self.navigationController?.show(WelcomeScreenNotificationsPage(), sender: nil)
    }
    
    @objc func ContinueButtonTap () {
        self.navigationController?.show(WelcomeScreenNotificationsPage(), sender: nil)
        
        App.settingsConfig.userFirstName = firstNameField.text ?? ""
        App.settingsConfig.userLastName = lastNameField.text ?? ""
    }
    
    @objc func TapAnywhere () {
        self.view.endEditing(true)
    }
    
    func DrawInputField (frame: CGRect, placeholder: String) -> UIView {
        let container = UIView(frame: frame)
        container.layer.cornerRadius = 8
        container.backgroundColor = .systemGray5
        
        let inputField = UITextField(frame: CGRect(x: padding, y: 0, width: container.frame.width-padding*2, height: container.frame.height))
        inputField.placeholder = placeholder
        inputField.delegate = self
        
        if placeholder == "First Name" {
            firstNameField = inputField
        } else if placeholder == "Last Name" {
            lastNameField = inputField
        }
        
        container.addSubview(inputField)
        
        return container
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: Notification page
class WelcomeScreenNotificationsPage: UIViewController {
    
    let padding = 16.0
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemBackground
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0.35*frameHeight, width: frameWidth-padding*2, height: 64))
        titleLabel.text = "Enable Notifications"
        titleLabel.textAlignment = .center
        titleLabel.font = .Rubik(weight: .semibold, size: 26)
        titleLabel.numberOfLines = 2
        
        let imageSize = frameWidth*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frameWidth-imageSize), y: titleLabel.frame.origin.y - padding*2 - imageSize, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "Notifications")
        imageView.contentMode = .scaleAspectFit
        
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        let skipButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        skipButton.backgroundColor = UIColor.systemGray3
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(SkipButtonTap), for: .touchUpInside)
        skipButton.titleLabel?.font = .Rubik(size: 18)
        
        let continueButton = UIButton(frame: CGRect(x: padding, y: skipButton.frame.origin.y - padding*0.5 - buttonSize, width: frameWidth-padding*2, height: buttonSize))
        continueButton.backgroundColor = .defaultColor
        continueButton.setTitle("Enable notifications", for: .normal)
        continueButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(ContinueButtonTap), for: .touchUpInside)
        continueButton.titleLabel?.font = .Rubik(size: 18)
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding*2, y: titleLabel.frame.maxY + padding*2, width: frameWidth-padding*4, height: 0))
        descriptionLabel.font = .Rubik
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Finale can send you notifications to help complete tasks on time.\n\nFinale will never send you any useless spam. You will only recieve important alerts that you set yourself."
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(frameWidth-descriptionLabel.frame.width)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(continueButton)
        self.view.addSubview(skipButton)
        self.view.addSubview(descriptionLabel)
    }
    
    @objc func SkipButtonTap () {
        self.navigationController?.show(WelcomeScreenCloudSyncPage(), sender: nil)
    }
    
    @objc func ContinueButtonTap () {
        NotificationHelper.RequestNotificationAccess() {
            self.navigationController?.show(WelcomeScreenCloudSyncPage(), sender: nil)
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: Cloud sync page
class WelcomeScreenCloudSyncPage: UIViewController {
    
    let padding = 16.0
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemBackground
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0.35*frameHeight, width: frameWidth-padding*2, height: 64))
        titleLabel.text = "Enable iCloud Sync"
        titleLabel.textAlignment = .center
        titleLabel.font = .Rubik(weight: .semibold, size: 26)
        titleLabel.numberOfLines = 2
        
        let imageSize = frameWidth*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frameWidth-imageSize), y: titleLabel.frame.origin.y - padding*2 - imageSize, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "Cloud sync")
        imageView.contentMode = .scaleAspectFit
        
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        let skipButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        skipButton.backgroundColor = UIColor.systemGray3
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(SkipButtonTap), for: .touchUpInside)
        skipButton.titleLabel?.font = .Rubik(size: 18)
        
        let continueButton = UIButton(frame: CGRect(x: padding, y: skipButton.frame.origin.y - padding*0.5 - buttonSize, width: frameWidth-padding*2, height: buttonSize))
        continueButton.backgroundColor = .defaultColor
        continueButton.setTitle("Enable iCloud sync", for: .normal)
        continueButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(ContinueButtonTap), for: .touchUpInside)
        continueButton.titleLabel?.font = .Rubik(size: 18)
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding*2, y: titleLabel.frame.maxY + padding*2, width: frameWidth-padding*4, height: 0))
        descriptionLabel.font = .Rubik
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Finale can securely backup your data in iCloud. This way all your tasks will be available across different devices."
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(frameWidth-descriptionLabel.frame.width)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(continueButton)
        self.view.addSubview(skipButton)
        self.view.addSubview(descriptionLabel)
    }
    
    @objc func SkipButtonTap () {
        self.navigationController?.show(WelcomeScreenAllSetPage(), sender: nil)
    }
    
    @objc func ContinueButtonTap () {
        self.navigationController?.show(WelcomeScreenAllSetPage(), sender: nil)
        App.settingsConfig.isICloudSyncOn = true
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//MARK: All set page
class WelcomeScreenAllSetPage: UIViewController {
    
    let padding = 16.0
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .systemBackground
        
        let frameWidth = self.view.frame.width
        let frameHeight = self.view.frame.height
        
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0.35*frameHeight, width: frameWidth-padding*2, height: 64))
        titleLabel.text = "All Set"
        titleLabel.textAlignment = .center
        titleLabel.font = .Rubik(weight: .semibold, size: 26)
        titleLabel.numberOfLines = 2
        
        let imageSize = frameWidth*0.5
        let imageView = UIImageView(frame: CGRect(x: 0.5*(frameWidth-imageSize), y: titleLabel.frame.origin.y - padding*2 - imageSize, width: imageSize, height: imageSize))
        imageView.image = UIImage(named: "All Set")
        imageView.contentMode = .scaleAspectFit
        
        let bottomPadding = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let buttonSize = 40.0
        let skipButton = UIButton(frame: CGRect(x: padding, y: frameHeight - bottomPadding - buttonSize*3, width: frameWidth-padding*2, height: buttonSize))
        skipButton.backgroundColor = UIColor.systemGray3
        skipButton.setTitle("I'll figure it out myself", for: .normal)
        skipButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(SkipButtonTap), for: .touchUpInside)
        skipButton.titleLabel?.font = .Rubik(size: 18)
        
        let continueButton = UIButton(frame: CGRect(x: padding, y: skipButton.frame.origin.y - padding*0.5 - buttonSize, width: frameWidth-padding*2, height: buttonSize))
        continueButton.backgroundColor = .defaultColor
        continueButton.setTitle("Show me around!", for: .normal)
        continueButton.setTitleColor(UIColor.systemGray, for: .highlighted)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(ContinueButtonTap), for: .touchUpInside)
        continueButton.titleLabel?.font = .Rubik(size: 18)
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding*2, y: titleLabel.frame.maxY + padding*2, width: frameWidth-padding*4, height: 0))
        descriptionLabel.font = .Rubik
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "Perfect! Would you like to go for a quick tour around the app to learn how to use Finale?"
        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.x = 0.5*(frameWidth-descriptionLabel.frame.width)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(continueButton)
        self.view.addSubview(skipButton)
        self.view.addSubview(descriptionLabel)
    }
    
    @objc func SkipButtonTap () {
        App.settingsConfig.completedInitialSetup = true
        App.instance.SelectTaskList(index: 0)
        App.instance.sideMenuView.userPanel.ReloadName()
        App.instance.SaveSettings()
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func ContinueButtonTap () {
        App.settingsConfig.completedInitialSetup = true
        App.instance.SelectTaskList(index: 0)
        App.instance.sideMenuView.userPanel.ReloadName()
        App.instance.SaveSettings()
        self.navigationController?.dismiss(animated: true)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
