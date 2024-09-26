//
//  MergeView.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//
import SwiftUI
import Foundation
import Charts
import SwiftyJSON

//
//  MergeView.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//
import SwiftUI
import Foundation

struct MergeView: View {
    var data:[Candlestick] = []

    var kInterval: Int? = 1
    
    var dateUnit: TimeUnit? = .d

    var maxPrice: Double = 0

    var minPrice: Double = 0

    var maIntervals: [Int] = [1, 5, 20]
        
    // 需要使用 mutating 来允许修改
   mutating func updateData(newValue: [Candlestick]) {
//       print("add\(newValue[0].high)" )
       for item in newValue {
           data.append(item)
       }
       print("data\(data)")
   }
    
    init (
        data:[Candlestick],
        interal:Int,
        kLineInterval: KLineInterval
    ) {
        self.data = data
        self.kInterval = kLineInterval.rawValue.interval
        self.dateUnit = kLineInterval.rawValue.timeUnit

        self.maxPrice = self.data.map{ $0.high }.max() ?? 0
        self.minPrice = self.data.map{ $0.low }.max() ?? 0
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let height:CGFloat = geometry.size.height
            
                let itemWidth:CGFloat = geometry.size.width / CGFloat(data.count)
                let heightRatio:Double = height / (maxPrice - minPrice)
                    
                Chart(data, id: \.openTime) { candlestick in
                    //k线图
//                    CandlestickChart(
//                        heightRatio: heightRatio,
//                        itemWidth: itemWidth
//                    )
//                    .generalChart(candlestick: candlestick)
                    
                    PointMark (
                        x: .value("日期", candlestick.openTime, unit: .day),
                        y: .value("美元", candlestick.close)
                    )
                    .symbol {
                        CandlesstickItem(
                            candlestick: candlestick,
                            heightRatio: heightRatio,
                            itemWidth: itemWidth
                        )
                        .fill(Color.green) // 设置图形的填充颜色
//                        .frame(width: 100, height: 20) // 设置图形的大小
                    }
//                    .symbol(
//                        symbol:
//                            {
//                            CandlesstickItem(
//                                candlestick: candlestick,
//                                heightRatio: heightRatio,
//                                itemWidth: itemWidth
//                            )
                            
//                        }
//                    )
                    
                    //均线图
                    ForEach(maIntervals, id: \.asNLGValue) { maInterval in
                        MAChart(maInterval: maInterval)
                            .generalChart(candlestick: candlestick)
                    }

                    //Boll
                    
                }

            }.onAppear{

                
                
                //计算ma
                Candlestick.calculateMA(data: data, maIntervals: maIntervals)
                
                print(self.data)
            }
        }
    }
}

#Preview {
//    :[Candlestick] = []
    // 将数组转换为 Data 对象
    if let data = try? JSONSerialization.data(withJSONObject: response, options: []) {
        
        // 使用 SwiftyJSON 解析
        let json = try? JSON(data: data)

        
        // 遍历 JSON 数组
        if let jsonArray = json?.array {
    
            var dataArray = jsonArray.map { json in
                let ts = json[0].int64Value
//                            print("tts-\(Date(timeIntervalSince1970:  TimeInterval(ts/1000)))")
                let open = json[1].doubleValue
                let high = json[2].doubleValue
                let low = json[3].doubleValue
                let close = json[4].doubleValue
                let volume = json[5].doubleValue
                
                return  Candlestick(
                    openTime: Date(timeIntervalSince1970:  TimeInterval(ts/1000)),
                        volume: volume,
                        open: open,
                        close: close,
                        high: high,
                        low: low
                    )
                
            }
            MergeView(data:dataArray, interal: 5, kLineInterval: .M_1)

//            var mutableSelf = self
//            mutableSelf.updateData(newValue: dataArray)
        }
    }
    

  
}

