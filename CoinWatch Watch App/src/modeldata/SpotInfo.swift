//
//  SpotInfo.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI
import os.lock


class SpotInfo: Identifiable, ObservableObject {
    static private var nextId = 0
    static private var lock = os_unfair_lock_s()
    
    @Published var id: Int
    var baseAssert: String   // 现货名 如 BTC/USDT
    var quoteAssert: String  // 计算单位 如 BTC/USDT
    
    
    @Published var assertValue: Double //资产价值，相对于 计算单位
    @Published var lastAssertValue: Double
    
    @Published var newPrise: Double   //最新价格，相对于 计算单位
    @Published var lastNewPrise: Double
    
    init(baseAssert:String?="BTC",
         quoteAssert:String?="USDT",
         assertValue: Double?=0.0,
         newPrise: Double?=0.0
    ) {
        
        self.baseAssert = baseAssert ?? "BTC"
        self.quoteAssert = quoteAssert ?? "USDT"
        
        self.assertValue = assertValue ?? 1.0
        self.lastAssertValue = assertValue ?? 0.0
        
        self.newPrise = newPrise ?? 1.0
        self.lastNewPrise = newPrise ?? 1.0
        
        os_unfair_lock_lock(&SpotInfo.lock)
        self.id = SpotInfo.nextId
        SpotInfo.nextId += 1
        os_unfair_lock_unlock(&SpotInfo.lock)
    }
}
