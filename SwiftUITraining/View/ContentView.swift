//
//  ContentView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 02/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@Model //A macro @Model torna esta struct persistivel (salvavel no banco de dados SwiftData)
final class TaskItem{
    var id: UUID
    var name : String
    var details : String
    var isCompleted: Bool
    var creationDate: Date
    var dueDate: Date
    
    init(name: String = "",details : String = "", isCompleted: Bool = false, creationDate: Date = Date(), dueDate: Date = Date()) {
        self.id = UUID() // gera um id aleatório
        self.name = name
        self.details = details
        self.isCompleted = isCompleted
        self.creationDate = creationDate
        self.dueDate = dueDate
    }
}

struct ContentView: View {
    //Environment : Acesso ao contexto do banco de dados (gerenciado pelo TaskMasterAp.swift)
    @Environment(\.modelContext) private var modelContext
    // @Query: Busca todos os TaskItem salvos, mantendo a lista atualizada automaticamente
    @Query(sort: \TaskItem.dueDate, order: .forward) private var tasks: [TaskItem]
    // @State: Controla o estado local desta View (a abertura do modal)
    @State private var showingAddTaskSheet = false
    @State private var deletedTasksHistory: [(name: String, details: String, savedDueDate: Date, savedCreationDate: Date)] = []
    
    //Cria a instancia do delegado
    @State private var notificationDelegate = NotificationDelegate()
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    @Bindable var task = task
                    HStack {
                        Button{
                            toggleTaskCompletion(task)
                        }label: {
                            Image(systemName:task.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }
                        .buttonStyle(.plain) // Importante para o clique não pegar na linha toda
                        .padding(.trailing, 5)

                            VStack(alignment: .leading) {
                                Text(task.name)
                                    .font(.headline) // Destaque para o título
                                    .strikethrough(task.isCompleted)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                                
                                // Só mostra se tiver detalhe escrito
                                if !task.details.isEmpty {
                                    Text(task.details)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .strikethrough(task.isCompleted) // Opcional: riscar o detalhe também
                                }
                                HStack{
                                    Image(systemName: "calendar")
                                    Text(task.dueDate.formatted(date: .numeric, time: .shortened))
                                }
                                .font(.caption2)
                                .foregroundStyle(.blue)
                                .padding(.top, 2)
                            }
                        Spacer()
                        .contentShape(Rectangle())
                    }
                }
                .onDelete(perform: deleteTask) // habilita o gesto de deslizar para deletar
            }
            .navigationTitle("TaskManager")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton() // botão nativo de edição
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !deletedTasksHistory.isEmpty {
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
        .onAppear{
            UNUserNotificationCenter.current().delegate = notificationDelegate
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ sucess, error in
                if sucess {
                    print("Permissão aceita")
                }else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteTask(offsets: IndexSet){
        withAnimation {
            for index in offsets {
                let taskToDelete = tasks[index]
                //cancela a notificação agendada
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskToDelete.id.uuidString])
                
                
                deletedTasksHistory.append((
                    name: taskToDelete.name,
                    details: taskToDelete.details,
                    savedCreationDate: taskToDelete.creationDate,
                    savedDueDate: taskToDelete.dueDate
                ))
                // deleta do banco de dados
                modelContext.delete(taskToDelete)
            }
        }
    }
    
    private func returnLastTask(){
        withAnimation {
            //verifica se existe algo no backup
            if let params = deletedTasksHistory.popLast() {
                //recria a tarefa com os mesmos dados antigos
                let restoredTask = TaskItem(
                    name: params.name,
                    details: params.details,
                    isCompleted: false, // apenas para quando voltar, voltar como dependente
                    creationDate: params.savedCreationDate,
                    dueDate: params.savedDueDate
                )
                //insere a tarefa no contexto para salvar no banco de dados
                modelContext.insert(restoredTask)
                if restoredTask.dueDate > Date() {
                    scheduleNotification(for: restoredTask)
                }
                
            }
        }
    }
    
    private func toggleTaskCompletion(_ task: TaskItem){
        task.isCompleted.toggle()
        
        let center = UNUserNotificationCenter.current()
        
        if task.isCompleted {
            center.removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        } else {
            // Se descompletou e a data ainda é no futuro, REAGENDA (Opcional, mas recomendado)
            if task.dueDate > Date() {
               scheduleNotification(for: task)
               print("Tarefa reaberta: Notificação reagendada.")
            }
        }
    }
    
    private func scheduleNotification(for task: TaskItem) {
        let content = UNMutableNotificationContent()
        content.title = "Hora da tarefa"
        content.body = task.name //o texto sera o nome da tarefa
        content.sound = .default
        
        //pega os componentes da data escolhida
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute] ,from: task.dueDate)
        
        //cria o gatilho (trigger) baseado na data
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        //cria o a requisicao usando o ID da tarefa
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
}
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // As opções .banner e .sound garantem que o alerta apareça visualmente e toque som
        completionHandler([.banner, .sound])
    }
}
struct AddTaskView : View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var taskName: String = ""
    @State private var taskDetails: String = ""
    @State private var taskDate: Date = Date()
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Informações Básicas"){
                    TextField("Nome da nova tarefa", text: $taskName)
                    // .axis: .vertical permite que o campo cresça se o texto for longo
                    TextField("Detalhes (opcional)", text: $taskDetails, axis: .vertical)
                        .lineLimit(3...6) // define o tamanho minimo e maximo visual
                }
                Section("Agendamento"){
                    DatePicker("Para quando?", selection: $taskDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
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
        let newTask = TaskItem(name: taskName, details: taskDetails, dueDate: taskDate)
        modelContext.insert(newTask)
        //agenda a notificação
        scheduleNotification(for: newTask)
    }
    
    private func scheduleNotification(for task: TaskItem) {
        let content = UNMutableNotificationContent()
        content.title = "Hora da tarefa"
        content.body = task.name //o texto sera o nome da tarefa
        content.sound = .default
        
        //pega os componentes da data escolhida
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute] ,from: task.dueDate)
        
        //cria o gatilho (trigger) baseado na data
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        //cria o a requisicao usando o ID da tarefa
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
    
#Preview {
    ContentView()
    //O preview tamb[em precisa do container do SwiftData
        .modelContainer(for: TaskItem.self)
}
