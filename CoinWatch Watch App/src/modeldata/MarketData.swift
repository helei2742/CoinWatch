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
     全量现货数据
     */
    var allSpotData:[MarketDataItem]
    
    /**
     全量合约数据
     */
    var allContractData:[MarketDataItem]
    
    /**
     现货成交值前100
     */
    var spotHot100:[MarketDataItem]
    {
        get {
            let res = allSpotData.sorted {
                $0.weightedAvgPrice * $0.volume > $1.weightedAvgPrice * $1.volume
            }
            .prefix(100)
            return Array(res)
        }
    }
    
    /**
     现货涨幅前100
     */
    var spotRise100:[MarketDataItem]
    {
        get {
            let res = allSpotData.sorted {
                $0.priceChangePercent > $1.priceChangePercent
            }
            .prefix(100)
            return Array(res)
        }
    }
    
    /**
     现货跌幅100
     */
    var spotFall100:[MarketDataItem]
    {
        get {
            let res = allSpotData.sorted {
                $0.priceChangePercent < $1.priceChangePercent
            }
            .prefix(100)
            return Array(res)
        }
    }
    
    private init() {
        allSpotData = []
        allContractData = []
    }
    
    
    /**
     网络请求加载全量的市场数据
     */
    func loadSpotMarketData(whenComplate: @escaping (Bool) -> Void) {
        BinanceApi.spotApi.allCoin24HrList { data in
            if let data = data {
                self.resolveSpotMarketData(data: data)
                whenComplate(true)
            }else {
                whenComplate(false)
            }
        }
    }
    
    func resolveSpotMarketData(data: JSON) {
        var list:[MarketDataItem] = []
        if let jsonarr = data.array {
            jsonarr.forEach { item in
                //只取固定后缀的
                if item["symbol"].stringValue.hasSuffix(self.quote.rawValue) {
                    list.append(self.jsonToMarketDataItem(json: item, symbolType: .spot))
                }
            }
        }
        self.allSpotData.removeAll()
        self.allSpotData.append(contentsOf: list)
        
//        //热度 100
//        self.hot100.removeAll()
//        let hot100 = list.sorted {
//            $0.weightedAvgPrice * $0.volume > $1.weightedAvgPrice * $1.volume
//        } .prefix(100)
//        self.hot100.append(contentsOf: hot100)
//        
//        //涨幅 100
//        self.rise100.removeAll()
//        let rise100 = list.sorted {
//            $0.priceChangePercent > $1.priceChangePercent
//        }.prefix(100)
//        self.rise100.append(contentsOf: rise100)
//        
//        //跌幅 100
//        self.fall100.removeAll()
//        let fall100 = list.sorted {
//            $0.priceChangePercent < $1.priceChangePercent
//        }.prefix(100)
//        self.fall100.append(contentsOf: fall100)
    }
    
    
    /**
     解析json转换为MarketDataItem
     */
    func jsonToMarketDataItem(json: JSON, symbolType:SymbolType) -> MarketDataItem{
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
            closeTime: DateUtil.timestarpToDate(timestamp: Double(json["closeTime"].intValue)),
            symbolType: symbolType
        )
    }
    
    /**
     根据类型选数据
     */
    func selectMarketTypeData(marketPrintType: MarketPrintType) -> [MarketDataItem] {
        switch marketPrintType {
        case .spotHot100:
            return spotHot100
        case .spotRise100:
            return spotRise100
        case .spotFall100:
            return spotFall100
        }
    }
    
    /**
     根据symbol查找MarketDataItem数据
     */
    func selectItem(symbol: String, symbolType:SymbolType) -> MarketDataItem? {
        switch symbolType {
        case .spot:
            allSpotData.first { item in
                item.symbol == symbol
            }
        case .contract:
            allContractData.first { item in
                item.symbol == symbol
            }
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
    
    var symbolType: SymbolType? = nil
    
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
    case spotHot100
    case spotRise100
    case spotFall100
    
    func next() -> MarketPrintType {
        let allCases = MarketPrintType.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        let nextIndex = allCases.index(after: currentIndex)
        return nextIndex < allCases.endIndex ? allCases[nextIndex] : allCases.first!
    }
}
