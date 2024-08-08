//
//  WinningCandidate.swift
//  UK Election Night
//
//  Created by Russell Toon on 04/07/2024.
//

import Foundation
import SwiftData

@Model
final class WinningCandidate {
    var timestamp: Date
    var personId: Int
    var partyId: String
    var constituencyId: String


    init(
        timestamp: Date,
        personId: Int,
        partyId: String,
        constituencyId: String
    ) {
        self.timestamp = timestamp
        self.personId = personId
        self.partyId = partyId
        self.constituencyId = constituencyId
    }
}
