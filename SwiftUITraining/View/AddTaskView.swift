//
//  AddTaskView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var taskName: String = ""
    @State private var taskDetails: String = ""
    @State private var taskDate: Date = Date()
    @State private var taskPriority: TaskPriority = .medium
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Básicas") {
                    TextField("Nome da nova tarefa", text: $taskName)
                    TextField("Detalhes (opcional)", text: $taskDetails, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Prioridade"){
                    Picker("Nível de Prioridade", selection: $taskPriority){
                        ForEach(TaskPriority.allCases, id: \.self){ priority in
                            Text(priority.rawValue)
                                .foregroundColor(priority.color)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented) //estilo em barra horizontal
                }
                Section("Agendamento") {
                    DatePicker("Para quando?", selection: $taskDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Nova Tarefa")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        saveTask()
                        dismiss()
                    }
                    .disabled(taskName.isEmpty)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
    
    private func saveTask() {
        let newTask = TaskItem(name: taskName, details: taskDetails, dueDate: taskDate, priority: taskPriority)
        modelContext.insert(newTask)
        
        modelContext.insert(newTask)
        try? modelContext.save()
        
        // Usa o Manager Singleton
        NotificationManager.shared.scheduleNotification(for: newTask)
    }
}
