//
//  ContentView.swift
//  ToDoListCoreData
//
//  Created by Marwan Al.Jabri on 03/10/1445 AH.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var isShowingAddNewGoalView: Bool = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Goal.deadline,
                                                     ascending: false)], animation: .default) private var goals: FetchedResults<Goal>
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(goals.filter{$0.isDone == false}) { goal in
                    HStack{
                        Button{
                            goal.isDone.toggle()
                            do {
                                try viewContext.save()
                            } catch {
                                print("Something went wrong")
                            }
                        }label: {
                            Image(systemName: goal.isDone ? "checkmark" : "square")
                        }
                        VStack(alignment: .leading){
                            Text(goal.title ?? "There is no title")
                            Text(goal.detail ?? "There is no title")
                            Text("\((goal.deadline?.formatted(date: .numeric, time: .shortened))!)")
                        }
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.gray)
                }
                
                ForEach(goals.filter{$0.isDone == true}) { goal in
                    HStack{
                        Button{
                            goal.isDone.toggle()
                            do {
                                try viewContext.save()
                            } catch {
                                print("Something went wrong")
                            }
                        }label: {
                            Image(systemName: goal.isDone ? "checkmark" : "square")
                        }
                        VStack(alignment: .leading){
                            Text(goal.title ?? "There is no title")
                            Text(goal.detail ?? "There is no title")
                            Text("\((goal.deadline?.formatted(date: .numeric, time: .shortened))!)")
                        }
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.gray)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.gray)
            
            .overlay(alignment: .bottomTrailing) {
                Button{
                    isShowingAddNewGoalView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .padding()
                }
            }
            
            .navigationTitle("To Do List App")
            .navigationBarTitleDisplayMode(.large)
            
        }.environment(\.colorScheme, .dark)
        
            .sheet(isPresented: $isShowingAddNewGoalView){
                AddNewGoalView()
                    .background(Material.ultraThinMaterial)
                    .presentationDetents([.fraction(0.9)])
                    .presentationDragIndicator(.visible)
                    .environment(\.colorScheme, .light)
                    .onAppear{
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                            return
                        }
                        controller.view.backgroundColor = .clear
                    }
            }
    }
    
    struct AddNewGoalView: View{
        @Environment(\.managedObjectContext) private var viewContext
        @State var title: String = ""
        @State var detail: String = ""
        @Environment(\.presentationMode) var presentationMode
        @State var dedline = Date()
        var body: some View{
            VStack{
                HStack{
                    Button{
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                }.padding()
                
                Group{
                    TextField("Title", text: $title)
                        .padding(.horizontal)
                    Divider()
                        .padding(.horizontal)
                    
                    TextField("Write details", text: $detail)
                        .padding(.horizontal)
                    Divider()
                        .padding(.horizontal)
                }
                
                DatePicker(selection: $dedline, in: Date()...){
                    
                    
                }.datePickerStyle(.graphical)
                
                
                Spacer()
                Text("This is the second view")
                Spacer()
                Button{
                    let myObject = Goal(context: viewContext)
                    myObject.title = title
                    myObject.deadline = dedline
                    myObject.detail = detail
                    myObject.isDone = false
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print("Something went wrong")
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }label: {
                    Text("Add New Goal")
                        .foregroundStyle(.white)
                        .frame(width: 290, height: 50)
                        .background(.blue)
                        .presentationCornerRadius(5)
                }
                HStack{Spacer()}
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, TheDB.shared.container.viewContext)
}
