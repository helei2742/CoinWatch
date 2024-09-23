//
//  AccountGeneralModelData.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import SwiftUI
import SwiftyJSON

class AccountGeneralModelData: ObservableObject{
    static let sharedInstance = AccountGeneralModelData()
    
    
    @Published var spotTotalValue: Double//现货资产总价值
    @Published var spotTotalCount: Int = 0    //现货资产总数
    @Published var spotUnit: CoinUnit        //现货资产单位
    
    @Published var contractTotalValue: Double //合约资产总数
    @Published var contractTotalCount: Int = 0    //合约仓位个数
    @Published var contractUnit: CoinUnit       //合约资产单位
    
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


    @State var accountSpot:[AccountSpotItem]
    // var spotList: [SpotInfo] = [
    //     SpotInfo(baseAssert: "BTC"), SpotInfo(baseAssert: "ETH"),
    //     SpotInfo(baseAssert: "DOGE"), SpotInfo(baseAssert: "SOL")
    // ]

    private init() {
            // 初始化代码
        spotTotalValue = 11820.89
        spotUnit = .USDT
        
        contractTotalValue = 0.0
        contractUnit = .USDT
        
        accountSpot = []
    }
    
    
}

class AccountSpotDayInfo: ObservableObject {
    var date: Date
    
    var snapshotVos: JSON

    @Published var spotTotalValue: Double//现货资产总价值
    
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

     var newPrise: Double   //最新价格，相对于 计算单位
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
        
        self.newPrise = 0
        self.lastNewPrise = 0
    }
}

