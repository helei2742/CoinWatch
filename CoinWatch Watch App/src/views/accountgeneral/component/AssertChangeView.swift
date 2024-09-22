//
//  AssertChangeView.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import SwiftUI
import Charts

struct AssertChangeView: View {
    @EnvironmentObject var modelData: AccountGeneralModelData
    @State var day: Date? = nil
    
    var body: some View {
        GeometryReader { geometry in
            SimpleAreaChart(rawSelectDate: $day)
                .environmentObject(modelData)
                .frame(height: geometry.size.height)
        }
    }
}
