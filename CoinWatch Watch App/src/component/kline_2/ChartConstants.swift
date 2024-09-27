//
//  ChartConstants.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/27.
//
import SwiftUI

enum MAType: RawRepresentable{

        
    var rawValue: MATypeItem {
        switch self {
        case .ma_1:
            return MATypeItem(interval: 1, color: .red)
        case .ma_5:
            return MATypeItem(interval: 5, color: Color.orange)
        case .ma_15:
            return MATypeItem(interval: 15, color: Color.yellow)
        case .ma_20:
            return MATypeItem(interval: 20, color: Color.green)
        case .ma_60:
            return MATypeItem(interval: 60, color: Color.gray)
        case .ma_120:
            return MATypeItem(interval: 120, color: Color.purple)
        }
    }
    
    typealias RawValue = MATypeItem

    case ma_1
    case ma_5
    case ma_15
    case ma_20
    case ma_60
    case ma_120
    
    
    init?(rawValue: MATypeItem) {
        self = .ma_5
        if rawValue.interval == 1 {
            self = .ma_1
        }
        if rawValue.interval == 5 {
            self = .ma_5
        }
        if rawValue.interval == 15 {
            self = .ma_15
        }
        if rawValue.interval == 20 {
            self = .ma_20
        }
        if rawValue.interval == 60 {
            self = .ma_60
        }
        if rawValue.interval == 120 {
            self = .ma_120
        }
        
    }
}

struct MATypeItem {
    var interval:Int
    var color:Color
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
