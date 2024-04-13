//
//  ContentView.swift
//  ToDoListCoreData
//
//  Created by Marwan Al.Jabri on 03/10/1445 AH.
//

import SwiftUI

struct Goal: Identifiable {
    let id = UUID().uuidString
    let title: String
    let detail: String
    let deadline: Date
    var isCompleted: Bool = false
}

struct ContentView: View {
    @State var isShowingAddNewGoalView: Bool = false
    @State var myGoals: [Goal] = []
    var body: some View {
        NavigationStack{
            List{
                ForEach(myGoals) { goal in
                    Text(goal.title)
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
                AddNewGoalView(myGoals: $myGoals)
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
        @State var title: String = ""
        @State var detail: String = ""
        @Binding var myGoals: [Goal]
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
                    let myGoalObject = Goal(title: title,
                                            detail: detail,
                                            deadline: dedline)
                    myGoals.append(myGoalObject)
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
}
