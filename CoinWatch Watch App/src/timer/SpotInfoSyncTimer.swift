//
//  SpotInfoSyncTimer.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/23.
//

import Foundation
import SwiftUI
import SwiftyJSON

/**
更新现货信息
**/
class SpotInfoSyncTimer {
    @State var spotInfoSyncTimer:Timer?


    private var spotInfo:SpotInfo
    private var accountInfo:AccountGeneralModelData



    init (spotInfo: SpotInfo, accountInfo: AccountGeneralModelData) {
        self.spotInfo = spotInfo
        self.accountInfo = accountInfo
    }
    
    
    func startTimer() {
        // 创建并启动定时器
        spotInfoSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.spotInfoSync()
        }
    }

    func stopTimer() {
        // 停止定时器
        spotInfoSyncTimer?.invalidate()
        spotInfoSyncTimer = nil
    }

    func spotInfoSync() {
        // 先检查用户账户信息有没有同步到现货持仓数据
        let accountSpot = accountInfo.accountSpot

        if accountSpot.isEmpty {
            //没有数据，不进行同步
            print ("用户账户现货持仓数据暂未同步")
        } else {
            BinanceApi.spotApi.coinsNewPrice(
                symbols: accountSpot.map { old in
                    return CommonUtil.generalCoinPrintSymbol(base: old.baseAsset, quote: accountInfo.spotUnit.rawValue)
                },
                successCall: setSpotInfoFromResponse
            )
        }

    }

 
    func setSpotInfoFromResponse(data : JSON) {
        var spotInfoList = spotInfo.spotInfoList
        
        for (index,item):(String, JSON) in data {
            var symbol = item["symbol"].stringValue
            let quote = accountInfo.spotUnit.rawValue
            let base = symbol.substring(to: symbol.count - quote.count) ?? "error"
            
            if let existItem = spotInfo.findSpotInfo(symbol: symbol) {
                existItem.price = item["price"].doubleValue
            } else {
                spotInfoList?.append(SpotInfoItem(
                    base: base,
                    quote: quote,
                    price: item["price"].doubleValue
                ))
            }
        }
    }
}
