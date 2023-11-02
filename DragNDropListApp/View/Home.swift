//
//  Home.swift
//  DragNDropListApp
//
//  Created by Gustavo Dong on 02/11/2023.
//

import SwiftUI

struct Home: View {
    // Tareas de ejemplo
    @State private var todo: [Task] = [
        .init(title: "Edit Video", status: .working)
    ]
    @State private var working: [Task] = [
        .init(title: "Record Video", status: .working)
    ]
    @State private var completed: [Task] = [
        .init(title: "Implement Drag & Drop", status: .completed),
        .init(title: "Update Mockview App", status: .completed),
    ]
    // Propiedades de la vista
    @State private var currentlyDragging: Task?
    var body: some View {
        HStack(spacing: 2) {
            TodoView()
            
            WorkingView()
            
            CompletedView()
        }
    }
    
    // Vista de las Tareas
    @ViewBuilder
    func TasksView(_ tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 10, content: {
            ForEach(tasks) { task in
                GeometryReader {
                    TaskRow(task, $0.size)
                }
                .frame(height: 45)
                
            }
        })
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // Fila de Tareas
    @ViewBuilder
    func TaskRow(_ task: Task, _ size: CGSize) -> some View {
        Text(task.title)
            .font(.callout)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: size.height)
            .background(.white, in: .rect(cornerRadius: 10))
            .contentShape(.dragPreview, .rect(cornerRadius: 10))
            .draggable(task.id.uuidString) {
                Text(task.title)
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: size.height)
                    .background(.white)
                    .contentShape(.dragPreview, .rect(cornerRadius: 10))
                    .onAppear(perform: {
                        currentlyDragging = task
                    })
            }
            .dropDestination(for: String.self) { items, location in
                currentlyDragging = nil
                return false
            } isTargeted: { status in
                if let currentlyDragging, status, currentlyDragging.id != task.id {
                    withAnimation(.snappy) {
                        // Interaccion Cross List
                        appendTask(task.status)
                        switch task.status {
                        case .todo:
                            replaceItem(tasks: &todo, droppingTask: task, status: .todo)
                        case .working:
                            replaceItem(tasks: &working, droppingTask: task, status: .working)
                        case .completed:
                            replaceItem(tasks: &completed, droppingTask: task, status: .working)
                        }
                    }
                }
            }
    }
    
    // Agregando y Quitando tarea de una lista a la otra
    func appendTask(_ status: Status) {
        if let currentlyDragging {
            switch status {
                case .todo:
                // Safe check and Insert
                    if !todo.contains(where: { $0.id == currentlyDragging.id }) {
                        var updatedTask = currentlyDragging
                        updatedTask.status = .todo
                        todo.append(updatedTask)
                        // Quitando de la lista anterior
                        working.removeAll(where: { $0.id == currentlyDragging.id })
                        completed.removeAll(where: { $0.id == currentlyDragging.id })
                    }
                case .working:
                    if !working.contains(where: { $0.id == currentlyDragging.id }) {
                        var updatedTask = currentlyDragging
                        updatedTask.status = .working
                        working.append(updatedTask)
                        // Quitando de la lista anterior
                        todo.removeAll(where: { $0.id == currentlyDragging.id })
                        completed.removeAll(where: { $0.id == currentlyDragging.id })
                    }
                case .completed:
                    if !completed.contains(where: { $0.id == currentlyDragging.id }) {
                        var updatedTask = currentlyDragging
                        updatedTask.status = .completed
                        completed.append(updatedTask)
                        // Quitando de la lista anterior
                        working.removeAll(where: { $0.id == currentlyDragging.id })
                        todo.removeAll(where: { $0.id == currentlyDragging.id })
                    }
            }
        }
    }
    
    // Reemplazando Items dentro de la Lista
    func replaceItem(tasks: inout [Task], droppingTask: Task, status: Status) {
        if let currentlyDragging {
            if let sourceIndex = tasks.firstIndex(where: { $0.id == currentlyDragging.id }),
               let destinationIndex = tasks.firstIndex(where: { $0.id == droppingTask.id}) {
                // Cambiando Items en la Lista
                var sourceItem = tasks.remove(at: sourceIndex)
                sourceItem.status = status
                tasks.insert(sourceItem, at: destinationIndex)
            }
        }
    }
    
    
    // Vista del TODO
    @ViewBuilder
    func TodoView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(todo)
            }
            .navigationTitle("To-Do")
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
    }
    
    // Vista del WORKING
    @ViewBuilder
    func WorkingView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(working)
            }
            .navigationTitle("Working")
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    func CompletedView() -> some View {
        NavigationStack {
            ScrollView(.vertical) {
                TasksView(completed)
            }
            .navigationTitle("Completed")
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    ContentView()
}
