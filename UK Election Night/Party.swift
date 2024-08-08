//
//  Party.swift
//  UK Election Night
//
//  Created by Russell Toon on 13/07/2024.
//

import Foundation
import SwiftUI


struct Party: Equatable, Hashable {

    let name: String
    let ids: [String]?
    let colour: Color

    static let libDem = Party(name: "Lib Dems", ids: ["PP90"], colour: .orange)
    static let labour = Party(name: "Labour", ids: ["PP53", "joint-party:53-119", "ynmp-party:12522"], colour: .red)
    static let green = Party(name: "Green", ids: ["PP63"], colour: .green)
    static let tory = Party(name: "Conservative", ids: ["PP52"], colour: .blue)
    static let reform = Party(name: "Reform", ids: ["PP7931"], colour: .cyan)
    static let snp = Party(name: "SNP", ids: ["PP102"], colour: .yellow)
    static let plaid = Party(name: "Plaid Cymru", ids: ["PP77"], colour: Color("Plaid Green"))

    static let other = Party(name: "Other", ids: nil, colour: .gray)
    static let remaining = Party(name: "Remaining", ids: nil, colour: .clear)
    static let declared = Party(name: "Total declared", ids: nil, colour: .clear)

    static let namedParties: [Party] = [
        labour, tory, libDem, green, reform, snp, plaid
    ]
    static let allParties: [Party] = [
        labour, tory, libDem, green, reform, snp, plaid, other
    ]
    static let partiesDisplayList: [Party] = [
        labour, tory, libDem, green, reform, snp, plaid, other, remaining, declared
    ]

    static func with(id: String) -> Party {
        namedParties.filter { $0.ids?.contains(id) ?? false }.first ?? .other
    }

    func total(candidates: Set<ElectionCandidate>) -> Int {
        if self == .other {
            let otherIds = Self.namedParties.compactMap { $0.ids }.map { $0 }.reduce([], +)
            let others = candidates.filter {
                !otherIds.contains($0.partyId)
            }
            return others.count
        }

        if self == .remaining {
            let totalAllParties = Self.allParties.map { $0.total(candidates: candidates) }.reduce(0, +)
            let remaining = 650 - totalAllParties
            return remaining
        }

        if self == .declared {
            return candidates.count
        }

        return candidates.filter { self.ids?.contains($0.partyId) ?? false }.count
    }
}
