//
//  CoinWatchApp.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI

@main
struct CoinWatch_Watch_AppApp: App {
    @State var kline:KLineInterval = .d_1
    var body: some Scene {
        WindowGroup {
        
            KLineChart(
                symbol: "BTCUSDT",
                kLineInterval: $kline,
                maIntervals: [MAType.ma_20],
                bollConfig: (average: 21, n: 2),
                getPrintState: {
                    .K_MA_LINE
                }
            )
            
//            CoinDetailPage(base: "BNB", quote: "USDT")
//            MainView()
        }
    }
}
