//
//  SpotInfo.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI
import SwiftyJSON

class SpotInfo {
    static let sharedInstance = SpotInfo(
        spotInfoList: [],
        coinTradingDayInfo: CoinTradingDayInfo()
    )
    
    
    @State var spotInfoList: [SpotInfoItem]?

    var coinTradingDayInfo: CoinTradingDayInfo
    
    init(spotInfoList: [SpotInfoItem], coinTradingDayInfo: CoinTradingDayInfo) {
        self.spotInfoList = spotInfoList
        self.coinTradingDayInfo = coinTradingDayInfo
    }

    func findSpotInfo(base: String, quote: String) -> SpotInfoItem? {
        return spotInfoList?.first(where: { (spotInfoItem) -> Bool in
                        spotInfoItem.base == base && spotInfoItem.quote == quote
                    })
    }
    
    func findSpotInfo(symbol: String) -> SpotInfoItem? {
        return spotInfoList?.first(where: { (spotInfoItem) -> Bool in
                        symbol == spotInfoItem.base + spotInfoItem.quote
                    })
    }
    
    
    func addCoinTradingDayInfo(date:Date, symbol: String, value: JSON) {
        coinTradingDayInfo.dayKeyCache[DateUtil.dateToDay(date: date)]?[symbol] = value
    }

    func getCoinTradingDayInfo(date: Date, symbol: String) -> JSON? {
        return coinTradingDayInfo.dayKeyCache[DateUtil.dateToDay(date: date)]?[symbol]
    }
}

class CoinTradingDayInfo {
    var dayKeyCache: [Date: [String:JSON]] = [:]
}

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


