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
struct SpotInfoSyncTimer {
    @State private  var spotInfoSyncTimer:Timer?


    @State private var spotInfo:SpotInfo = SpotInfo.sharedInstance
    @State var accountInfo:AccountGeneralModelData = AccountGeneralModelData.sharedInstance

    
    func startTimer() {
        // 创建并启动定时器
        spotInfoSyncTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.spotInfoSync()
        }
        // 设置定时器每5秒执行一次请求
//        spotInfoSyncTimer = Timer.publish(every: 10, on: .main, in: .common)
//            .autoconnect()
//            .sink { _ in
//                self.spotInfoSync()
//            }
    }

    func stopTimer() {
        // 停止定时器
//      spotInfoSyncTimer?.invalidate()
        spotInfoSyncTimer = nil
    }

    /**
     同步现货信息
     */
    func spotInfoSync() {
        // 先检查用户账户信息有没有同步到现货持仓数据
        let accountSpot = accountInfo.accountSpot

        if accountSpot.isEmpty {
            //没有数据，不进行同步
            print("用户账户现货持仓数据暂未同步")
        } else {
            
            let symbols = accountSpot.map { old in
                return CommonUtil.generalCoinSymbol(base: old.baseAsset, quote: accountInfo.spotUnit.rawValue)
            }
            print("开始同步现货信息，\(symbols)")
            BinanceApi.spotApi.coinsNewPrice(
                symbols: symbols,
                whenComplate: setSpotInfoFromResponse
            )
        }
    }

     /**
      网络请求到现货信息后处理
      */
    func setSpotInfoFromResponse(data : JSON?) {
        if data == nil {
            print("现货信息获取失败")
            return
        }
        
        print("现货信息获取成功\(data!)")
        
        for (_,item):(String, JSON) in data! {
            let symbol = item["symbol"].stringValue
            let quote = accountInfo.spotUnit.rawValue
            let base = symbol.substring(to: symbol.count - quote.count) ?? "error"
            
            spotInfo.updateSpotInfo(base: base, quote: quote, price: item["price"].doubleValue)
        }
        print("现货信息同步完成，\(String(describing: spotInfo.spotInfoList))")
    }
}
