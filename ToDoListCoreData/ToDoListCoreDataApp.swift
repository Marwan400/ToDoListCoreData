//
//  ToDoListCoreDataApp.swift
//  ToDoListCoreData
//
//  Created by Marwan Al.Jabri on 03/10/1445 AH.
//

import SwiftUI

@main
struct ToDoListCoreDataApp: App {
    let persistantContrller = TheDB.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistantContrller.container.viewContext)
        }
    }
}
