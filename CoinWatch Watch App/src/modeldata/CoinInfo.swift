//
//  CoinInfo.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

/**
    用于在CoinDetailPage里显示的信息数据
 */
@Observable
class CoinInfo: Identifiable{
    
    var base: String
    var quote: String
    
    var deepInfo: DeepInfo
    
    init(
        base:String = "BTC",
        quote:String = "USDT",
        deepInfo: DeepInfo = DeepInfo()
    ) {
        
        self.base = base
        self.quote = quote
        self.deepInfo = deepInfo
        
        let asks =  [
            [
                "62614.01000000",
                "2.89985000"
            ],
            [
                "62614.02000000",
                "0.04700000"
            ],
            [
                "62614.04000000",
                "0.00010000"
            ],
            [
                "62614.05000000",
                "0.00359000"
            ],
            [
                "62614.21000000",
                "0.00010000"
            ],
            [
                "62614.28000000",
                "0.00010000"
            ],
            [
                "62614.35000000",
                "0.00010000"
            ],
            [
                "62614.41000000",
                "0.00010000"
            ],
            [
                "62614.43000000",
                "0.00010000"
            ],
            [
                "62614.50000000",
                "0.04410000"
            ]
        ]
        
        let bids = [
            [
                "00000000",
                "2.04906000"
            ],
            [
                "62613.99000000",
                "0.01391000"
            ],
            [
                "62613.98000000",
                "0.00900000"
            ],
            [
                "62613.97000000",
                "0.00010000"
            ],
            [
                "62613.96000000",
                "0.00927000"
            ],
            [
                "62613.94000000",
                "0.00022000"
            ],
            [
                "62613.93000000",
                "0.00010000"
            ],
            [
                "62613.81000000",
                "0.00010000"
            ],
            [
                "62613.80000000",
                "0.00010000"
            ],
            [
                "62613.78000000",
                "0.11811000"
            ]
        ]
        
        
        for pair in asks {
            self.deepInfo.asks.append(DeepInfoPoint(pair[0], pair[1]))
        }
        
        for pair in bids {
            self.deepInfo.bids.append(DeepInfoPoint(pair[0], pair[1]))
        }
    }
}


struct DeepInfo {
    var bids: [DeepInfoPoint] = []
    var asks: [DeepInfoPoint] = []
}

class DeepInfoPoint {
    var price: Double = 1
    var volume: String = ""
    
    init(_ price: String, _ volume: String) {
        self.price =  Double(price) ?? 0
        self.volume = volume
    }
}

