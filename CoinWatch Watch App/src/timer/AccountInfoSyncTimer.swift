//
//  AccountInfoSyncTimer.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/23.
//


import Foundation
import SwiftyJSON
import SwiftUI

/**
 更新账户信息
 */
struct AccountInfoSyncTimer {
    
    @State private var accountSpotAssertSyncTimer:Timer?
    
    @State private var accountSpotDayHistorySyncTimer:Timer?
    
    private var accountInfo:AccountGeneralModelData
    private var spotInfo:SpotInfo
    
    
    init (
        accountInfo: AccountGeneralModelData,
        spotInfo: SpotInfo
    ) {
        self.accountInfo = accountInfo
        self.spotInfo = spotInfo
    }
    
    func startAccountSpotAssertSyncTimer() {
        // 创建并启动定时器
        accountSpotAssertSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.accountSpotAssertSync()
        }
    }
    
    func stopAccountSpotAssertSyncTimer() {
        // 停止定时器
        accountSpotAssertSyncTimer?.invalidate()
        accountSpotAssertSyncTimer = nil
    }
    
    func startAccountSpotDayHistorySyncTimer() {
        accountSpotDayHistorySyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.accountSpotDayHistorySync()
        }
    }
    
    func stopAccountSpotDayHistorySyncTimer() {
        // 停止定时器
        accountSpotDayHistorySyncTimer?.invalidate()
        accountSpotDayHistorySyncTimer = nil
        
    }
    
    /**
     同步账户的现货资产情况
     */
    func accountSpotAssertSync() {
        BinanceApi.accountApi.soptInfo (
            omitZeroBalances: true,
            successCall:setAccountSpotInfo
        )
    }
    
    func setAccountSpotInfo(data: JSON) {
        //更新 spotList
        
        var spotList = accountInfo.accountSpot
        for (_,item):(String, JSON) in data["balances"] {
            
            if let existItem = spotList.first(where: { (spotInfo) -> Bool in
                spotInfo.baseAsset == item["asset"].string
            }) {//存在，更新
                existItem.count = item["free"].doubleValue
            } else { //不存在，创建
                spotList.append(AccountSpotItem(
                    baseAsset: item["asset"].stringValue,
                    quoteAsset: accountInfo.spotUnit.rawValue,
                    count: item["free"].doubleValue
                ))
            }
        }
        
        //更新spotTotalValue
        var totalValue = Double(0.0)
        for accountSpotItem in spotList {
            let symbol = accountSpotItem.baseAsset + accountInfo.spotUnit.rawValue
            if let spotInfoItem = spotInfo.findSpotInfo(symbol: symbol) {
                totalValue += accountSpotItem.count * spotInfoItem.price
            }
        }
        
        accountInfo.spotTotalValue = totalValue
        
        //更新spotTotalCount
        accountInfo.spotTotalCount = spotList.count
    }
    
    
    /**
     同步账户现货历史资产
     */
    func accountSpotDayHistorySync() {
        let limit = 14
        let endTime = Date()
        let startTime = Date(timeInterval: TimeInterval(-24*60*60*limit), since: endTime)
        
        BinanceApi.accountApi.assertSnapshoot (
            limit: limit,
            startTime: Int(startTime.timeIntervalSince1970),
            endTime: Int(endTime.timeIntervalSince1970),
            successCall: setAccountSpotDayHistory
        )
    }
    
    
    func setAccountSpotDayHistory(data: JSON) {
        var accountSpotDayHistory:[AccountSpotDayInfo] = []
        
        
        for (_,daySnapshot):(String,JSON) in data["snapshotVos"] {
            let snapshotVos = daySnapshot["data"]["balances"]
            
            let item = AccountSpotDayInfo(
                date: Date(timeIntervalSince1970: daySnapshot["updateTime"].doubleValue),
                snapshotVos: snapshotVos,
                spotTotalValue: 0
            )
            accountSpotDayHistory.append(item)
            
            //计算总价值
            var totalValue = 0.0
           
            var symbolMapCount:[String:Double] = [:]
            for (_,rowJson) in snapshotVos {
                symbolMapCount[rowJson["asset"].stringValue + accountInfo.spotUnit.rawValue] = rowJson["free"].doubleValue
            }
            
            //等这个执行完
            BinanceApi.spotApi.tradingDayPrice (
                symbols: Array(symbolMapCount.keys),
                successCall: {data in
                    for (_,item):(String,JSON) in data {
                        let symbol = item["symbol"].stringValue
                        let price = item["lastPrice"].doubleValue
                        let date = Date(timeIntervalSince1970: item["openTime"].doubleValue)
                        
                        //记录或更新这条交易日信息
                        spotInfo.addCoinTradingDayInfo(date: date, symbol: symbol, value: item)
                        
                        totalValue += (symbolMapCount[symbol] ?? 0.0) * price
                    }
                }
            )
            
            item.spotTotalValue = totalValue
        }
    }
    
    
}



