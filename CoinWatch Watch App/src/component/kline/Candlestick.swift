//
//  Candlestick.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//

import SwiftUI
import Charts


/**
MA协议，用在Candlestick上
*/
protocol MAProtocol {

    /**
        MA价格字典 key: ma间隔， value: 价格
    */
    var dictOfMA:[Int: Double] { get set }


    /**
     计算ma均线
     - Parameters:
        - data: [Candlestick], k图的原始数据，
        - interval: 计算ma的数组
     - Returns: VOid
     */
    static func calculateMA(data:[Candlestick], maIntervals:[Int]) -> Void
}

protocol BollProtocol {

    var bollLine: (upper:Double, ma:Double, lower:Double) { get set }

    static func calculateBoll(data:[Candlestick], maInterval:Int, n: Double) -> Void
}

/**
基础的，k线线图数据
*/
class Candlestick: Identifiable, MAProtocol, BollProtocol, CustomStringConvertible {
    var description: String{
        return "Person(openTime: \(openTime), ma: \(dictOfMA))\n"
    }
    
    

    let id = UUID()

    /**
        开盘时间
    */
    let openTime: Date
    
    /**
        量能
    */
    var volume: Double

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
        MAProtocol 协议里的ma均线字典
    */
    var dictOfMA: [Int: Double] = [:]

    var bollLine: (upper:Double, ma:Double, lower:Double) = (0, 0, 0)

    init(
        openTime: Date, volume: Double, open: Double, close: Double, high: Double, low: Double
    ) {
        self.openTime = openTime
        self.volume = volume
        self.open = open
        self.close = close
        self.high = high
        self.low = low
    }
    
    static func calculateMA(data: [Candlestick], maIntervals:[Int] = [1]) -> Void{
        
        var intervalWindow: [Int:(interval:Int, windowLength:Int, windowTotal:Double)] = [:]
        for element in maIntervals {
            intervalWindow[element] = (element, 0, 0)
        }
      

        var currentIdx = data.count - 1
        for candlestick in data {
            for (_, value) in intervalWindow {
                var (interval, windowLength, windowTotal) = value
                
                if windowLength < interval {
                    windowLength += 1
                    windowTotal += candlestick.close
                } else {
                    windowTotal = windowTotal - data[(currentIdx + windowLength - 1)].close + candlestick.close
                }
                let ma = windowTotal / Double(windowLength)
                
                candlestick.dictOfMA[interval] = ma
                currentIdx -= 1
            }
        }
    }
    
    static func calculateBoll(data: [Candlestick], maInterval:Int = 1, n: Double = 2) -> Void {
        for i in maInterval-1...data.count {
            let periodPrices = data[i-maInterval+1...i].map{$0.close}
            let sum = periodPrices.reduce(0, +)
            let average = sum / Double(maInterval)

            let variance = periodPrices.map {pow($0 - average, 2)}.reduce(0, +) / Double(maInterval)
            let standardDeviation = sqrt(variance)

            let upper = average + (n * standardDeviation)
            let lower = average - (n * standardDeviation)

            data[i].bollLine = (upper, average, lower)
        }
    }

    /**
        获取应该现实的颜色
    - Parameters:
    - Returns: Color k蜡烛的颜色
    */
    func getColor() -> Color {
        return close > open ? Color.green : Color.red
    }
}

