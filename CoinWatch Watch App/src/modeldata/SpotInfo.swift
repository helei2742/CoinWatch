//
//  SpotInfo.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI
import SwiftyJSON

/**
 
 现货信息，采用单例模式。并且是可观察的。
 其他视图中可直接获取单例，对其进行修改就能影响到全局
 */
@Observable
class SpotInfo {
    static let sharedInstance = SpotInfo(
        spotInfoList: [],
        coinTradingDayInfo: CoinTradingDayInfo()
    )
    
    /**
      当前的现货信息列表
     */
    var spotInfoList: [SpotInfoItem]?

    /**
        币种交易日信息
     */
    var coinTradingDayInfo: CoinTradingDayInfo
    
    private init(spotInfoList: [SpotInfoItem], coinTradingDayInfo: CoinTradingDayInfo) {
        self.spotInfoList = spotInfoList
        self.coinTradingDayInfo = coinTradingDayInfo
    }
    
    /**
        查找现货信息
        - Parameters:
            - base:
            - quote:
        - Returns: SpotInfoItem?
     */
    func findSpotInfo(base: String, quote: String) -> SpotInfoItem? {
        return spotInfoList?.first(where: { (spotInfoItem) -> Bool in
                        spotInfoItem.base == base && spotInfoItem.quote == quote
                    })
    }
    
    /**
        查找现货信息
        - Parameters: symbol
        - Returns: SpotInfoItem?
     */
    func findSpotInfo(symbol: String) -> SpotInfoItem? {
        return spotInfoList?.first(where: { (spotInfoItem) -> Bool in
                        symbol == spotInfoItem.base + spotInfoItem.quote
                    })
    }
    
    /**
        更新现货信息
        - Parameters:
            - base:
            - quote:
            - peice:
        - Returns: Void
     */
    func updateSpotInfo(base: String, quote: String,price:Double) {
        if let existItem = findSpotInfo(symbol: CommonUtil.generalCoinSymbol(base: base, quote: quote)) {
            existItem.price = price
        } else {
            spotInfoList?.append(SpotInfoItem(
                base: base,
                quote: quote,
                price: price
            ))
        }
    }
    
    /**
        添加币种交易日信息
     - Parameters:
         - date:
         - symbol:
         - value:
     - Returns: Void
     */
    func addCoinTradingDayInfo(date:Date, symbol: String, value: LineDataEntry) {
        coinTradingDayInfo.dayKeyCache[DateUtil.dateToDay(date: date)]?[symbol] = value
    }

    /**
        获取币种交易日信息
     - Parameters:
        - date:
        - symbol:
        - value:
     - Returns: JSON
     */
    func getCoinTradingDayInfo(date: Date, symbol: String) -> LineDataEntry? {
        return coinTradingDayInfo.dayKeyCache[DateUtil.dateToDay(date: date)]?[symbol]
    }
}

/**
 币种单个交易日的信息
 */
class CoinTradingDayInfo {
    var dayKeyCache: [Date: [String:LineDataEntry]] = [:]
}

/**
 单条现货信息
 */
//@Observable
class SpotInfoItem {
    var base: String
    var quote: String
    var price: Double
    
    
    init(base: String, quote: String, price: Double) {
        self.base = base
        self.quote = quote
        self.price = price
    }
}


