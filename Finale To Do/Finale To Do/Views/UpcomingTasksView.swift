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
    var tasksThisMonth = [Task]()
    var tasksLater = [Task]()
    var tasksWithoutDate = [Task]()
    
    var sections = [UpcomingTasksSection]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TogglePlaceholder()
        return sections[section].tasks.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
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
    
    override func ReloadTaskData(sortOverviewList: Bool = true) {
        super.ReloadTaskData(sortOverviewList: sortOverviewList)
        
        for task in allUpcomingTasks {
            if !task.isDateAssigned {
                tasksWithoutDate.append(task)
            } else {
                if task.isOverdue { tasksOverdue.append(task) }
                else if Calendar.current.isDateInToday(task.dateAssigned) { tasksToday.append(task) }
                else if Calendar.current.isDateInTomorrow(task.dateAssigned) { tasksTomorrow.append(task) }
                else if Calendar.current.isDate(task.dateAssigned, equalTo: Date.now, toGranularity: .weekOfYear) { tasksThisWeek.append(task) }
                else if Calendar.current.isDate(task.dateAssigned, equalTo: Date.now, toGranularity: .month) { tasksThisMonth.append(task) }
                else { tasksLater.append(task) }
            }
        }
        
        sections.removeAll()
        if tasksOverdue.count > 0 { sections.append( UpcomingTasksSection(title: "Overdue", tasks: tasksOverdue)) }
        if tasksToday.count > 0 { sections.append( UpcomingTasksSection(title: "Today", tasks: tasksToday)) }
        if tasksTomorrow.count > 0 { sections.append( UpcomingTasksSection(title: "Tomorrow", tasks: tasksTomorrow)) }
        if tasksThisWeek.count > 0 { sections.append( UpcomingTasksSection(title: "This week", tasks: tasksThisWeek)) }
        if tasksThisMonth.count > 0 { sections.append( UpcomingTasksSection(title: "This month", tasks: tasksThisMonth)) }
        if tasksLater.count > 0 { sections.append( UpcomingTasksSection(title: "Later", tasks: tasksLater)) }
        if tasksWithoutDate.count > 0 { sections.append( UpcomingTasksSection(title: "Without date", tasks: tasksWithoutDate)) }
    }
    
    override func AddSortButton() {
        return
    }
    
}

struct UpcomingTasksSection {
    var title: String
    var tasks: [Task]
}
