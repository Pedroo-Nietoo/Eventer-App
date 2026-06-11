//
//  Eventer_MobileApp.swift
//  Eventer-Mobile
//
//  Created by Silva, Pedro Henrique Nieto da on 11/06/26.
//

import SwiftUI
import CoreData

@main
struct Eventer_MobileApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
