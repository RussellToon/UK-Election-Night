//
//  Seats.swift
//  UK Election Night
//
//  Created by Russell Toon on 19/07/2024.
//

import SwiftUI

struct Seats: View {

    @EnvironmentObject private var electionData : ElectionData

    static let total = 650
    static let height = 26 // Needs to be even & a factor of 650 (e.g. 10 or 26)
    let height = Self.height
    let width = total / height
    let benchRows = height / 2
    let seatSide = CGFloat(5)

    func index(x: Int, y: Int) -> Int {
        return x + y * width
    }

    var body: some View {

        VStack {

            VStack(spacing: 2) {
                ForEach(0..<benchRows, id: \.self) { yPos in
                    row(yPos: yPos)
                }
            }

            VStack(spacing: 2) {
                ForEach(benchRows..<height, id: \.self) { yPos in
                    row(yPos: yPos)
                }
            }

        }
    }

    func row(yPos: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<width, id: \.self) { xPos in
                seat(xPos: xPos, yPos: yPos)
            }
        }

    }

    func seat(xPos: Int, yPos: Int) -> some View {
        let party = electionData.partyForSeat(at: index(x: xPos, y: yPos))

        let colour = party?.colour ?? Color("Empty Seat")

        return Rectangle()
            .frame(width: seatSide, height: seatSide)
            .foregroundColor(colour)
    }
}

#Preview {
    Seats()
        .environmentObject(ElectionData())
}
