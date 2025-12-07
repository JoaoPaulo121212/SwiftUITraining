//
//  TaskItem.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import SwiftData
import Foundation

@Model
final class TaskItem{
    var id: UUID
    var name : String
    var details : String
    var isCompleted: Bool
    var isHidden: Bool
    var creationDate: Date
    var dueDate: Date
    var priority: TaskPriority
    
    init(name: String = "",details : String = "", isCompleted: Bool = false,isHidden: Bool = false, creationDate: Date = Date(), dueDate: Date = Date(), priority: TaskPriority = .medium) {
        self.id = UUID() // gera um id aleatório
        self.name = name
        self.details = details
        self.isCompleted = isCompleted
        self.isHidden = isHidden
        self.creationDate = creationDate
        self.dueDate = dueDate
        self.priority = priority
    }
}
