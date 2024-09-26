//
///**
//    绘制均线图
//*/
//struct MALine: Shape {
//
//    let color: Color
//
//    /**
//        均线间隔
//    */
//    let maInterval: Int
//
//    /**
//        数据
//    */
//    let lineDataEntryList: [lineDataEntry]
//
//    /**
//        高的比例
//    */
//    let heightRatio: Double
//
//    /**
//        单个k线数据的宽度
//    */
//    let entryWidth: Double
//
//    func path(in rect: CGRect) -> Path {
//
//        Path { path in
//            if lineDataEntryList.isEmpty {
//                return
//            }
//            //绘制不同间隔的MA
//            var width:Double = entryWidth / 2
//            var isFirst:Bool = true
//            //ma的线
//            lineDataEntryList.forEach { dataEntry in
//
//                if let ma = dataEntry.dictOfMA[maInterval] {
//                    var y = ma * heightRatio
//
//                    switch isFirst {
//                        case true:
//                            path.move(to: CGPoint(x: width, y: y))
//                            isFirst = false
//                        case false:
//                            path.addLine(to: CGPoint(x: width, y: y))
//                    }
//                }
//
//                width += entryWidth
//
//                path.stroke (
//                    color,
//                    lineWidth: 1
//                )
//            }
//        }
//    }
//}
//
//
//                            //绘制均线
//                            maIntervals.forEach( maInterval in
//                                MALine(
//                                    color: CommonUtil.randomColor(),
//                                    maIntervals: maIntervals,
//                                    lineDataEntryList: dataset.dataset,
//                                    heightRatio: heightRatio,
//                                    entryWidth: lineItemWidth
//                                )
//
//                            )
//

//
//
//
//
//    /**
//        计算均线
//    */
//    func calculateMA(maIntervals:[Int] = [1]) -> Void{
//        var intervalWindow: [Int:(interval:Int, windowLength:Int, windowTotal:Double)] = [:]
//        for element in maIntervals {
//            intervalWindow[element] = (element, 0, 0)
//        }
//      
//
//        var currentIdx = data.count - 1
//        for entry in datasett {
//            for (_, value) in intervalWindow {
//                var (interval, windowLength, windowTotal) = value
//
//                if windowLength < interval {
//                    windowLength += 1
//                    windowTotal += candlestick.close
//                } else {
//                    windowTotal = windowTotal - data[(currentIdx + windowLength - 1)].close + entry.close
//
//                    let ma = windowTotal / Double(windowLength)
//                    entry.dictOfMA[interval] = ma
//                }
//                
//                currentIdx -= 1
//            }
//        }
//    }
