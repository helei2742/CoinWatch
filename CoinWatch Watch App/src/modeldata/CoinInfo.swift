//
//  CoinInfo.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI
import SwiftyJSON


/**
    用于在CoinDetailPage里显示的信息数据
 */
@Observable
class CoinInfo: Identifiable{
    
    var base: String
    var quote: String
    
    var bids: [DeepInfoPoint]
    var asks: [DeepInfoPoint]
        
    init(
        base:String = "BTC",
        quote:String = "USDT"
    ) {
        
        self.base = base
        self.quote = quote
        
        self.asks =  []
        
        self.bids = []
    }
    
    
    /**
     网络请求获取深度信息
     */
    func loadDeepInfo(whenComplate: @escaping (Bool) -> Void) {
        print("获取深度信息中。。。。。\(base)-\(quote)")
        
        BinanceApi.spotApi.deepInfo(
            symbol: CommonUtil.generalCoinSymbol(base: base, quote: quote),
            limit: 50
        ) { [self] data in
                if data == nil {
                    whenComplate(false)
                    return
                }
                let bidsJson = data!["bids"]
                let asksJson = data!["asks"]
                
                
                self.generateDeepJSONToArray(asksJson: asksJson, bidsJson: bidsJson)
                
            print("获取深度信息完毕。。。。。\(self.base)-\(quote)")
                whenComplate(true)
            }
    }
    
    
    /**
        解析json，放入asks 和 bids中
     */
    func generateDeepJSONToArray(asksJson:JSON, bidsJson:JSON) {
        
        self.asks.removeAll()
        asksJson.array?.forEach({ itemJSON in
            self.asks.append(DeepInfoPoint(itemJSON[0].stringValue, itemJSON[1].stringValue))
        })
        
        self.bids.removeAll()
        bidsJson.array?.forEach({ itemJSON in
            self.bids.append(DeepInfoPoint(itemJSON[0].stringValue, itemJSON[1].stringValue))
        })
        
    }
}


class DeepInfoPoint {
    var price: Double = 1
    var volume: String = ""
    
    init(_ price: String, _ volume: String) {
        self.price =  Double(price) ?? 0
        self.volume = volume
    }
}



