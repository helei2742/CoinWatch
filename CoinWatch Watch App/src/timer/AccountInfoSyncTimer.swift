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
    
    /**
    同步账户现货信息
     */
    @State private var accountSpotAssertSyncTimer:Timer?
    
    /**
     同步账户现货按日的历史变化情况
     */
    @State private var accountSpotDayHistorySyncTimer:Timer?
    
    private var accountInfo:AccountGeneralModelData
    
    private var spotInfo:SpotInfo
    
    init () {
        self.accountInfo = AccountGeneralModelData.sharedInstance
        self.spotInfo = SpotInfo.sharedInstance
    }
    
    /**
     开始同步账户现货信息的任务
     */
    func startAccountSpotAssertSyncTimer() {
        accountSpotAssertSyncTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.accountSpotAssertSync()
        }
    }
    
    /**
     关闭同步账户现货信息任务
     */
    func stopAccountSpotAssertSyncTimer() {
        // 停止定时器
        accountSpotAssertSyncTimer?.invalidate()
        accountSpotAssertSyncTimer = nil
    }
    
    /**
     开始同步按日账户历史信息任务
     */
    func startAccountSpotDayHistorySyncTimer() {
        accountSpotDayHistorySyncTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.accountSpotDayHistorySync()
        }
    }
    
    /**
     关闭同步按日账户历史信息任务
     */
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
    
    /**
     设置账户现货信息
     */
    func setAccountSpotInfo(data: JSON) {
        //更新 spotList
        var existSpot: [String] = []
        
        for (_,item):(String, JSON) in data["balances"] {
            
            if let existItem = accountInfo.accountSpot.first(where: { (spotInfo) -> Bool in
                spotInfo.baseAsset == item["asset"].stringValue
            }) {//存在，更新
                existItem.count = item["free"].doubleValue
            } else { //不存在，创建
                accountInfo.accountSpot.append(AccountSpotItem(
                    baseAsset: item["asset"].stringValue,
                    quoteAsset: accountInfo.spotUnit.rawValue,
                    count: item["free"].doubleValue
                ))
            }
            existSpot.append(item["asset"].stringValue)
        }
        
        //剔除现在不存在的
        accountInfo.accountSpot.removeAll { item in
            existSpot.firstIndex(of: item.baseAsset) == nil
        }
        
        //更新spotTotalValue
        var totalValue = Double(0.0)
        for accountSpotItem in accountInfo.accountSpot {
            let symbol = accountSpotItem.baseAsset + accountInfo.spotUnit.rawValue
            if let spotInfoItem = spotInfo.findSpotInfo(symbol: symbol) {
                totalValue += accountSpotItem.count * spotInfoItem.price
            }
        }
        
        accountInfo.spotTotalValue = totalValue
        
        //更新spotTotalCount
        accountInfo.spotTotalCount = accountInfo.accountSpot.count
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
            startTime: DateUtil.dateToTimestamp(date: startTime),
            endTime: DateUtil.dateToTimestamp(date: endTime),
            successCall: setAccountSpotDayHistory
        )
    }
    
    /**
     设置账户按日历史资产变化情况
     */
    func setAccountSpotDayHistory(data: JSON) {
        accountInfo.spotTotalValueDayHistory.removeAll()
        
        for (_,daySnapshot):(String,JSON) in data["snapshotVos"] {
            let snapshotVos = daySnapshot["data"]["balances"]
            
            let snapshotDate = DateUtil.timestarpToDate(timestamp: daySnapshot["updateTime"].doubleValue)
            
            let accountSpotDayInfo = AccountSpotDayInfo(
                date: snapshotDate,
                snapshotVos: snapshotVos,
                spotTotalValue: 0
            )
                        
            accountInfo.spotTotalValueDayHistory.append(accountSpotDayInfo)
            
            //计算总价值
            var symbolMapCount:[String:Double] = [:]
            for (_,rowJson) in snapshotVos {
                let symbol:String = rowJson["asset"].stringValue + accountInfo.spotUnit.rawValue
                
                symbolMapCount[symbol] = rowJson["free"].doubleValue
                
                //获取，该现货在该日期的价格
                BinanceApi.spotApi.kLineData(
                    symbol: symbol,
                    interval: .d_1,
                    startTime: snapshotDate,
                    limit: 1,
                    successCall: { (data, interval) in
                        
                        var res:[LineDataEntry] = []
                        // 遍历 JSON 数组
                        if let jsonArray = data.array {
                            res = jsonArray.map { json in
                                let openTime = json[0].int64Value
                                let open = json[1].doubleValue
                                let high = json[2].doubleValue
                                let low = json[3].doubleValue
                                let close = json[4].doubleValue
                                let volume = json[5].doubleValue
                                let closeTime = json[6].int64Value
                                
                                return LineDataEntry(
                                    openTime: Date(timeIntervalSince1970:  TimeInterval(openTime/1000)),
                                    closeTime: Date(timeIntervalSince1970:  TimeInterval(closeTime/1000)),
                                    open: open,
                                    close: close,
                                    high: high,
                                    low: low,
                                    volume: volume
                                )
                            }
                        }
                        
                        //记录或更新这条交易日信息
                        spotInfo.addCoinTradingDayInfo(date: snapshotDate, symbol: symbol, value: res[0])
                        
                        accountSpotDayInfo.spotTotalValue += (symbolMapCount[symbol] ?? 0.0) * res[0].close
                    },
                    failureCall: {error in
                        print(error)
                    }
                )
            }
            
//
//            BinanceApi.spotApi.tradingDayPrice (
//                symbols: Array(symbolMapCount.keys),
//                successCall: {data in
//                    for (_,item):(String,JSON) in data {
//                        let symbol = item["symbol"].stringValue
//                        let price = item["lastPrice"].doubleValue
//                        let date = Date(timeIntervalSince1970: item["openTime"].doubleValue)
//                        
//                        //记录或更新这条交易日信息
//                        spotInfo.addCoinTradingDayInfo(date: date, symbol: symbol, value: item)
//                        
//                        accountSpotDayInfo.spotTotalValue += (symbolMapCount[symbol] ?? 0.0) * price
//                    }
//                }
//            )
//            
        }
        
    }
    
    
}



