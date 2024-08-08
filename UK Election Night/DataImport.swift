//
//  DataImport.swift
//  UK Election Night
//
//  Created by Russell Toon on 03/07/2024.
//

import Foundation
import TabularData
import OSLog


struct ElectionCandidate: Identifiable, Hashable, Equatable {
    let personName: String
    let partyName: String
    let constituency: String
    let constituencyId: String
    let personId: Int
    let partyId: String

    var id: Int {
        personId
    }
}


struct DataImport {

    static let candidatesFile = Bundle.main.url(forResource: "dc-candidates-election_id_parl2024-07-04-2024-06-26T01-54-01", withExtension: "csv")
    static let winnersFile = Bundle.main.url(forResource: "ElectionWinners2024", withExtension: "csv")

    private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: DataImport.self))

    func readFile(csvFileUrl: URL?) -> String? {
        guard let csvFileUrl else {
            log.error("Couldn't find data file")
            return nil
        }
        do {
            let fileContent = try String(contentsOf: csvFileUrl, encoding: .utf8)
            return fileContent
        }
        catch {
            log.error("Couldn't read data file")
            return nil
        }
    }

    func parseFile(csvContent: String, hasHeaderRow: Bool = true) -> DataFrame? {
        var options = CSVReadingOptions()
        options.hasHeaderRow = hasHeaderRow

        do {
            let frame = try DataFrame.init(csvData: Data(csvContent.utf8), options: options)
            return frame
        }
        catch {
            log.error("Failed to parse csv: \(error)")
            return nil
        }
    }


    func candidate(index: Int, in frame: DataFrame) -> ElectionCandidate? {
        let row = frame.rows[index]
        guard
            let personName = row["person_name", String.self],
            let partyName = row["party_name", String.self],
            let constituency = row["post_label", String.self],
            let constituencyId = row["ballot_paper_id", String.self],
            let personId = row["person_id", Int.self],
            let partyId = row["party_id", String.self]
        else {
            log.error("Data csv missing columns")
            return nil
        }

        let electionCandidate = ElectionCandidate(
            personName: personName,
            partyName: partyName,
            constituency: constituency,
            constituencyId: constituencyId,
            personId: personId,
            partyId: partyId
        )

        return electionCandidate
    }


    func winner(index: Int, in frame: DataFrame) -> String? {
        let row = frame.rows[index]
        guard
            let winnerName = row[0, String.self]
        else {
            log.error("Winners csv missing columns")
            return nil
        }

        return winnerName
    }


}
