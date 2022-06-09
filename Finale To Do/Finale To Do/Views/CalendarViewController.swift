//
//  CalendarView.swift
//  Finale To-do
//
//  Created by Grant Oganan on 4/19/22.
//

import Foundation
import UIKit

class CalendarViewController: UIViewController, UIDynamicTheme {
    
    let padding = 16.0
    
    var backgroundView: UIView!
    var containerView: UIView!
    
    var firstPageView: UIView!
    var notificationPageView: UIView!
    var repeatPageView: UIView!
    
    var notificationSelectoinRows = [SettingsSelectionRow]()
    var selectedNotificationTypes = [NotificationType]()
    
    var repeatSelectionRows = [SettingsSelectionRow]()
    var selectedRepeatTypes = [TaskRepeatType]()
    
    var confirmButton: UIButton!
    var calendarView: UIDatePicker!
    var dueTimePicker: UIDatePicker!
    var dueTimetoggle: UISwitch!
    var notificationRow: UIView!
    var notificationStatusLabel: UILabel!
    var repeatRow: UIView!
    var repeatStatusLabel: UILabel!
    
    let taskSlider: TaskSlider
    let taskSliderContextMenu: TaskSliderContextMenu?
    
    var accentColor: UIColor!
    
    init(tintColor: UIColor, taskSlider: TaskSlider, taskSliderContextMenu: TaskSliderContextMenu?) {
        self.taskSlider = taskSlider
        self.accentColor = tintColor
        self.taskSliderContextMenu = taskSliderContextMenu
        for (notificationType, _) in taskSlider.task.notifications {
            self.selectedNotificationTypes.append(notificationType)
        }
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = App.settingsConfig.interface == .System ? .unspecified : App.settingsConfig.interface == .Light ? .light : .dark
        SharedInit(tintColor: tintColor, taskSlider: taskSlider)
    }
    
