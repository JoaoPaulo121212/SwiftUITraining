//
//  TaskListViewModel.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import SwiftUI
import SwiftData

@Observable
class TaskListViewModel {
    var deletedTasksHistory: [(name: String, details: String, savedDueDate: Date, savedCreationDate: Date, savedPriority: TaskPriority)] = []
    
    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        
        if task.isCompleted {
            NotificationManager.shared.cancelNotification(for: task)
        } else if task.dueDate > Date() {
            NotificationManager.shared.scheduleNotification(for: task)
        }
    }
    
    func toggleHideTask(_ task: TaskItem, context: ModelContext) {
        withAnimation {
            task.isHidden.toggle()
        }
    }
    
    func deleteTask(offsets: IndexSet, tasks: [TaskItem], context: ModelContext) {
        withAnimation {
            for index in offsets {
                let taskToDelete = tasks[index]
                
                NotificationManager.shared.cancelNotification(for: taskToDelete)
                
                deletedTasksHistory.append((
                    name: taskToDelete.name,
                    details: taskToDelete.details,
                    savedDueDate: taskToDelete.dueDate,
                    savedCreationDate: taskToDelete.creationDate,
                    savedPriority: taskToDelete.priority
                ))
                
                context.delete(taskToDelete)
            }
        }
    }
    
    func restoreLastTask(context: ModelContext) {
        withAnimation {
            if let params = deletedTasksHistory.popLast() {
                let restoredTask = TaskItem(
                    name: params.name,
                    details: params.details,
                    isCompleted: false,
                    isHidden: false,
                    creationDate: params.savedCreationDate,
                    dueDate: params.savedDueDate,
                    priority: params.savedPriority
                )
                
                context.insert(restoredTask)
                
                if restoredTask.dueDate > Date() {
                    NotificationManager.shared.scheduleNotification(for: restoredTask)
                }
            }
        }
    }
}
