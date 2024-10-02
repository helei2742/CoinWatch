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
final class LineDataEntry: Identifiable , Sendable, Equatable{
    static func == (lhs: LineDataEntry, rhs: LineDataEntry) -> Bool {
        return lhs.openTime == rhs.openTime
        && lhs.closeTime == lhs.closeTime
        && lhs.open == lhs.open
        && lhs.close == lhs.close
        && lhs.high == lhs.high
        && lhs.low == lhs.low
        && lhs.volume == lhs.volume
    }
    
    
    let id: UUID = UUID()

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
    let volume: Double
    
    /**
        MA指标
    */
    var dictOfMA: [Int:Double] = [:]

    /**
        Boll指标
    */
    var bollLine: (upper:Double, ma:Double, lower:Double) = (0, 0, 0)

    
    init (
        openTime: Date,
        closeTime: Date,
        open: Double,
        close: Double,
        high: Double,
        low: Double,
        volume: Double
    ) {
        self.openTime = openTime
        self.closeTime = closeTime
        self.open = open
        self.close = close
        self.high = high
        self.low = low
        self.volume = volume
    }
    
    func addMA(maInterval:Int, value: Double) {
        dictOfMA[maInterval] = value
    }
    
    /**
        获取应该现实的颜色
    - Parameters:
    - Returns: Color k蜡烛的颜色
    */
    func getColor() -> Color {
        return close > open ? Color("KLineColorUp") : Color("KLineColorDown")
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

