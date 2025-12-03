//
//  ContentView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 02/12/25.
//

import SwiftUI
import SwiftData

@Model //A macro @Model torna esta struct persistivel (salvavel no banco de dados SwiftData)
final class TaskItem{
    var name : String
    var isCompleted: Bool
    var creationDate: Date
    
    init(name: String = "", isCompleted: Bool = false, creationDate: Date = Date()) {
        self.name = name
        self.isCompleted = isCompleted
        self.creationDate = creationDate
    }
}

struct ContentView: View {
    //Environment : Acesso ao contexto do banco de dados (gerenciado pelo TaskMasterAp.swift)
    @Environment(\.modelContext) private var modelContext
    // @Query: Busca todos os TaskItem salvos, mantendo a lista atualizada automaticamente
    @Query(sort: \TaskItem.creationDate, order: .reverse) private var tasks: [TaskItem]
    // @State: Controla o estado local desta View (a abertura do modal)
    @State private var showingAddTaskSheet = false
    @State private var lastDeletedTaskParams: (name: String, date: Date)? = nil
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    @Bindable var task = task
                    // HStack: Layout horizontal para o contéudo da célula da lista
                    HStack{
                        //isCompleted: Controlado por um Binding dentro da Toggle
                        Toggle(task.name, isOn: $task.isCompleted)
                        //aplica modificadores com base no estado (isCompleted)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .gray : .primary)
                        Spacer()
                        
                        Text(task.creationDate.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .toggleStyle(.button) //oculta o r[otulo do toggle, mas mant[em sua funcionalidade de clique
                }
                .onDelete(perform: deleteTask) // habilita o gesto de deslizar para deletar
            }
            .navigationTitle("TaskMaster")
            
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton() // botão nativo de edição
                }
                ToolbarItem(placement: .topBarTrailing) {
                   if lastDeletedTaskParams != nil {
                       Button {
                           returnLastTask()
                       } label : {
                           Image(systemName: "arrow.uturn.backward.circle")
                       }
                   }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        showingAddTaskSheet = true
                    } label: {
                        Label("Adicionar Tarefa", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet){
                AddTaskView()
            }
        }
    }
    
    private func deleteTask(offsets: IndexSet){
        withAnimation {
            for index in offsets {
                let taskToDelete = tasks[index]
                //salva em um backup
                lastDeletedTaskParams = (taskToDelete.name, taskToDelete.creationDate)
                // deleta do banco de dados
                modelContext.delete(taskToDelete)
            }
        }
    }
    private func returnLastTask(){
        withAnimation {
            //verifica se existe algo no backup
            if let params = lastDeletedTaskParams {
                //recria a tarefa com os mesmos dados antigos
                let restoredTask = TaskItem(
                    name: params.name,
                    isCompleted: false, // apenas para quando voltar, voltar como dependente
                    creationDate: params.date
                )
                //insere a tarefa no contexto para salvar no banco de dados
                modelContext.insert(restoredTask)
                //limpa a variavel, fazendo o botao sumir caso nao tenha
                lastDeletedTaskParams = nil
            }
        }
    }
}

struct AddTaskView : View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var taskName: String = ""
    
    var body: some View {
        NavigationStack{
            Form {
                TextField("Nome da nova tarefa", text: $taskName)
            }
            .navigationTitle("Nova Tarefa")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        saveTask()
                        dismiss() //fecha a modal
                    }
                    //desabilita o botao se o campo de texto estiver vazio
                    .disabled(taskName.isEmpty)
                }
                ToolbarItem (placement: .topBarLeading){
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
    private func saveTask() {
        let newTask = TaskItem(name: taskName)
        modelContext.insert(newTask)
    }
}
    
#Preview {
    ContentView()
    //O preview tamb[em precisa do container do SwiftData
        .modelContainer(for: TaskItem.self)
}
