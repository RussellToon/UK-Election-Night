//
//  CandidateChooser.swift
//  UK Election Night
//
//  Created by Russell Toon on 04/07/2024.
//

import SwiftUI


struct CandidateChooser: View {

    struct Model: Hashable, Equatable {
        var constituency: Constituency
        var candidates: [ElectionCandidate]
    }

    var model: Model

    @EnvironmentObject private var electionData : ElectionData

    @Environment(\.dismiss) private var dismiss

    @State private var selection: ElectionCandidate?

    @State private var enableAutoDismiss = false

    var addCandidate: (_ candidate: ElectionCandidate) -> Void
    var removeCandidate: (_ candidate: ElectionCandidate) -> Void

    init(model: Model, selection: ElectionCandidate? = nil, addCandidate: @escaping (_: ElectionCandidate) -> Void, removeCandidate: @escaping (_: ElectionCandidate) -> Void) {
        self.model = model
        self.selection = selection
        self.addCandidate = addCandidate
        self.removeCandidate = removeCandidate
    }

    var body: some View {
        List(model.candidates, id: \.self, selection: $selection) { candidate in

            let selected = (selection == candidate)

            candidateCell(candidate: candidate, selected: selected)
                .selectionDisabled(electionData.showDeclaredWinners)
        }
        .navigationTitle(model.constituency.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Button {
                    if let selectionNow = selection {
                        electionData.removeCandidate(candidate: selectionNow)
                        selection = nil
                    }
                } label: {
                    Text("Clear")
                }
                .disabled(selection == nil || electionData.showDeclaredWinners)
            }
        })
        .onChange(of: selection) { oldValue, newValue in

            if electionData.showDeclaredWinners {
                return
            }

            if let oldValue {
                electionData.removeCandidate(candidate: oldValue)
                removeCandidate(oldValue)
            }
            if let newValue {
                electionData.choseCandidate(newCandidate: newValue)
                addCandidate(newValue)
            }

            if enableAutoDismiss {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    print("Dismiss")
                    dismiss()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                enableAutoDismiss = true
            }
        }
    }


    func candidateCell(candidate: ElectionCandidate, selected: Bool) -> some View {
        HStack {
            VStack {
                HStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 4.0)
                            .aspectRatio(0.2, contentMode: .fit)
                            .foregroundColor(Party.with(id: candidate.partyId).colour)
                        Text(candidate.personName)
                    }
                    .fixedSize()
                    Spacer()
                }
                HStack {
                    Text(candidate.partyName)
                        .font(.footnote)
                    Spacer()
                }
            }

            Spacer()
            VStack(spacing: 0) {
                if selected {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .bold()
                            .imageScale(.large)
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                }
            }
            .animation(.default, value: selected)
        }

    }
}

#Preview {
    CandidateChooser(model: CandidateChooser.Model(
        constituency: Constituency(id: "ConstituencyId3", name: "Constituency3"),
        candidates: [
            ElectionCandidate(personName: "Name1",
                              partyName: "PartyA",
                              constituency: "Constituency3",
                              constituencyId: "ConstituencyId3",
                              personId: 1, partyId: "PartyId"),
            ElectionCandidate(personName: "Name2",
                              partyName: "PartyB",
                              constituency: "Constituency3",
                              constituencyId: "ConstituencyId3",
                              personId: 2,
                              partyId: "PartyId")
        ]),
                     addCandidate: { _ in },
                     removeCandidate: { _ in }
    )
    .environmentObject(ElectionData())
}
