//
//  Summary.swift
//  UK Election Night
//
//  Created by Russell Toon on 04/07/2024.
//

import Foundation
import SwiftUI


struct Summary: View {

    @EnvironmentObject private var electionData : ElectionData

    
    var body: some View {

        List {

            ForEach(electionData.totalsList, id: \.self) { total in

                HStack {
                    RoundedRectangle(cornerRadius: 4.0)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(height: 30)
                        .foregroundColor(total.party.colour)
                    Text("\(total.party.name)")
                    Spacer()
                    Text("\(total.total)")
                }

            }

            VStack {
                Spacer(minLength: 40)
                
                Text("Seats Map")

                HStack {
                    Spacer()
                    Seats()
                    Spacer()
                }

                Spacer(minLength: 40)
            }

        }
        .navigationTitle("Totals")

    }
}
