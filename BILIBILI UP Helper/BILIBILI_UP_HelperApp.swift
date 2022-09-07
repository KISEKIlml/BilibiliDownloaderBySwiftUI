//
//  BILIBILI_UP_HelperApp.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/8/6.
//

import SwiftUI

 @main
struct BILIBILI_UP_HelperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
