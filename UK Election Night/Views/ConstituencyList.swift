//
//  ConstituencyList.swift
//  UK Election Night
//
//  Created by Russell Toon on 04/07/2024.
//

import SwiftUI
import SwiftData


struct ConstituencyList: View {

    @EnvironmentObject private var electionData : ElectionData

    var addCandidate: (_ candidate: ElectionCandidate) -> Void
    var removeCandidate: (_ candidate: ElectionCandidate) -> Void


    var body: some View {

        List(electionData.constituencies, id: \.self) { constituency in

            let candidates = electionData.candidatesFor(constituency: constituency)
            let selectedCandidate = electionData.chosenCandidateFor(constituency: constituency)

            NavigationLink() {
                CandidateChooser(
                    model: CandidateChooser.Model(constituency: constituency, candidates: candidates),
                    selection: selectedCandidate,
                    addCandidate: addCandidate,
                    removeCandidate: removeCandidate
                )
            } label: {
                constituencyCell(name: constituency.name, selectedCandidate: selectedCandidate)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: electionData.constituencies)

    }

    func constituencyCell(name: String, selectedCandidate: ElectionCandidate?) -> some View {
        HStack {
            VStack {
                HStack {
                    Text(name)
                        .font(selectedCandidate == nil ? .body : .caption)
                    Spacer()
                }
                if let selectedCandidate {
                    HStack {
                        HStack {
                            RoundedRectangle(cornerRadius: 4.0)
                                .aspectRatio(0.2, contentMode: .fit)
                                .foregroundColor(Party.with(id: selectedCandidate.partyId).colour)

                            Text(selectedCandidate.personName)
                        }
                        .fixedSize()
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedCandidate)
        }
    }
}

#Preview {
    ConstituencyList(addCandidate: { _ in }, removeCandidate: { _ in })
        .environmentObject(ElectionData())
}
