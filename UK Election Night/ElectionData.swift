//
//  ElectionData.swift
//  UK Election Night
//
//  Created by Russell Toon on 03/07/2024.
//

import Foundation
import TabularData
import Combine
import OSLog



struct Constituency: Identifiable, Hashable, Equatable, Comparable {
    let id: String
    let name: String

    static func < (lhs: Constituency, rhs: Constituency) -> Bool {
        if lhs.name != rhs.name {
            return lhs.name.compare(rhs.name) == .orderedAscending
        }
        else {
            return lhs.id.compare(rhs.id) == .orderedAscending
        }
    }
}

class ElectionData: ObservableObject {

    @Published private(set) var constituencies: [Constituency] = []
    @Published private(set) var chosenCandidates: Set<ElectionCandidate> = []
    @Published private(set) var totalsList: [PartyTotal] = []

    @Published private(set) var allCandidates: [ElectionCandidate] = []

    @Published var constituencyNameFilter: String = ""
    @Published var chosenOnlyFilter: Bool = false
    @Published var showDeclaredWinners: Bool = false

    private var winningCandidates: Set<ElectionCandidate> = []
    private var allConstituencies: [Constituency] = []

    private var allWinnerNames: [String] = []

    private let dataImport = DataImport()

    private var candidatesFrame: DataFrame = DataFrame()
    private var winnersFrame: DataFrame = DataFrame()

    private var cancellables: Set<AnyCancellable> = []

    private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ElectionData.self))

    init() {
        importData()

        $constituencyNameFilter
            .receive(on: DispatchQueue.main)
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [self] newNameFilter in
                filter(
                    nameFilter: newNameFilter,
                    chosenFilter: chosenOnlyFilter
                )
            }
            .store(in: &cancellables)

        $chosenOnlyFilter
            .receive(on: DispatchQueue.main)
            .sink { [self] chosenOnly in
                filter(
                    nameFilter: constituencyNameFilter,
                    chosenFilter: chosenOnly
                )
            }
            .store(in: &cancellables)

        $showDeclaredWinners
            .receive(on: DispatchQueue.main)
            .sink { [self] declared in
                calculateTotals(candidates: declared ? winningCandidates : chosenCandidates)
            }
            .store(in: &cancellables)

        calculateTotals(candidates: chosenCandidates)
    }

    private func importData() {
        guard
            let candidatesData = dataImport.readFile(csvFileUrl: DataImport.candidatesFile),
            let parsedCandidates = dataImport.parseFile(csvContent: candidatesData),
            let winnersData = dataImport.readFile(csvFileUrl: DataImport.winnersFile),
            let parsedWinners = dataImport.parseFile(csvContent: winnersData, hasHeaderRow: false)
        else {
            log.error("Failed to read and parse csv file")
            return
        }

        candidatesFrame = parsedCandidates
        winnersFrame = parsedWinners

        let candidatesCount = candidatesFrame.rows.count
        let winnersCount = winnersFrame.rows.count

        for i in 0..<candidatesCount {
            let candidate = candidate(index: i)
            allCandidates.append(candidate)
        }

        allConstituencies = Set(allCandidates.map { Constituency(id: $0.constituencyId, name: $0.constituency) }).sorted()

        constituencies = allConstituencies

        for i in 0..<winnersCount {
            let winner = winner(index: i)
            allWinnerNames.append(winner)
        }

        matchWinnersToCandidates()
    }

    private func matchWinnersToCandidates() {
        for winner in allWinnerNames {
            let names = winner.components(separatedBy: " ")
            let firstAndLastNameOnly = (names.first ?? "?") + " " + (names.last ?? "?")
            let allNamesMatch = allCandidates.filter( { $0.personName == winner } )
            let firstAndLastNamesMatch = allCandidates.filter( { $0.personName == firstAndLastNameOnly })
            if allNamesMatch.count == 1, let candidate = allNamesMatch.first {
                winningCandidates.insert(candidate) // += [candidate]
            }
            else if firstAndLastNamesMatch.count == 1, let candidate = firstAndLastNamesMatch.first {
                winningCandidates.insert(candidate) // += [candidate]
            }
            else {
                print("Couldn't find winner: \(winner)")
            }
        }
        print("Winning candidates: \(winningCandidates.count)")
    }

    func filter(nameFilter: String, chosenFilter: Bool) {
        if nameFilter.isEmpty && chosenFilter == false {
            resetSearch()
            return
        }

        let matchingCandidates = allCandidates.filter { candidate in
            candidate.personName.lowercased().contains(nameFilter.lowercased()) ||
            (chosenFilter == true && chosenCandidates.contains(candidate))
        }
        let constituenciesWithMatchingCandidates = matchingCandidates.map { $0.constituencyId }
        constituencies = allConstituencies.filter { constituency in
            (constituency.name.lowercased().contains(nameFilter.lowercased()) /* && chosenFilter == false */) ||
            constituenciesWithMatchingCandidates.map{ $0.lowercased() }.contains(constituency.id.lowercased())
        }
    }

    func resetSearch() {
        constituencies = allConstituencies
    }

    private func candidate(index: Int) -> ElectionCandidate {
        guard let candidate = dataImport.candidate(index: index, in: candidatesFrame)
        else {
            fatalError("Index out of bounds")
        }
        return candidate
    }

    private func winner(index: Int) -> String {
        guard let winner = dataImport.winner(index: index, in: winnersFrame)
        else {
            fatalError("Index out of bounds")
        }
        return winner
    }

    func candidatesFor(constituency: Constituency) -> [ElectionCandidate] {
        let candidates = allCandidates.filter { $0.constituencyId == constituency.id }
        return candidates
    }

    func chosenCandidateFor(constituency: Constituency) -> ElectionCandidate? {
        if showDeclaredWinners {
            let winner = winningCandidates.filter( { $0.constituencyId == constituency.id } )
            return winner.first
        }

        let constituencyCandidates = candidatesFor(constituency: constituency)
        let chosenCandidate = constituencyCandidates.filter { chosenCandidates.contains($0) }.first
        return chosenCandidate
    }

    func choseCandidate(newCandidate: ElectionCandidate) {
        chosenCandidates.insert(newCandidate)
        calculateTotals(candidates: chosenCandidates)
    }

    func removeCandidate(candidate: ElectionCandidate) {
        chosenCandidates.remove(candidate)
        calculateTotals(candidates: chosenCandidates)
    }


    private func calculateTotals(candidates: Set<ElectionCandidate>) {
        totalsList = Party.partiesDisplayList.map { party in PartyTotal(party: party, total: party.total(candidates: candidates)) }
        partyTotals = Party.allParties.map { party in PartyTotal(party: party, total: party.total(candidates: candidates)) }
            .sorted(by: { totalA, totalB in
                totalA.total > totalB.total
            })
        calculateSeatRanges()
    }

    private var partyTotals: [PartyTotal] = []

    private func calculateSeatRanges() {
        seatRanges = partyTotals.reduce(into: [(Range<Int>, Party)]()) { partialResult, partyTotal in
            let lastIndex = partialResult.last?.0.upperBound ?? 0
            partialResult += [(lastIndex..<lastIndex+partyTotal.total, partyTotal.party)]
        }
    }

    private var seatRanges: [(range: Range<Int>, party: Party)] = []

    func partyForSeat(at index: Int) -> Party? {
        return seatRanges.first { (range, party) in
            range.contains(index)
        }?.party
    }
}


struct PartyTotal: Hashable {
    let party: Party
    let total: Int
}

