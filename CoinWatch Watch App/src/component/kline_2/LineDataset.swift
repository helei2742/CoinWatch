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

    /**
        上一次网络请求时的k线频率
    */
    var lastKLineInterval: KLineInterval
    
    /**
        k线频率
    **/
    var kLineInterval: KLineInterval
    
    /**
        一次网络请求价值的k线数据限制
     */
    var onceLoadLineDataCountLimit:Int = 30
    
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
    
    


    /**
        刷新最新的k线数据，也就是dataset数组里的最后一个的数据
    */
    func refreshNewLineData() -> Void {
        if dataset.isEmpty {
            print("刷新k线数据失败，当前数据集为null")
            return
        }
        let startTime: Date = dataset.last!.openTime

        loadLineData(
            startTime: startTime,
            limit: 1,
            actionOfNewData:{ newData in
                if newData.isEmpty {
                    print("最新的k线数据为null，startTime:\(self.startTime), kLineInterval:\(self.kLineInterval)")
                    return
                }
                if self.dataset.isEmpty {
                    print("数据集信息为null,")
                    return
                }
                

                self.dataset[self.dataset.count - 1] = newData[0]
            },
            whenComplate: { res in

            }
        )
    }

    /**
     加载数据
     */
    func loadLineData(whenComplate: @escaping (Bool) -> Void) {
        loadLineData(
            startTime: getStartTime(endTime: startTime),
            limit: onceLoadLineDataCountLimit,
            actionOfNewData: { newData in
                self.dataset.append(contentsOf: newData)
            },
            whenComplate: whenComplate)
    }


    /**
     加载数据
     */
    func loadLineData(
        startTime: Date,
        limit: Int,
        actionOfNewData: @escaping ([LineDataEntry]) -> Void,
        whenComplate: @escaping (Bool) -> Void
    ) {
        //判断是否是重新获取k线数据，还是继续加k线数据
        let reload = lastKLineInterval != kLineInterval

        //更新上次请求的k线频率
        lastKLineInterval = kLineInterval

        //不是重新加载数，并且标识已经完成，直接返回false
        if !reload, isEndOfDataset {
            whenComplate(false)
        }


        print("开始获取k线数据, reload(\(reload)) 当前\(self.dataset.count)条")
        BinanceApi.spotApi.kLineData(
            symbol: symbol,
            interval: kLineInterval,
            startTime: startTime,
            limit: limit,
            successCall: { data in
                //更新dataset
                let newData = self.generalJSONToLineDataEntryArray(data: data).sorted(by:{$0.openTime > $1.openTime})
                if newData.count == 0 {
                    self.isEndOfDataset = true
                }

                if reload { //是重新加载，清除之前所有的
                    self.dataset.removeAll()
                }

                actionOfNewData(newData)
                self.dataset.sort(by:{$0.openTime < $1.openTime})

                //更新count，max，min等
                self.count = self.dataset.count

                if self.count != 0 {
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
        var minV:Double = self.dataset[start].low
        var maxV:Double = 0

        for i in (start...end) {
            minV = min(minV, dataset[i].low)
            maxV = max(maxV, dataset[i].high)
        }
        self.maxPrice = maxV
        self.minPrice = minV
        print("计算最小值和最大值完成 max\(maxV) min \(minV)")
    }
    
    
    
    func getStartTime(endTime:Date) -> Date{
        return DateUtil.calDate(from: endTime, days: -1 * 30, timeUnit: kLineInterval.rawValue.timeUnit) ?? Date()
    }

    func getIndex(_ index:Int) -> LineDataEntry? {
        
        if dataset.isEmpty || index >= dataset.count || index < 0 {
            return nil
        }

        return dataset[index]
    }

   /**
       计算均线
   */
    func calculateMA(maIntervals:[MATypeItem] = [MAType.ma_5]) -> Void{

       var i = 0
       for entry in dataset {
           for maInterval in maIntervals {
               let n = maInterval.interval
               if i < n - 1 {
                   continue
               }
               var sum:Double = 0
               for j in (0...n-1) {
                   sum += dataset[i-j].close
               }
               entry.dictOfMA[n] = sum/Double(n)
           }
           i += 1
       }
   }
    
    
    /**
        计算Boll指标
    */
    func calculateBoll(
        maInterval:Int = 21,
        n: Double = 2
    ) -> Void {
        for i in maInterval-1...dataset.count-1 {
            let periodPrices = dataset[i-maInterval+1...i].map{$0.close}
            let sum = periodPrices.reduce(0, +)
            let average = sum / Double(maInterval)

            let variance = periodPrices.map {pow($0 - average, 2)}.reduce(0, +) / Double(maInterval)
            let standardDeviation = sqrt(variance)

            let upper = average + (n * standardDeviation)
            let lower = average - (n * standardDeviation)

            dataset[i].bollLine = (upper, average, lower)
//            print("date - [\(dataset[i].openTime)], boll - [\(dataset[i].bollLine)]")
        }
    }

}
