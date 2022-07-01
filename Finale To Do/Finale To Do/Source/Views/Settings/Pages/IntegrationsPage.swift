//
//  IntegrationsPage.swift
//  Finale To Do
//
//  Created by Grant Oganan on 6/30/22.
//

import Foundation
import UIKit
import EventKit

class SettingsIntegrationsPage: SettingsPageViewController {
    
    override func GetSettings() -> [SettingsSection] {
        return [
        
            SettingsSection(title: "Import", options: [
                .navigationCell(model: SettingsNavigationOption(title: "iOS Reminders", icon: UIImage(named: "iOS Reminders Icon"), iconBorderWidth: 1, OnTap: {
                    self.TappedImportReminders()
                } ))
            ])
        
        ]
    }
    
    override var PageTitle: String {
        return "Integrations"
    }
    
    
    func TappedImportReminders () {
        let confirmationVC = ConfirmationSlideover(title: "Import iOS Reminders", description: "Would you like to import all your iOS reminders?", confirmActionTitle: "Import", confirmAction: {
            self.TryImportReminders()
        })
        self.present(confirmationVC, animated: true)
    }
    
    func TryImportReminders() {
        let store = EKEventStore()

        store.requestAccess(to: .reminder, completion: { granted, error in
            if error != nil { return }

            if !granted {
                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                    DispatchQueue.main.async { UIApplication.shared.open(appSettings) }
                }
            } else {
                DispatchQueue.main.async {
                    self.ImportReminders()
                }
            }
        })
    }
    
    func ImportReminders () {
        let store = EKEventStore()
        
        let calendars = store.calendars(for: .reminder)
        
        for calendar in calendars {
            let predicate: NSPredicate? = store.predicateForReminders(in: [calendar])
            
            let taskList = getTaskList(ekCalendar: calendar)
            
            if let aPredicate = predicate {
                store.fetchReminders(matching: aPredicate, completion: {(_ reminders: [Any]?) -> Void in
                    
                    DispatchQueue.main.async {
                        for reminder: EKReminder? in reminders as? [EKReminder?] ?? [EKReminder?]() {
                            if reminder != nil {
                                if self.doesTaskExist(reminder: reminder!, taskList: taskList) { continue }
                                
                                let importedTask = Task(
                                    name: reminder!.title,
                                    priority: reminder!.priority == 1 ? .High : .Normal,
                                    notes: reminder!.notes ?? "",
                                    taskListID: taskList.id
                                )
                                if reminder!.dueDateComponents != nil {
                                    if let reminderDate = Calendar.current.date(from: reminder!.dueDateComponents!) {
                                        importedTask.isDateAssigned = true
                                        importedTask.dateAssigned = reminderDate
                                        importedTask.isDueTimeAssigned = reminder!.dueDateComponents?.hour != nil && reminder!.dueDateComponents?.minute != nil
                                    }
                                }
                                if reminder!.isCompleted && reminder!.completionDate != nil {
                                    importedTask.isCompleted = true
                                    importedTask.dateCompleted = reminder!.completionDate!
                                }
                                
                                print(calendar.title)
                                
                                if !importedTask.isCompleted {
                                    taskList.upcomingTasks.append(importedTask)
                                } else {
                                    taskList.completedTasks.append(importedTask)
                                }
                                App.instance.SelectTaskList(index: 0, closeMenu: false)
                            }
                        }
                    }
                    
                    
                })
            }
        }
    }
    
    func doesTaskExist (reminder: EKReminder, taskList: TaskList) -> Bool {
        if !reminder.isCompleted {
            for task in taskList.upcomingTasks {
                if task.name == reminder.title { return true }
            }
        } else {
            for task in taskList.completedTasks {
                if task.name == reminder.title { return true }
            }
        }
        return false
    }
    
    func getTaskList (ekCalendar: EKCalendar) -> TaskList {
        for tasklist in App.instance.allTaskLists {
            if ekCalendar.title == tasklist.name { return tasklist }
        }
        App.instance.CreateNewTaskList(taskList: TaskList(name: ekCalendar.title, primaryColor: getClosestPredefinedColor(initialColor: UIColor(cgColor: ekCalendar.cgColor))))
        
        return App.userTaskLists.last!
    }
    
    func getClosestPredefinedColor(initialColor: UIColor) -> UIColor {
        var closestDistance = Double.infinity
        var selectedColor = initialColor
        
        for color in AddListView.colors {
            let distanceSquared = pow((color.components.red - initialColor.components.red), 2) + pow((color.components.green - initialColor.components.green), 2) + pow((color.components.blue - initialColor.components.blue), 2)
            if distanceSquared < closestDistance {
                closestDistance = distanceSquared
                selectedColor = color
            }
        }
        
        return selectedColor
    }
}
