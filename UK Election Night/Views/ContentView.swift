//
//  ContentView.swift
//  UK Election Night
//
//  Created by Russell Toon on 03/07/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var winners: [WinningCandidate]

    @EnvironmentObject private var electionData : ElectionData

    @State private var searchPresented: Bool = false


    var body: some View {
        NavigationStack {
            ConstituencyList(/*electionData: electionData*/
                addCandidate: addCandidate(candidate:),
                removeCandidate: removeCandidate(candidate:)
            )
            .navigationTitle("Constituencies")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        electionData.showDeclaredWinners.toggle()
                    } label: {
                        Label("Declared Results", systemImage: electionData.showDeclaredWinners ? "trophy.circle.fill" : "trophy.circle")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        electionData.chosenOnlyFilter.toggle()
                    } label: {
                        let filtering = electionData.chosenOnlyFilter
                        Label("Selected", systemImage: filtering ? "checkmark.circle.fill" : "checkmark.circle")
                    }

                    NavigationLink {
                        Summary()
                    } label: {
                        Label("Totals", systemImage: "info.circle")
                    }
                }
            }

        }
        .searchable(text: $electionData.constituencyNameFilter,
                    isPresented: $searchPresented,
                    prompt: Text("Constituency or candidate name")
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                searchPresented = false
            }
            for winner in winners {
                let selectedCandidates = electionData.allCandidates.filter { $0.personId == winner.personId }
                if let selectedCandidate = selectedCandidates.first {
                    electionData.choseCandidate(newCandidate: selectedCandidate)
                }
            }
        }
    }



    private func addCandidate(candidate: ElectionCandidate) {
        let newWinner = WinningCandidate(timestamp: .now, personId: candidate.personId, partyId: candidate.partyId, constituencyId: candidate.constituencyId)
        modelContext.insert(newWinner)

        print("Added \(candidate.personId) \(candidate.personName) \(winners.count)")

        do {
            try modelContext.save()
        }
        catch {
            print("\(error)")
        }
    }

    private func removeCandidate(candidate: ElectionCandidate) {

        print("Will delete \(candidate.personId) \(candidate.personName) \(winners.count)")
        if let toBeRemoved = winners.filter({ $0.personId == candidate.personId }).first {
            modelContext.delete(toBeRemoved)
            print("Did delete \(toBeRemoved.personId) \(winners.count)")
        }

        do {
            try modelContext.save()
        }
        catch {
            print("\(error)")
        }

    }

}

#Preview {
    ContentView()
        .modelContainer(for: WinningCandidate.self, inMemory: true)
        .environmentObject(ElectionData())
}