    func SharedInit(tintColor: UIColor, taskSlider: TaskSlider) {
        let containerWidth = UIScreen.main.bounds.width * 0.8
        
        let blurEffect = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        blurEffect.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurEffect.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HideViewNoAction)))
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        self.view.addSubview(blurEffect)
        
        
        containerView = UIView ()
        containerView.clipsToBounds = true
        
        firstPageView = UIView()
        firstPageView.layer.cornerRadius = 20
        
        calendarView = UIDatePicker()
        calendarView.preferredDatePickerStyle = .inline
        calendarView.frame = CGRect(x: padding*0.5, y: 0, width: containerWidth-padding, height: containerWidth)
        calendarView.tintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tintColor)
        calendarView.datePickerMode = .date
        if taskSlider.task.isDateAssigned { calendarView.date = taskSlider.task.dateAssigned }
        
        let timeDueRow = DrawDueTimeRow(prevMaxY: calendarView.frame.maxY-padding, rowWidth: containerWidth-padding*2)
        notificationRow = DrawNotificationRow(prevMaxY: timeDueRow.frame.maxY, rowWidth: containerWidth)
        repeatRow = DrawRepeatRow(prevMaxY: notificationRow.frame.maxY, rowWidth: containerWidth)
        
        let buttonHeight = 40.0
        let buttonWidth = 0.5*(containerWidth-padding*3)
        let clearButton = UIButton(frame: CGRect(x: padding, y: repeatRow.frame.maxY + padding, width: buttonWidth, height: buttonHeight))
        clearButton.backgroundColor = .systemGray2
        clearButton.setTitle(" Clear", for: .normal)
        clearButton.setTitleColor(.systemGray, for: .highlighted)
        clearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.tintColor = .white
        clearButton.layer.cornerRadius = 10
        clearButton.addTarget(self, action: #selector(Clear), for: .touchUpInside)
        clearButton.imageView!.layer.borderWidth = 0 // this is a weird fix for image scaling when opening the calendar view
        
        confirmButton = UIButton(frame: CGRect(x: clearButton.frame.maxX + padding, y: clearButton.frame.origin.y, width: buttonWidth, height: buttonHeight))
        confirmButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: tintColor)
        confirmButton.setTitle(" Assign", for: .normal)
        confirmButton.setTitleColor(.systemGray, for: .highlighted)
        confirmButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        confirmButton.tintColor = .white
        confirmButton.layer.cornerRadius = 10
        confirmButton.addTarget(self, action: #selector(Confirm), for: .touchUpInside)
        confirmButton.imageView!.layer.borderWidth = 0 // this is a weird fix for image scaling when opening the calendar view
        
        let containerHeight = confirmButton.frame.maxY + padding
        containerView.frame = CGRect(x: 0.5*(UIScreen.main.bounds.width-containerWidth), y: 0.5*(UIScreen.main.bounds.height-containerHeight), width: containerWidth, height: containerHeight)
        firstPageView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight-confirmButton.frame.height-padding*2)
        
        let blurEffect2 = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        blurEffect2.effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 20).cgPath
        blurEffect2.layer.mask = shapeLayer
        
        backgroundView = UIView(frame: containerView.frame)
        backgroundView.layer.cornerRadius = 20
        backgroundView.layer.shadowOffset = CGSize.zero
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowOpacity = 0.5
        
        backgroundView.addSubview(blurEffect2)
        
        firstPageView.addSubview(calendarView)
        firstPageView.addSubview(timeDueRow)
        firstPageView.addSubview(notificationRow)
        firstPageView.addSubview(repeatRow)
        
        notificationPageView = DrawNotificationSelectionPage(size: CGSize(width: firstPageView.frame.width, height: firstPageView.frame.height))
        repeatPageView = DrawRepeatingSelectionPage(size: notificationPageView.frame.size)
        
        containerView.addSubview(clearButton)
        containerView.addSubview(confirmButton)
        containerView.addSubview(notificationPageView)
        containerView.addSubview(repeatPageView)
        containerView.addSubview(firstPageView)
        
        self.view.addSubview(backgroundView)
        self.view.addSubview(containerView)
        
        ShowView()
    }
    
    func DrawDueTimeRow (prevMaxY: CGFloat, rowWidth: CGFloat) -> UIView {
        let rowHeight = 45.0
        let view = UIView()
        view.frame = CGRect(x: padding, y: prevMaxY, width: rowWidth, height: rowHeight)
        
        dueTimetoggle = UISwitch()
        dueTimetoggle.frame.origin.x = rowWidth - dueTimetoggle.frame.width
        dueTimetoggle.frame.origin.y += 0.5*(rowHeight-dueTimetoggle.frame.height)
        dueTimetoggle.addTarget(self, action: #selector(DueTimeToggle), for: .valueChanged)
        dueTimetoggle.onTintColor = accentColor
        dueTimetoggle.isOn = taskSlider.task.isDueTimeAssigned
        
        dueTimePicker = UIDatePicker()
        dueTimePicker.preferredDatePickerStyle = .inline
        dueTimePicker.tintColor = accentColor
        dueTimePicker.datePickerMode = .time
        dueTimePicker.frame = CGRect(x: 0, y: 0.5*(rowHeight-dueTimePicker.frame.height), width: rowWidth - dueTimetoggle.frame.width, height: dueTimePicker.frame.height)
        if taskSlider.task.isDueTimeAssigned {
            dueTimePicker.setDate(taskSlider.task.dateAssigned, animated: false)
        } else {
            dueTimePicker.setDate(Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date.now)!, animated: false)
        }
        dueTimePicker.isEnabled = taskSlider.task.isDueTimeAssigned
        
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rowWidth*0.5, height: rowHeight))
        titleLabel.text = "Due time"
        
        
        view.addSubview(titleLabel)
        view.addSubview(dueTimePicker)
        view.addSubview(dueTimetoggle)
        
        return view
    }
    
    func DrawNotificationRow (prevMaxY: CGFloat, rowWidth: CGFloat) -> UIView {
        let rowHeight = 45.0
        let paddedRowWidth = rowWidth-padding*2
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: prevMaxY, width: rowWidth, height: rowHeight)
        view.backgroundColor = .clear
        
        
        let notifWidth: CGFloat = "Notifications".size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .body)]).width
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0, width: notifWidth, height: rowHeight))
        titleLabel.text = "Notifications"
        
        notificationStatusLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: paddedRowWidth*0.965-titleLabel.frame.width-padding*1.5, height: rowHeight))
        notificationStatusLabel.text = notificationStatusLabelText
        notificationStatusLabel.font = UIFont.systemFont(ofSize: 14)
        notificationStatusLabel.textColor = .systemGray
        notificationStatusLabel.textAlignment = .right
        
        let iconHeight = rowHeight*0.3
        let arrowIcon = UIImageView(frame: CGRect(x: paddedRowWidth*0.965+padding, y: 0.5*(rowHeight-iconHeight), width: paddedRowWidth*0.035, height: iconHeight))
        arrowIcon.image = UIImage(systemName: "greaterthan")
        arrowIcon.tintColor = .systemGray2
        
        view.addSubview(titleLabel)
        view.addSubview(notificationStatusLabel)
        view.addSubview(arrowIcon)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(TapGestureNatificationRow))
        gesture.minimumPressDuration = 0
        view.addGestureRecognizer(gesture)
        
        return view
    }
    
    var notificationStatusLabelText: String {
        if selectedNotificationTypes.count == 0 {
            return "None"
        } else if selectedNotificationTypes.count == 1 {
            return selectedNotificationTypes.first!.str
        } else {
            return "\(selectedNotificationTypes.count) selected"
        }
    }
    
    func DrawRepeatRow (prevMaxY: CGFloat, rowWidth: CGFloat) -> UIView {
        let rowHeight = 45.0
        let paddedRowWidth = rowWidth-padding*2
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: prevMaxY, width: rowWidth, height: rowHeight)
        view.backgroundColor = .clear
        
        
        let notifWidth: CGFloat = "Repeat".size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .body)]).width
        let titleLabel = UILabel(frame: CGRect(x: padding, y: 0, width: notifWidth, height: rowHeight))
        titleLabel.text = "Repeat"
        
        repeatStatusLabel = UILabel(frame: CGRect(x: titleLabel.frame.maxX + padding, y: 0, width: paddedRowWidth*0.965-titleLabel.frame.width-padding*1.5, height: rowHeight))
        repeatStatusLabel.text = repeatStatusLabelText
        repeatStatusLabel.font = UIFont.systemFont(ofSize: 14)
        repeatStatusLabel.textColor = .systemGray
        repeatStatusLabel.textAlignment = .right
        
        let iconHeight = rowHeight*0.3
        let arrowIcon = UIImageView(frame: CGRect(x: paddedRowWidth*0.965+padding, y: 0.5*(rowHeight-iconHeight), width: paddedRowWidth*0.035, height: iconHeight))
        arrowIcon.image = UIImage(systemName: "greaterthan")
        arrowIcon.tintColor = .systemGray2
        
        view.addSubview(titleLabel)
        view.addSubview(repeatStatusLabel)
        view.addSubview(arrowIcon)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(TapGestureRepeatRow))
        gesture.minimumPressDuration = 0
        view.addGestureRecognizer(gesture)
        
        return view
    }
    
    var repeatStatusLabelText: String {
        return "None"
    }
    
    func DrawNotificationSelectionPage (size: CGSize) -> UIView {
        let view = UIView(frame: CGRect(x: size.width, y: 0, width: size.width, height: size.height))
        view.layer.cornerRadius = 20
        
        let notifWidth: CGFloat = "Notifications".size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .headline)]).width
        let titleLabel = UILabel(frame: CGRect(x: 0.5*(size.width-notifWidth), y: padding, width: notifWidth, height: 20))
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.text = "Notifications"
        titleLabel.textAlignment = .center
        
        let backButton = UIButton(frame: CGRect(x: padding-10, y: titleLabel.frame.origin.y + 0.5*(titleLabel.frame.height-padding*2), width: padding*2, height: padding*2))
        backButton.contentVerticalAlignment = .fill
        backButton.contentHorizontalAlignment = .fill
        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        backButton.setImage(UIImage(systemName: "lessthan"), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(TapBackNotificationPage), for: .touchUpInside)
        
        notificationSelectoinRows.removeAll()
        let noneRow = SettingsSelectionRow(
            frame: CGRect(x: 0, y: titleLabel.frame.maxY + padding, width: size.width, height: 40.0),
            title: "None",
            index: -1,
            isSelected: taskSlider.task.notifications.count == 0,
            isNone: true,
            onSelect: SelectNotificationType,
            onDeselect: DeselectNotificationType)
        view.addSubview(noneRow)
        notificationSelectoinRows.append(noneRow)
        
        let start = taskSlider.task.isDueTimeAssigned ? 0 : 5
        let end = taskSlider.task.isDueTimeAssigned ? 5 : 10
        for i in start..<end {
            let row = SettingsSelectionRow(
                frame: CGRect(x: 0, y: noneRow.frame.maxY + padding + Double(taskSlider.task.isDueTimeAssigned ? i : i-5)*50.0, width: size.width, height: 40.0),
                title: NotificationType(rawValue: i)!.str,
                accentColor: accentColor,
                index: i,
                isSelected: taskSlider.task.containsNotification(notificationType: NotificationType(rawValue: i)!),
                isNone: false,
                onSelect: SelectNotificationType,
                onDeselect: DeselectNotificationType)
            view.addSubview(row)
            notificationSelectoinRows.append(row)
        }
        
        view.addSubview(titleLabel)
        view.addSubview(backButton)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DragNotificationPage))
        pan.minimumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        
        return view
    }
    
    var originXnotif = 0.0
    var originX1notif = 0.0
    @objc func DragNotificationPage (sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            originXnotif = notificationPageView.frame.origin.x
            originX1notif = firstPageView.frame.origin.x
        } else if sender.state == .changed {
            notificationPageView.frame.origin.x = max(0, min(originXnotif + sender.translation(in: self.view).x, notificationPageView.frame.width))
            firstPageView.frame.origin.x = max(-notificationPageView.frame.width, min(originX1notif + sender.translation(in: self.view).x, 0))
        } else if sender.state == .ended {
            if notificationPageView.frame.origin.x >= notificationPageView.frame.width*0.2 { CloseNotificationSelectionPage() }
            else { OpenNotificationSelectionPage() }
        }
    }
    var originXrepeat = 0.0
    var originX1repeat = 0.0
    @objc func DragRepeatPage (sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            originXrepeat = repeatPageView.frame.origin.x
            originX1repeat = firstPageView.frame.origin.x
        } else if sender.state == .changed {
            repeatPageView.frame.origin.x = max(0, min(originXrepeat + sender.translation(in: self.view).x, repeatPageView.frame.width))
            firstPageView.frame.origin.x = max(-repeatPageView.frame.width, min(originX1repeat + sender.translation(in: self.view).x, 0))
        } else if sender.state == .ended {
            if repeatPageView.frame.origin.x >= repeatPageView.frame.width*0.2 { CloseRepeatSelectionPage() }
            else { OpenRepeatSelectionPage() }
        }
    }
    
    func SelectNotificationType (index: Int) {
        if index == -1 {
            for row in notificationSelectoinRows {
                row.isSelected = false
            }
            selectedNotificationTypes.removeAll()
            notificationSelectoinRows.first?.isSelected = true
            return
        }
        
        let notifPerk = StatsManager.getLevelPerk(type: .UnlimitedNotifications)
        if selectedNotificationTypes.count >= 2 && !notifPerk.isUnlocked {
            let coloredSubstring = "Level \(notifPerk.unlockLevel)"
            let vc = LockedPerkPopupViewController(warningText: "Reach \(coloredSubstring) to set more than 2 notifications per task", coloredSubstring: coloredSubstring, parentVC: self)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
            return
        }
        
        selectedNotificationTypes.append(NotificationType(rawValue: index)!)
        notificationSelectoinRows.first?.isSelected = false
        for row in notificationSelectoinRows {
            if row.index == index {
                row.isSelected = true
                break
            }
        }
    }
    func DeselectNotificationType (index: Int) {
        if index == -1 { return }
        
        if selectedNotificationTypes.contains(NotificationType(rawValue: index)!) {
            selectedNotificationTypes.remove(at: selectedNotificationTypes.firstIndex(of: NotificationType(rawValue: index)!)!)
        }
        
        if selectedNotificationTypes.count == 0 { notificationSelectoinRows.first?.isSelected = true }
        for row in notificationSelectoinRows {
            if row.index == index {
                row.isSelected = false
                break
            }
        }
    }
    
    func OpenNotificationSelectionPage () {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
            firstPageView.frame.origin.x = -firstPageView.frame.width
            notificationPageView.frame.origin.x = 0
        }
    }
    func CloseNotificationSelectionPage () {
        notificationStatusLabel.text = notificationStatusLabelText
        let duration = 0.25 * ( 1 - notificationPageView.frame.origin.x / notificationPageView.frame.width)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) { [self] in
            firstPageView.frame.origin.x = 0
            notificationPageView.frame.origin.x = notificationPageView.frame.width
        }
    }
    
    func DrawRepeatingSelectionPage (size: CGSize) -> UIView {
        let view = UIView(frame: CGRect(x: size.width, y: 0, width: size.width, height: size.height))
        view.layer.cornerRadius = 20
        
        let notifWidth: CGFloat = "Repeat".size(withAttributes:[.font: UIFont.preferredFont(forTextStyle: .headline)]).width
        let titleLabel = UILabel(frame: CGRect(x: 0.5*(size.width-notifWidth), y: padding, width: notifWidth, height: 20))
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.text = "Repeat"
        titleLabel.textAlignment = .center
        
        let backButton = UIButton(frame: CGRect(x: padding-10, y: titleLabel.frame.origin.y + 0.5*(titleLabel.frame.height-padding*2), width: padding*2, height: padding*2))
        backButton.contentVerticalAlignment = .fill
        backButton.contentHorizontalAlignment = .fill
        backButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        backButton.setImage(UIImage(systemName: "lessthan"), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(TapBackRepeatPage), for: .touchUpInside)
        
        repeatSelectionRows.removeAll()
        let noneRow = SettingsSelectionRow(
            frame: CGRect(x: 0, y: titleLabel.frame.maxY + padding, width: size.width, height: 40.0),
            title: "None",
            index: -1,
            isSelected: taskSlider.task.notifications.count == 0,
            isNone: true,
            onSelect: SelectRepeatType,
            onDeselect: DeselectRepeatType)
        view.addSubview(noneRow)
        repeatSelectionRows.append(noneRow)
        
        for i in 0..<3  {
            let row = SettingsSelectionRow(
                frame: CGRect(x: 0, y: noneRow.frame.maxY + padding + Double(i)*50.0, width: size.width, height: 40.0),
                title: TaskRepeatType(rawValue: i)!.str,
                accentColor: accentColor,
                index: i,
                isSelected: taskSlider.task.containsNotification(notificationType: NotificationType(rawValue: i)!),
                isNone: false,
                onSelect: SelectRepeatType,
                onDeselect: DeselectRepeatType)
            view.addSubview(row)
            repeatSelectionRows.append(row)
        }
        
        view.addSubview(titleLabel)
        view.addSubview(backButton)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(DragRepeatPage))
        pan.minimumNumberOfTouches = 1
        view.addGestureRecognizer(pan)
        
        return view
    }
    
    func OpenRepeatSelectionPage () {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) { [self] in
            firstPageView.frame.origin.x = -firstPageView.frame.width
            repeatPageView.frame.origin.x = 0
        }
    }
    func CloseRepeatSelectionPage () {
        repeatStatusLabel.text = repeatStatusLabelText
        let duration = 0.25 * ( 1 - repeatPageView.frame.origin.x / repeatPageView.frame.width)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) { [self] in
            firstPageView.frame.origin.x = 0
            repeatPageView.frame.origin.x = repeatPageView.frame.width
        }
    }
    
    @objc func TapGestureRepeatRow (sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            repeatRow.backgroundColor = .systemGray3.withAlphaComponent(0.5)
        } else if sender.state == .ended {
            repeatRow.backgroundColor = .clear
            OpenRepeatSelectionPage()
        }
    }
    
    
    @objc func TapGestureNatificationRow (sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            notificationRow.backgroundColor = .systemGray3.withAlphaComponent(0.5)
        } else if sender.state == .ended {
            notificationRow.backgroundColor = .clear
            OpenNotificationSelectionPage()
        }
    }
    
    @objc func TapBackNotificationPage () {
        CloseNotificationSelectionPage()
    }
    @objc func TapBackRepeatPage () {
        CloseRepeatSelectionPage()
    }
    
    @objc func DueTimeToggle (sender: UISwitch) {
        taskSlider.task.isDueTimeAssigned = sender.isOn
        dueTimePicker.isEnabled = sender.isOn
        
        selectedNotificationTypes.removeAll()
        
        notificationPageView.removeFromSuperview()
        notificationPageView = DrawNotificationSelectionPage(size: firstPageView.frame.size)
        containerView.addSubview(notificationPageView)
        
        notificationStatusLabel.text = notificationStatusLabelText
    }
    
    
    func ShowView () {
        self.view.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        backgroundView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = 1
                self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.backgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    func HideView () {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.backgroundView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: {_ in
            self.dismiss(animated: false)
        })
    }
    
    @objc func Clear () {
        taskSlider.ClearDateAndTime()
        OnCalendarClose()
    }
    
    @objc func Confirm () {
        let adjDate: Date
        taskSlider.task.isDueTimeAssigned = dueTimetoggle.isOn
        if taskSlider.task.isDueTimeAssigned {
            adjDate = Calendar.current.date(bySettingHour: dueTimePicker.date.get(.hour), minute: dueTimePicker.date.get(.minute), second: dueTimePicker.date.get(.second), of: calendarView.date)!
        } else {
            adjDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: calendarView.date)!
        }
        taskSlider.AddDate(date: adjDate)
        for (notificationType, _) in taskSlider.task.notifications {
            if !selectedNotificationTypes.contains(notificationType) {
                taskSlider.task.RemoveNotification(notificationType: notificationType)
            }
        }
        for notificationType in selectedNotificationTypes {
            taskSlider.task.AddNotification(notificationType: notificationType)
        }
        
        OnCalendarClose()
        
        if taskSlider.task.notifications.count > 0 {
            AnalyticsHelper.LogTaskAddedNotification(notifCount: taskSlider.task.notifications.count)
        }
    }
    
    func OnCalendarClose () {
        HideView()
        taskSliderContextMenu?.OnCalendarViewClose()
        
        if taskSliderContextMenu == nil && !taskSlider.isEditing {
            App.instance.taskListView.MoveTaskToRightSortedIndexPath(task: taskSlider.task)
        }
        
        if App.settingsConfig.smartLists.contains(.Upcoming) { App.instance.sideMenuView.UpdateSmartListTasksCount() }
    }
    
    @objc func HideViewNoAction () {
        HideView()
        taskSlider.HideCalendarView()
    }
    
    func ReloadThemeColors() {
        let color: UIColor
        if App.selectedTaskListIndex < App.settingsConfig.smartLists.count { color = .defaultColor }
        else if App.selectedTaskListIndex == App.settingsConfig.smartLists.count { color = App.mainTaskList.primaryColor }
        else { color = App.userTaskLists[App.selectedTaskListIndex-App.settingsConfig.smartLists.count-1].primaryColor }
        accentColor = color
        UIView.animate(withDuration: 0.25) { [self] in
            if calendarView != nil { calendarView.tintColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: accentColor) }
            if confirmButton != nil { confirmButton.backgroundColor = ThemeManager.currentTheme.primaryElementColor(tasklistColor: accentColor) }
            for row in notificationSelectoinRows { row.SetAccentColor(color: accentColor) }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        ThemeManager.currentTheme = App.settingsConfig.GetCurrentTheme()
        ReloadThemeColors()
        App.instance.SetSubviewColors(of: self.view)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