let response:[[Any]] =
[
[
    1725926400000,
    "57042.01000000",
    "58044.36000000",
    "56386.40000000",
    "57635.99000000",
    "23626.78126000",
    1726012799999,
    "1349365460.09005710",
    2843148,
    "11690.37506000",
    "667774722.69939110",
    "0"
],
[
    1726012800000,
    "57635.99000000",
    "57981.71000000",
    "55545.19000000",
    "57338.00000000",
    "33026.56757000",
    1726099199999,
    "1875738697.37841530",
    4045103,
    "15979.30786000",
    "907634258.56498910",
    "0"
],
[
    1726099200000,
    "57338.00000000",
    "58588.00000000",
    "57324.00000000",
    "58132.32000000",
    "31074.40631000",
    1726185599999,
    "1802848638.07570170",
    3706764,
    "14783.00418000",
    "857572456.51008690",
    "0"
],
[
    1726185600000,
    "58132.31000000",
    "60625.00000000",
    "57632.62000000",
    "60498.00000000",
    "29825.23333000",
    1726271999999,
    "1760671733.54929960",
    3378012,
    "15395.13731000",
    "909141733.97476540",
    "0"
],
[
    1726272000000,
    "60497.99000000",
    "60610.45000000",
    "59400.00000000",
    "59993.03000000",
    "12137.90901000",
    1726358399999,
    "728527024.34169630",
    1288784,
    "5570.22098000",
    "334303099.74321360",
    "0"
],
[
    1726358400000,
    "59993.02000000",
    "60395.80000000",
    "58691.05000000",
    "59132.00000000",
    "13757.92361000",
    1726444799999,
    "822410872.39069560",
    1552950,
    "6431.24697000",
    "384460724.57039670",
    "0"
],
[
    1726444800000,
    "59132.00000000",
    "59210.70000000",
    "57493.30000000",
    "58213.99000000",
    "26477.56420000",
    1726531199999,
    "1543273198.70274520",
    3145152,
    "12859.75840000",
    "749563220.80605080",
    "0"
],
[
    1726531200000,
    "58213.99000000",
    "61320.00000000",
    "57610.01000000",
    "60313.99000000",
    "33116.25878000",
    1726617599999,
    "1983378424.77570380",
    3918209,
    "16390.65993000",
    "981860543.27358150",
    "0"
],
[
    1726617600000,
    "60313.99000000",
    "61786.24000000",
    "59174.80000000",
    "61759.99000000",
    "36087.02469000",
    1726703999999,
    "2174000496.82077610",
    5167671,
    "18429.59712000",
    "1110622778.75108520",
    "0"
],
[
    1726704000000,
    "61759.98000000",
    "63850.00000000",
    "61555.00000000",
    "62947.99000000",
    "34332.52608000",
    1726790399999,
    "2153175931.17387170",
    4438284,
    "17609.62958000",
    "1104427424.52469690",
    "0"
],
[
    1726790400000,
    "62948.00000000",
    "64133.32000000",
    "62350.00000000",
    "63201.05000000",
    "25466.37794000",
    1726876799999,
    "1611195963.99080440",
    3969296,
    "12411.32227000",
    "785440558.81257280",
    "0"
],
[
    1726876800000,
    "63201.05000000",
    "63559.90000000",
    "62758.00000000",
    "63348.96000000",
    "8375.34608000",
    1726963199999,
    "528657852.31830240",
    1283611,
    "3877.73743000",
    "244802615.78455930",
    "0"
],
[
    1726963200000,
    "63348.97000000",
    "64000.00000000",
    "62357.93000000",
    "63578.76000000",
    "14242.19892000",
    1727049599999,
    "897477338.37351270",
    2145736,
    "6923.17369000",
    "436456231.95378810",
    "0"
],
[
    1727049600000,
    "63578.76000000",
    "64745.88000000",
    "62538.75000000",
    "63339.99000000",
    "24078.05287000",
    1727135999999,
    "1531015038.36802670",
    3999187,
    "12331.07643000",
    "784350440.71456530",
    "0"
],
[
    1727136000000,
    "63339.99000000",
    "63948.00000000",
    "62700.00000000",
    "63102.01000000",
    "15050.20607000",
    1727222399999,
    "952139351.65326200",
    2322887,
    "7296.74510000",
    "461633113.04447870",
    "0"
]
]
