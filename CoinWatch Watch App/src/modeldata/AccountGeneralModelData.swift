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
    
    
    var spotTotalValue: Double//现货资产总价值
    var spotTotalCount: Int = 0    //现货资产总数
    var spotUnit: CoinUnit = .USDT      //现货资产单位
    
    var contractTotalValue: Double //合约资产总数
    var contractTotalCount: Int = 0    //合约仓位个数
    var contractUnit: CoinUnit       //合约资产单位
    
    /**
     现货资产日变化情况
     */
    var spotTotalValueDayHistory:[AccountSpotDayInfo] = [
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-22 11:11:11"), spotTotalValue: 18.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-21 11:11:11"), spotTotalValue: 12.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-20 11:11:11"), spotTotalValue: 10000.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-19 11:11:11"), spotTotalValue: 7002.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-18 11:11:11"), spotTotalValue: 1293.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-17 11:11:11"), spotTotalValue: 90.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-16 11:11:11"), spotTotalValue: 80.0),
        
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-15 11:11:11"), spotTotalValue: 80.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-14 11:11:11"), spotTotalValue: 8009.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-13 11:11:11"), spotTotalValue: 123),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-12 11:11:11"), spotTotalValue: 1242),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-11 11:11:11"), spotTotalValue: 3322),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-10 11:11:11"), spotTotalValue: 3213),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-09 11:11:11"), spotTotalValue: 3000.0)
    ]
    
    /**
     账户现货列表
     */
    var accountSpot:[AccountSpotItem]
    
    private init() {
        // 初始化代码
        spotTotalValue = 11820.89
        
        contractTotalValue = 0.0
        contractUnit = .USDT
        
        accountSpot = []
    }
    
    
}

@Observable
class AccountSpotDayInfo: ObservableObject {
    var date: Date
    
    var snapshotVos: JSON
    
    var spotTotalValue: Double//现货资产总价值
    
    init(date: Date, snapshotVos: JSON? = nil, spotTotalValue: Double) {
        self.date = date
        self.snapshotVos = snapshotVos ?? JSON()
        self.spotTotalValue = spotTotalValue
    }
}


@Observable
class AccountSpotItem: Identifiable{
    static private var nextId = 0
    
    var baseAsset: String   // 现货名 如 BTC/USDT
    var quoteAsset: String  // 计算单位 如 BTC/USDT
    
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
    var lastCount: Double //上一次的个数
    
    private var internalAssetValue: Double = 0
    var assetValue: Double {
        set {
            self.lastAssetValue = assetValue
            internalAssetValue = newValue
        }
        get {
            if let spotInfo = SpotInfo.sharedInstance.findSpotInfo(base: baseAsset, quote: quoteAsset) {
                return spotInfo.price  * count
            }
            
            return 0
        }
    }
    var lastAssetValue: Double //上一次的资产价值
    
    private var internalNewPrice: Double = 0
    //最新价格，相对于 计算单位
    var newPrise: Double{
        set {
            self.lastNewPrise = newPrise
            internalNewPrice = newValue
        }
        get {
            if let spotInfo = SpotInfo.sharedInstance.findSpotInfo(base: baseAsset, quote: quoteAsset) {
                return spotInfo.price
            }
            
            return 0
        }
    }
    var lastNewPrise: Double  //上一次的最新价格
    
    init(baseAsset: String,
         quoteAsset: String,
         count: Double
    ) {
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        
        self.internalCount = count
        self.lastCount = count
        
        self.lastAssetValue = 0.0
        
        self.lastNewPrise = 0
    }
}

