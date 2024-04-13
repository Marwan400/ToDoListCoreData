//
//  ContentView.swift
//  ToDoListCoreData
//
//  Created by Marwan Al.Jabri on 03/10/1445 AH.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            List{
                ForEach(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                    Text("Dummy Data")
                        .foregroundStyle(.white)
                        .listRowBackground(Color.gray)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.gray)
            
            .overlay(alignment: .bottomTrailing) {
                Button{
                    
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
    }
}

#Preview {
    ContentView()
}
