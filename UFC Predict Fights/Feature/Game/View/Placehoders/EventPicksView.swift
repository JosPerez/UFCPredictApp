//
//  EventPicksView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct EventPicksView: View {
    let eventId: Int

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()
            Text("Event Picks — Coming in Step 7")
                .foregroundColor(BSColors.textTertiary)
        }
        .navigationTitle("Picks")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
