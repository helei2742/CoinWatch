//
//  CoinWatchApp.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI

@main
struct CoinWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            KLineChart(symbol: "BTCUSDT", kLineInterval: .d_1)

        }
    }
}
