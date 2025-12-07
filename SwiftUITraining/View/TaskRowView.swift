//
//  TaskRowView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggleCompletion: () -> Void 
    
    var body: some View {
        HStack(alignment: .top) {
            Button {
                onToggleCompletion()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 5)

            VStack(alignment: .leading) {
                Text(task.name)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .strikethrough(task.isCompleted)
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text(task.dueDate.formatted(date: .numeric, time: .shortened))
                }
                .font(.caption2)
                .foregroundStyle(task.isCompleted ? .gray : .blue)
                .padding(.top, 2)
            }
            Spacer()
        }
    }
}
