
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
    
    var count: Int = 0
    
    /**
     最高价格
     */
    var maxPrice: Double = 0
    
    /**
     最低价格
     */
    var minPrice: Double = 0
    
    /**
        下一次加载数据时的startTIme
    */
    var startTime:Date = Date()
    
    
    

    func getStartTime(endTime:Date) -> Date{
        return DateUtil.calDate(from: endTime, days: -1 * 30, timeUnit: kLineInterval.rawValue.timeUnit) ?? Date()
    }

    func getIndex(_ index:Int) -> LineDataEntry {
        return dataset[index]
    }
    /**
     加载数据
     */
    func loadLineData(whenComplate: @escaping (Bool) -> Void) {
        print("开始获取k线数据, 当前\(self.dataset.count)条")
        BinanceApi.spotApi.kLineData(
            symbol: symbol,
            interval: kLineInterval,
            startTime: getStartTime(endTime: startTime),
            limit: 30,
            successCall: { data in
                //更新dataset
                
                let newData = self.generalJSONToLineDataEntryArray(data: data).sorted(by:{$0.openTime > $1.openTime})
                
                self.dataset.append(contentsOf: newData)
                
                //更新count，max，min等
                self.count = self.dataset.count

                if self.count != 0 {
                    var minV:Double = self.dataset[0].low
                    var maxV:Double = 0

                    for entry in self.dataset {
                        minV = min(minV, entry.low)
                        maxV = max(maxV, entry.high)
                    }
                    self.maxPrice = maxV
                    self.minPrice = minV

                    //更新startTime
                    self.startTime = self.getStartTime(endTime: self.startTime)
                
                }

                print("获取k线数据完成共： \(self.dataset.count) - \(self.count) 条")
                print("maxprice： \(self.maxPrice) - minprice \(self.minPrice)")
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
