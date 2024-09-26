//
//  LineDataset.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/25.
//

import Foundation
import SwiftUI
import SwiftyJSON

/**
 线的数据集
 */
@Observable
class LineDataset {
    
    /**
     币种名称，如 BTCUSDT
     */
    var symbol: String
    
    var kLineInterval: KLineInterval
    
    var dataset: [LineDataEntry]
    
    init(symbol: String, kLineInterval: KLineInterval, dataset: [LineDataEntry]) {
        self.symbol = symbol
        self.kLineInterval = kLineInterval
        self.dataset = dataset
    }
    
    /**
     渲染当前视图需使用的dataset
     */
    var usableDataset: [LineDataEntry] {
        get {
            return dataset
        }
    }
    
    var count: Int {
        get {
            return dataset.count
        }
    }
    
    
    /**
     最高价格
     */
    var maxPrice: Double {
        get {
            if !dataset.isEmpty {
                var res:Double = 0
                for entry in dataset {
                    res = max(res, entry.open)
                }
                return res
            }
            return 0
        }
    }
    
    /**
     最低价格
     */
    var minPrice: Double {
        get {
            if !dataset.isEmpty {
                var res:Double = dataset[0].open
                for entry in dataset {
                    res = min(res, entry.open)
                }
                return res
            }
            return 0
        }
    }
    
    
    
    
    /**
     加载数据
     */
    func loadLineData(whenComplate: @escaping (Bool) -> Void) {
        print("开始获取k线数据")
        BinanceApi.spotApi.kLineData(
            symbol: symbol,
            interval: kLineInterval,
            //            startTime: Int? = ,
            limit: 30,
            successCall: { data in
                //更新dataset
                
                let newData = self.generalJSONToLineDataEntryArray(data: data).sorted(by:{$0.openTime > $1.openTime})
                self.dataset.append(contentsOf: newData)
                
                print("获取k线数据完成共： \(self.dataset.count) 条")
                whenComplate(true)
            },
            failureCall: { error in
                whenComplate(false)
            }
        )
    }
    
    func generalJSONToLineDataEntryArray(data: JSON) -> [LineDataEntry] {
        print("解析k线数据")
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
                    low: low
                )
            }
        }
        print("解析k线数据success\n")
        return res
    }
}
