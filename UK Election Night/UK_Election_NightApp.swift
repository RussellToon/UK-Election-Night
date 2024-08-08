//
//  UK_Election_NightApp.swift
//  UK Election Night
//
//  Created by Russell Toon on 03/07/2024.
//

import SwiftUI
import SwiftData

@main
struct UK_Election_NightApp: App {

    @ObservedObject var electionData: ElectionData

    init() {
        electionData = ElectionData()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WinningCandidate.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()



    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(electionData)

        }
        .modelContainer(sharedModelContainer)
    }
}
