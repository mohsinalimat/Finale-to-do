//
//  ICloudSyncConfirmationViewController.swift
//  Finale To-do
//
//  Created by Grant Oganan on 5/2/22.
//

import Foundation
import UIKit

class ICloudSyncConfirmationViewController: UIViewController {
    
    let padding = 16.0
    
    let onCancelled: (()->Void)
    let onConfirm: (()->Void)
    let onDecline: (()->Void)
    
    var pickedChoice = false
    
    init(lastICloudSync: Date, deviceName: String, OnCancelled: @escaping (() -> Void), OnConfirm: @escaping (() -> Void), OnDecline: @escaping (() -> Void) ) {
        self.onCancelled = OnCancelled
        self.onConfirm = OnConfirm
        self.onDecline = OnDecline
        
        super.init(nibName: nil, bundle: nil)
        
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        self.view.backgroundColor = .systemGray6
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        containerView.backgroundColor = self.view.backgroundColor
        
        let titleLable = UILabel(frame: CGRect(x: padding, y: padding, width: width-padding*2, height: 20))
        titleLable.text = "Latest iCloud Sync\n\(deviceName) on " + formattedDate(date: lastICloudSync)
        titleLable.font = .preferredFont(forTextStyle: .headline)
        titleLable.textAlignment = .center
        titleLable.numberOfLines = 0
        titleLable.sizeToFit()
        titleLable.frame.origin.x = 0.5*(width-titleLable.frame.width)
        
        let descriptionLabel = UILabel(frame: CGRect(x: padding, y: titleLable.frame.maxY + padding, width: width-padding*2, height: 20))
        descriptionLabel.text = "Would you like to replace data on this device with the latest backup from iCloud?\n\nOr, keep data on this device and use it to replace data in iCloud?"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.frame.origin.x = 0.5*(width-descriptionLabel.frame.width)
        
        let keepDataButton = UIButton()
        if #available(iOS 15.0, *) {
            keepDataButton.frame = CGRect(x: padding, y: height * 0.5 - padding - 45.0, width: width-padding*2, height: 45)
        } else {
            keepDataButton.frame = CGRect(x: padding, y: height - padding*6 - 45.0, width: width-padding*2, height: 45)
        }
        keepDataButton.backgroundColor = .systemGray2
        keepDataButton.setTitle("Replace data in iCloud", for: .normal)
        keepDataButton.tintColor = .white
        keepDataButton.setTitleColor(.systemGray, for: .highlighted)
        keepDataButton.addTarget(self, action: #selector(Decline), for: .touchUpInside)
        keepDataButton.layer.cornerRadius = 10
        
        let loadFromICloudButton = UIButton(frame: CGRect(x: padding, y: keepDataButton.frame.origin.y - keepDataButton.frame.height - padding, width: width-padding*2, height: 45))
        loadFromICloudButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: .defaultColor)
        loadFromICloudButton.setTitle("Replace data on this device", for: .normal)
        loadFromICloudButton.tintColor = .white
        loadFromICloudButton.setTitleColor(.systemGray, for: .highlighted)
        loadFromICloudButton.addTarget(self, action: #selector(Confirm), for: .touchUpInside)
        loadFromICloudButton.layer.cornerRadius = 10
        
        containerView.addSubview(titleLable)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(loadFromICloudButton)
        containerView.addSubview(keepDataButton)
        
        self.view.addSubview(containerView)
    }
    
    func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !pickedChoice {
            onCancelled()
        }
    }
    
    @objc func Confirm () {
        onConfirm()
        pickedChoice = true
        self.dismiss(animated: true)
    }
    
    @objc func Decline () {
        onDecline()
        pickedChoice = true
        self.dismiss(animated: true)
    }
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
