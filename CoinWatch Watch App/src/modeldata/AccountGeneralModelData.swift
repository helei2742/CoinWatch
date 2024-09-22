//
//  AccountGeneralModelData.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation


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
    
    var spotList: [SpotInfo] = [
        SpotInfo(baseAssert: "BTC"), SpotInfo(baseAssert: "ETH"),
        SpotInfo(baseAssert: "DOGE"), SpotInfo(baseAssert: "SOL")
    ]
//
    private init() {
            // 初始化代码
        spotTotalValue = 11820.89
        spotUnit = .USDT
        
        contractTotalValue = 0.0
        contractUnit = .USDT
    }
    
    
}

class AccountSpotDayInfo: ObservableObject {
    var date: Date
    
    @Published var spotTotalValue: Double//现货资产总价值
    
    init(date: Date?, spotTotalValue: Double?) {
        self.date = date ?? Date()
        
        self.spotTotalValue = spotTotalValue ?? 0.0
    }
}
