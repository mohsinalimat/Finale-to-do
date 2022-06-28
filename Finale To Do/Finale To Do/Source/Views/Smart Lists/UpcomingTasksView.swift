//
//  UpcomingTasksView.swift
//  Finale To Do
//
//  Created by Grant Oganan on 5/30/22.
//

import Foundation
import UIKit

class UpcomingTasksView: TaskListView {
    
    var tasksOverdue = [Task]()
    var tasksToday = [Task]()
    var tasksTomorrow = [Task]()
    var tasksThisWeek = [Task]()
    var tasksNextWeek = [Task]()
    var tasksThisMonth = [Task]()
    var tasksLater = [Task]()
    var tasksWithoutDate = [Task]()
    
    var sections = [UpcomingTasksSection]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TogglePlaceholder()
        return sections[section].tasks.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        TogglePlaceholder()
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskSliderTableCell
        
        let task = sections[indexPath.section].tasks[indexPath.row]
        cell.Setup(
            task: task,
            sliderSize: CGSize(width: tableView.frame.width-padding*2, height: tableView.rowHeight-padding*0.5),
            cellSize: CGSize(width: tableView.frame.width, height: tableView.rowHeight),
            taskListColor: getTaskListColor(id: task.taskListID), app: app)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
            
            return TaskSliderContextMenu(slider: cell.slider)
        }, actionProvider: { _ in
            let cell = tableView.cellForRow(at: indexPath) as! TaskSliderTableCell
            let DeleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.app.DeleteTask(task: cell.slider.task)
            }
            let Delete = UIMenu(title: "", options: .displayInline, children: [DeleteAction])
            
            let Edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
                self.OpenTaskDetailsView(slider: cell.slider)
            }
            let AssignDate = UIAction(title: cell.slider.task.isDateAssigned ? "Change Date" : "Assign Date", image: UIImage(systemName: "calendar")) { action in
                cell.slider.ShowCalendarView(taskSliderContextMenu: nil)
            }
            
            let Regular = UIMenu(title: "", options: .displayInline, children: [AssignDate, Edit])
            
            return UIMenu(title: "", children: [Regular, Delete])
        })
    }
    
    override func ReloadTaskData(sortOverviewList: Bool = true) {
        super.ReloadTaskData(sortOverviewList: sortOverviewList)
        
        tasksOverdue.removeAll()
        tasksToday.removeAll()
        tasksTomorrow.removeAll()
        tasksThisWeek.removeAll()
        tasksNextWeek.removeAll()
        tasksThisMonth.removeAll()
        tasksLater.removeAll()
        tasksWithoutDate.removeAll()
        
        for task in allUpcomingTasks {
            if !task.isDateAssigned {
                tasksWithoutDate.append(task)
            } else {
                if task.isOverdue { tasksOverdue.append(task) }
                else if Calendar.current.isDateInToday(task.dateAssigned) { tasksToday.append(task) }
                else if Calendar.current.isDateInTomorrow(task.dateAssigned) { tasksTomorrow.append(task) }
                else if Calendar.current.isDate(task.dateAssigned, equalTo: Date(), toGranularity: .weekOfYear) { tasksThisWeek.append(task) }
                else if task.dateAssigned.get(.weekOfYear) - Date().get(.weekOfYear) == 1 { tasksNextWeek.append(task) }
                else if Calendar.current.isDate(task.dateAssigned, equalTo: Date(), toGranularity: .month) { tasksThisMonth.append(task) }
                else { tasksLater.append(task) }
            }
        }
        
        sections.removeAll()
        if tasksOverdue.count > 0 { sections.append( UpcomingTasksSection(id: 0, title: "Overdue", tasks: tasksOverdue)) }
        if tasksToday.count > 0 { sections.append( UpcomingTasksSection(id: 1, title: "Today", tasks: tasksToday)) }
        if tasksTomorrow.count > 0 { sections.append( UpcomingTasksSection(id: 2, title: "Tomorrow", tasks: tasksTomorrow)) }
        if tasksThisWeek.count > 0 { sections.append( UpcomingTasksSection(id: 3, title: "This week", tasks: tasksThisWeek)) }
        if tasksNextWeek.count > 0 { sections.append( UpcomingTasksSection(id: 3, title: "Next week", tasks: tasksNextWeek)) }
        if tasksThisMonth.count > 0 { sections.append( UpcomingTasksSection(id: 4, title: "This month", tasks: tasksThisMonth)) }
        if tasksLater.count > 0 { sections.append( UpcomingTasksSection(id: 5, title: "Later", tasks: tasksLater)) }
        if tasksWithoutDate.count > 0 { sections.append( UpcomingTasksSection(id: 6, title: "Without date", tasks: tasksWithoutDate)) }
    }
    
    override func SortUpcomingTasks(sortPreference: SortingPreference, animated: Bool = true) {
        allUpcomingTasks = allUpcomingTasks.sorted { sortBool(task1: $0, task2: $1, sortingPreference: .ByTimeDue) }
    }
    
    override func AddSortButton() {
        return
    }
    
    override func MoveTaskToRightSortedIndexPath(task: Task, moveRow: Bool = true) {
        super.MoveTaskToRightSortedIndexPath(task: task, moveRow: false)
        
        var oldSectionsIDs = [Int]()
        var oldIndexPath = IndexPath(row: 0, section: 0)
        for i in 0..<sections.count {
            if sections[i].tasks.contains(task) {
                oldIndexPath.section = i
                oldIndexPath.row = sections[i].tasks.firstIndex(of: task)!
            }
            oldSectionsIDs.append(sections[i].id)
        }
        
        ReloadTaskData()
        
        var newSectionsIDs = [Int]()
        var newIndexPath = IndexPath(row: 0, section: 0)
        for i in 0..<sections.count {
            if sections[i].tasks.contains(task) {
                newIndexPath.section = i
                newIndexPath.row = sections[i].tasks.firstIndex(of: task)!
            }
            newSectionsIDs.append(sections[i].id)
        }
        
        if oldSectionsIDs.contains(-1) {
            tableView.performBatchUpdates({
                tableView.deleteSections(IndexSet(integer: 0), with: .fade)
                oldSectionsIDs.removeFirst()
                if oldSectionsIDs == newSectionsIDs {
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                } else {
                    if newSectionsIDs.count > oldSectionsIDs.count {
                        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .fade)
                    }
                }
            })
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        } else {
            tableView.performBatchUpdates({
                if newSectionsIDs == oldSectionsIDs {
                    tableView.moveRow(at: oldIndexPath, to: newIndexPath)
                } else {
                    if newSectionsIDs.count > oldSectionsIDs.count {
                        tableView.deleteRows(at: [oldIndexPath], with: .fade)
                        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .fade)
                    } else if newSectionsIDs.count < oldSectionsIDs.count {
                        tableView.deleteSections(IndexSet(integer: oldIndexPath.section), with: .fade)
                        tableView.insertRows(at: [newIndexPath], with: .fade)
                    } else {
                        tableView.deleteSections(IndexSet(integer: oldIndexPath.section), with: .fade)
                        tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .fade)
                    }
                }
            })
            if newIndexPath == IndexPath(row: 0, section: 0) || oldIndexPath == IndexPath(row: 0, section: 0) { tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false) }
        }
    }
    
    override var shouldShowPlaceholder: Bool {
        return sections.count == 0
    }
    
    override var placeholderTitle: String {
        return "Looks like you are done with everything!"
    }
    
}

struct UpcomingTasksSection {
    var id: Int
    var title: String
    var tasks: [Task]
}
