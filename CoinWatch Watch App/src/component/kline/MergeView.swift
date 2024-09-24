//
//  MergeView.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//
import SwiftUI
import Foundation

struct MergeView: View {
    let data = [
        Candlestick(open: 150, close: 160, high: 165, low: 145),
        Candlestick(open: 160, close: 155, high: 170, low: 150),
        Candlestick(open: 155, close: 170, high: 175, low: 150),
        Candlestick(open: 170, close: 165, high: 180, low: 160),
        Candlestick(open: 165, close: 175, high: 185, low: 160)
    ]
    let interal: Int
    let dateUnit: String


    func calculateMA() -> [Double] {
        var windowLength:Int = 1
        var windowTotal:Double = 0
        
        var res:[Double] = []
        var currentIdx = data.count - 1
        for candlestick in data {
            if windowLength < interal {
                windowLength += 1
                windowTotal += candlestick.close
            } else {
                windowTotal = windowTotal - data[(currentIdx + windowLength - 1)].close + candlestick.close
            }
            res.append(windowTotal / Double(windowLength))
            currentIdx -= 1
        }
        return res
    }

    var body: some View {
        let maxY = data.map { candlestick in
            candlestick.high
        }.max() ?? 0
        
        let minY = data.map{ candlestick in
            candlestick.low
        }.max() ?? 0
        
        CandlestickChartView(
            data:data,
            maxY: maxY,
            minY: minY
        )
        .frame(height:300)
        .background(.blue)
        .padding()
    }
}


#Preview {
    MergeView(interal: 4, dateUnit: "m")
}
