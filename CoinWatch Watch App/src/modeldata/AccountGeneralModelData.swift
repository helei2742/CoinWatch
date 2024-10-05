//
//  AccountGeneralModelData.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import SwiftUI
import SwiftyJSON

/**
 账户信息
 主要为账户的资产信息，
 采用单例模式，任意界面的更改都全局有效
 */
@Observable
class AccountGeneralModelData: ObservableObject{
    static let sharedInstance = AccountGeneralModelData()
    
    private var spotInfo:SpotInfo = SpotInfo.sharedInstance
    /**
     现货资产总价值
     */
    var spotTotalValue: Double {
        get{
            var totalValue = Double(0.0)
            for accountSpotItem in accountSpot {
                let symbol = accountSpotItem.baseAsset + spotUnit.rawValue
                if let spotInfoItem = spotInfo.findSpotInfo(symbol: symbol) {
                    totalValue += accountSpotItem.count * spotInfoItem.newPrise
                }
            }
            return totalValue
        }
    }
    
    /**
     现货资产总数
     */
    var spotTotalCount: Int = 0
    
    /**
     现货资产单位
     */
    var spotUnit: CoinUnit = .USDT
    
    /**
     合约资产总数
     */
    var contractTotalValue: Double
    
    /**
     合约仓位个数
     */
    var contractTotalCount: Int = 0
    
    /**
     合约资产单位
     */
    var contractUnit: CoinUnit       
    
    /**
     现货资产日变化情况
     */
    var spotTotalValueDayHistory:[AccountSpotDayInfo] = [
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-22 11:11:11"), spotTotalValue: 18.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-21 11:11:11"), spotTotalValue: 12.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-20 11:11:11"), spotTotalValue: 10000.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-19 11:11:11"), spotTotalValue: 7002.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-18 11:11:11"), spotTotalValue: 1293.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-17 11:11:11"), spotTotalValue: 90.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-16 11:11:11"), spotTotalValue: 80.0),
//        
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-15 11:11:11"), spotTotalValue: 80.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-14 11:11:11"), spotTotalValue: 8009.0),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-13 11:11:11"), spotTotalValue: 123),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-12 11:11:11"), spotTotalValue: 1242),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-11 11:11:11"), spotTotalValue: 3322),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-10 11:11:11"), spotTotalValue: 3213),
//        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-09 11:11:11"), spotTotalValue: 3000.0)
    ]
    
    /**
     账户现货列表
     */
    var accountSpot:[AccountSpotItem]
    
    private init() {
        // 初始化代码
        
        contractTotalValue = 0.0
        contractUnit = .USDT
        
        accountSpot = []
        accountSpot.append(AccountSpotItem(baseAsset: "USDT", quoteAsset: "USDT", count: 10))
        accountSpot.append(AccountSpotItem(baseAsset: "BTC", quoteAsset: "USDT", count: 20))
    }
    
    /**
     获取币种数量
     */
    func coinCount(base: String) -> Double {
        if let spot = accountSpot.first(where: { item in
            item.baseAsset == base
        }) {
            return spot.count
        }
        return 0
    }
}

@Observable
class AccountSpotDayInfo: ObservableObject, Equatable {
    static func == (lhs: AccountSpotDayInfo, rhs: AccountSpotDayInfo) -> Bool {
        lhs.date == rhs.date
    }
    
    /**
     日期
     */
    var date: Date
    
    /**
     当日的一些价格数据，如：
     {
          "data":{
             "balances":[
                {
                   "asset":"BTC",
                   "free":"0.09905021",
                   "locked":"0.00000000"
                },
                {
                   "asset":"USDT",
                   "free":"1.89109409",
                   "locked":"0.00000000"
                }
             ],
             "totalAssetOfBtc":"0.09942700"
          },
          "type":"spot",
          "updateTime":1576281599000
       }
     */
    var snapshotVos: JSON
    
    /**
     现货资产总价值
     */
    var spotTotalValue: Double
    
    init(date: Date, snapshotVos: JSON? = nil, spotTotalValue: Double) {
        self.date = date
        self.snapshotVos = snapshotVos ?? JSON()
        self.spotTotalValue = spotTotalValue
    }
}


@Observable
class AccountSpotItem: Identifiable, Equatable{
    static func == (lhs: AccountSpotItem, rhs: AccountSpotItem) -> Bool {
        lhs.baseAsset == rhs.baseAsset && lhs.quoteAsset == rhs.quoteAsset
    }
    
    static private var nextId = 0
    
    /**
     现货名 如 BTC/USDT的BTC
     */
    var baseAsset: String
    
    /**
     计算单位 如 BTC/USDT的USDT
     */
    var quoteAsset: String
    
    private var internalCount: Double = 0
    var count: Double {
        set {
            self.lastCount = count
            internalCount = newValue
        }
        
        get {
            return internalCount
        }
    }
    /**
     上一次的个数
     */
    var lastCount: Double
    
    private var internalAssetValue: Double = 0
    var assetValue: Double {
        set {
            self.lastAssetValue = assetValue
            internalAssetValue = newValue
        }
        get {
            if let spotInfo = SpotInfo.sharedInstance.findSpotInfo(base: baseAsset, quote: quoteAsset) {
                return spotInfo.newPrise  * count
            }
            
            return 0
        }
    }
    /**
     上一次的价值
     */
    var lastAssetValue: Double
    
    
    init(baseAsset: String,
         quoteAsset: String,
         count: Double
    ) {
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        
        self.internalCount = count
        self.lastCount = count
        self.lastAssetValue = 0.0
    }
}

