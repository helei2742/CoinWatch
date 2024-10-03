//
//  MarketData.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/3.
//

import Foundation
import SwiftyJSON
import SwiftUI

@Observable
class MarketData {
    static let sharedInstance: MarketData = MarketData()
    
    private var quote: CoinUnit = AccountGeneralModelData.sharedInstance.spotUnit
    
    /**
     全量数据
     */
    var allData:[MarketDataItem]
    
    /**
     成交值前100
     */
    var hot100:[MarketDataItem] {
        get {
            let res = allData.sorted {
                $0.weightedAvgPrice * $0.volume > $1.weightedAvgPrice * $1.volume
            }
            .prefix(100)
            return Array(res)
        }
    }
    
    /**
     涨幅前100
     */
    var rise100:[MarketDataItem] {
        get {
            let res = allData.sorted {
                $0.priceChange > $1.priceChange
            }
            .prefix(100)
            return Array(res)
        }
    }
    
    /**
     跌幅100
     */
    var fall100:[MarketDataItem] {
        get {
            let res = allData.sorted {
                $0.priceChange < $1.priceChange
            }
            .prefix(100)
            return Array(res)
        }
    }
    
    private init() {
        allData = []
    }
    
    
    /**
     网络请求加载全量的市场数据
     */
    func loadMarketData(whenComplate: @escaping (Bool) -> Void) {
        BinanceApi.spotApi.allCoin24HrList { data in
            if data == nil {
                whenComplate(false)
                return
            }
            
            if let jsonarr = data!.array {
                self.allData.removeAll()
                
                
                jsonarr.forEach { item in
                    //只去特定的
                    if item["symbol"].stringValue.hasSuffix(self.quote.rawValue) {
                        self.allData.append(self.jsonToMarketDataItem(json: item))
                    }
                }
                
                
                whenComplate(true)
            }
        }
    }
    
    /**
     解析json转换为MarketDataItem
     */
    func jsonToMarketDataItem(json: JSON) -> MarketDataItem{
        let symbol = json["symbol"].stringValue
        return MarketDataItem(
            symbol: symbol,
            base: symbol.replacingOccurrences(of: quote.rawValue, with: ""),
            priceChange: json["priceChange"].doubleValue,
            priceChangePercent: json["priceChangePercent"].doubleValue,
            weightedAvgPrice: json["weightedAvgPrice"].doubleValue,
            lastPrice: json["lastPrice"].doubleValue,
            lastQty: json["lastQty"].doubleValue,
            openPrice: json["openPrice"].doubleValue,
            highPrice: json["highPrice"].doubleValue,
            lowPrice: json["lowPrice"].doubleValue,
            volume: json["volume"].doubleValue,
            quoteVolume: json["quoteVolume"].doubleValue,
            openTime: DateUtil.timestarpToDate(timestamp: Double(json["openTime"].intValue)),
            closeTime: DateUtil.timestarpToDate(timestamp: Double(json["closeTime"].intValue))
        )
    }
    
    /**
     根据类型选数据
     */
    func selectMarketTypeData(marketPrintType: MarketPrintType) -> [MarketDataItem] {
        switch marketPrintType {
        case .hot100:
            return hot100
        case .rise100:
            return rise100
        case .fall100:
            return fall100
        }
    }
}


struct MarketDataItem: Identifiable {
    var id = UUID()
    
    let symbol:String
    
    let base: String
    
    let priceChange: Double
    
    let priceChangePercent: Double
    
    let weightedAvgPrice: Double
    
    let lastPrice: Double
    
    let lastQty: Double
    
    let openPrice: Double
    
    let highPrice: Double
    
    let lowPrice: Double
    
    let volume: Double
    
    let quoteVolume: Double
    
    let openTime: Date
    
    let closeTime: Date
    
    func newPrice() -> Double {
        return lastPrice + priceChange
    }
    
    func getColor() -> Color {
        return priceChange > 0 ? .green : .red
    }
}

enum MarketType: CaseIterable {
    case star
    case spot
    case contract
}

enum MarketPrintType: CaseIterable{
    case hot100
    case rise100
    case fall100
    
    func next() -> MarketPrintType {
        let allCases = MarketPrintType.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        let nextIndex = allCases.index(after: currentIndex)
        return nextIndex < allCases.endIndex ? allCases[nextIndex] : allCases.first!
    }
}
