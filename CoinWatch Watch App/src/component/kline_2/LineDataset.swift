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


    var lastKLineInterval: KLineInterval
    
    /**
        k线频率
    **/
    var kLineInterval: KLineInterval
    
    /**
        具体的数据
    */
    var dataset: [LineDataEntry]


    /**
        数据集是否加载完毕
    */
    var isEndOfDataset:Bool = false


    /**
        当前显示窗口的起始位置的下标
    */
    var windowStartIndex: Int

    /**
        窗口长度
    */
    var windowLength: Int

    init(
        symbol: String,
        kLineInterval: KLineInterval,
        dataset: [LineDataEntry],
        windowStartIndex: Int,
        windowLength: Int
    ) {
        self.symbol = symbol
        self.kLineInterval = kLineInterval
        self.lastKLineInterval = kLineInterval
        self.dataset = dataset
    
        self.windowStartIndex = windowStartIndex
        self.windowLength = windowLength
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
        //判断是否是重新获取k线数据，还是继续加k线数据
        let reload = lastKLineInterval != kLineInterval

        //更新上次请求的k线频率
        lastKLineInterval = kLineInterval

        if isEndOfDataset {
            whenComplate(false)
        }


        print("开始获取k线数据, reload(\(reload)) 当前\(self.dataset.count)条")
        BinanceApi.spotApi.kLineData(
            symbol: symbol,
            interval: kLineInterval,
            startTime: getStartTime(endTime: startTime),
            limit: 30,
            successCall: { data in
                //更新dataset
                let newData = self.generalJSONToLineDataEntryArray(data: data)
                if newData.count == 0 {
                    self.isEndOfDataset = true
                }

                if reload { //是重新加载，清除之前所有的
                    self.dataset.removeAll()
                }
                
                self.dataset.append(contentsOf: newData)
                self.dataset.sort(by:{$0.openTime < $1.openTime})
                
                //更新count
                self.count = self.dataset.count

                if self.count != 0 {
                    //更新startTime
                    self.startTime = self.getStartTime(endTime: self.startTime)
                }

                print("获取k线数据完成共： \(self.dataset.count) - \(self.count) 条")
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

    /**
        根据爽口计算最大价格和最小价格
    */
    func calMaxMinPriceOfWindow(start: Int) {
        calMaxMinPriceOfWindow(start: start, end: start + windowLength - 1)
    }

    func calMaxMinPriceOfWindow(start: Int, end: Int) {
        print("计算最小值和最大值 from-\(start) to-\(end)")
        if self.dataset.isEmpty || start < 0 || end >= dataset.count{
            print("数据为不合法，无法计算最值")
            return
        }
        var minV:Double = self.dataset[0].low
        var maxV:Double = 0

        for i in (start...end) {
            minV = min(minV, dataset[i].low)
            maxV = max(maxV, dataset[i].high)
        }
        self.maxPrice = maxV
        self.minPrice = minV
        print("计算最小值和最大值完成 max\(maxV) min \(minV)")
    }
    

   /**
       计算均线
   */
   func calculateMA(maIntervals:[MAType] = [.ma_5]) -> Void{
       var intervalWindow: [Int:(interval:Int, windowLength:Int, windowTotal:Double)] = [:]
       for element in maIntervals {
            let interval = element.rawValue.interval
           intervalWindow[interval] = (interval, 0, 0)
       }
     

       var currentIdx = dataset.count - 1
       for entry in dataset {
           for (_, value) in intervalWindow {
               var (interval, windowLength, windowTotal) = value

               if windowLength < interval {
                   windowLength += 1
                   windowTotal += entry.close
               } else {
                   windowTotal = windowTotal - dataset[(currentIdx + windowLength - 1)].close + entry.close

                   let ma = windowTotal / Double(windowLength)
                   entry.addMA(maInterval: interval, value: ma)
               }
               
               currentIdx -= 1
           }
       }
   }

}
