//
//  LineDataEntry.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/25.
//

import Foundation
import SwiftUI

/**
    一条线含的所有数据
*/
struct LineDataEntry: Identifiable {
    
    let id = UUID()

    /**
        开盘时间
    */
    let openTime: Date

    /**
        收盘时间
    */
    let closeTime: Date
    /**
        开盘价格
    */
    let open: Double

    /**
        收盘价格

    */
    let close: Double
    
    /**
        最高价格

    */
    let high: Double
    
    /**
        最低价格
    */
    let low: Double


    /**
        量能
    */
    var volume: Double = 0.0
    
    
    /**
        获取应该现实的颜色
    - Parameters:
    - Returns: Color k蜡烛的颜色
    */
    func getColor() -> Color {
        return close > open ? Color.green : Color.red
    }
}

extension Double {

    func coinPriceFormat() -> String {
        if self >= 1 || self <= -1 {
            return String(format: "%0.2f", self)
        } else {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 8
            formatter.numberStyle = .decimal

            return formatter.string(from: self as NSNumber) ?? String(self)
        }
    }
    
}
