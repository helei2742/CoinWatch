//
//  CandlestickChart.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//

import SwiftUI
import Charts

/**
 蜡烛图
 
 使用方式：
 Chart() { element in
 // 这里调用 generalChart() 方法
 CandlestickChart().generalChart()
 }
 */
struct CandlestickChart {
    
    /**
     高的比例，所有与高有关的数据都要乘
     */
    let heightRatio:Double
    
    /**
     一根蜡烛的宽度
     */
    let itemWidth: Double
    
    
    func generalChart (candlestick: Candlestick) -> any ChartContent {
        let res = PointMark (
            x: .value("日期", candlestick.openTime, unit: .day),
            y: .value("美元", candlestick.close)
        )
        let t = res.symbol(symbol: {
            CandlesstickItem(
                candlestick: candlestick,
                heightRatio: heightRatio,
                itemWidth: itemWidth
            )
            }
        )
        print(t)
        return t
    }
}

/**
 一根蜡烛的形状
 */
struct CandlesstickItem: Shape  {
    
    /**
     一根k线图的数据
     */
    var candlestick: Candlestick
    
    /**
     高的比例，所有与高有关的数据都要乘
     */
    let heightRatio: Double
    
    /**
     一根蜡烛的宽度
     */
    let itemWidth: Double
    
    
    func path(in rect: CGRect) -> Path {
        
        Path { path in
            //绘制上下影线s
            let width = rect.width
//            print(rect.height)
            print("width \(rect.width) height: \(rect.height)")
            
            path.move(to: CGPoint(x: width / 2, y: candlestick.high * heightRatio))
            path.addLine(to: CGPoint(x: width / 2, y: candlestick.low * heightRatio))
            
            //绘制实体部分 (矩形)
            let rect = CGRect (
                x: (itemWidth / 2) - (itemWidth / 4),
                y: candlestick.close * heightRatio,
                width: itemWidth / 2,
                height:  CGFloat(abs(candlestick.open - candlestick.close) * heightRatio)
            )
            path.addRect(rect)
            
            
        }
    }
}




enum KLineInterval: RawRepresentable {
    var rawValue: KLineIntervalItem {
        switch self {
        case .s_1:
            return KLineIntervalItem(1, .s)
        case .m_1:
            return KLineIntervalItem(1, .m)
        case .m_3:
            return KLineIntervalItem(3, .m)
        case .m_5:
            return KLineIntervalItem(5, .m)
        case .m_15:
            return KLineIntervalItem(15, .m)
        case .h_1:
            return KLineIntervalItem(1, .h)
        case .h_2:
            return KLineIntervalItem(2, .h)
        case .h_4:
            return KLineIntervalItem(4, .h)
        case .h_6:
            return KLineIntervalItem(6, .h)
        case .h_8:
            return KLineIntervalItem(8, .h)
        case .h_12:
            return KLineIntervalItem(12, .h)
        case .d_1:
            return KLineIntervalItem(1, .d)
        case .w_1:
            return KLineIntervalItem(1, .w)
        case .M_1:
            return KLineIntervalItem(1, .M)
        }
    }
    
    typealias RawValue = KLineIntervalItem
    case s_1
    case m_1
    case m_3
    case m_5
    case m_15
    case h_1
    case h_2
    case h_4
    case h_6
    case h_8
    case h_12
    case d_1
    case w_1
    case M_1
    
    
    init?(rawValue: KLineIntervalItem) {
        self = .d_1
        if rawValue.interval == 1, rawValue.timeUnit == .s {
            self = .s_1
        }
        if rawValue.interval == 1, rawValue.timeUnit == .m {
            self = .m_1
        }
        if rawValue.interval == 3, rawValue.timeUnit == .m {
            self = .m_3
        }
        if rawValue.interval == 5, rawValue.timeUnit == .m {
            self = .m_5
        }
        if rawValue.interval == 15, rawValue.timeUnit == .m {
            self = .m_15
        }
        if rawValue.interval == 1, rawValue.timeUnit == .h {
            self = .h_1
        }
        if rawValue.interval == 2, rawValue.timeUnit == .h {
            self = .h_2
        }
        if rawValue.interval == 4, rawValue.timeUnit == .h {
            self = .h_4
        }
        if rawValue.interval == 6, rawValue.timeUnit == .h {
            self = .h_6
        }
        if rawValue.interval == 8, rawValue.timeUnit == .h {
            self = .h_8
        }
        if rawValue.interval == 12, rawValue.timeUnit == .h {
            self = .h_12
        }
        if rawValue.interval == 1, rawValue.timeUnit == .d {
            self = .d_1
        }
        if rawValue.interval == 1, rawValue.timeUnit == .w {
            self = .w_1
        }
        if rawValue.interval == 1, rawValue.timeUnit == .M {
            self = .M_1
        }
        
    }
    
    
}

enum TimeUnit: String {
    case s
    case m
    case h
    case d
    case w
    case M
}
struct KLineIntervalItem {
    let interval:Int
    let timeUnit:TimeUnit
    
    init(_ interval:Int, _ timeUnit:TimeUnit) {
        self.interval = interval
        self.timeUnit = timeUnit
    }
    
    func toString() -> String {
        return String(interval) + String(timeUnit.rawValue)
    }
}

enum ApiResponseType: String {
    case FULL
    case MINI
}
