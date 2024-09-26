//
//  BollChart.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//
import SwiftUI
import Charts

struct BollChart {
    let maInterval: Int = 20
    let n: Int = 2
    
    let maxPrice: Double

    let minPrice: Double


    func generalChart(candlestick: Candlestick) -> AreaMark {
        let (upper, ma, lower):(Double, Double, Double) = candlestick.bollLine
        
        return AreaMark(
            x: .value("日期", candlestick.openTime, unit: .day),
            yStart: .value("Minimum Price", lower),
            yEnd: .value("Maximum Price", upper)
        )
    }
}
