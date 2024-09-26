//
//  MAChart.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//
import SwiftUI
import Charts

struct MAChart {
    let maInterval:Int
    
    func generalChart(candlestick: Candlestick) -> LineMark {
        return LineMark(
            x: .value("日期", candlestick.openTime, unit: .day),
            y: .value("美元", candlestick.dictOfMA[maInterval] ?? 0)
        )
    }
}
