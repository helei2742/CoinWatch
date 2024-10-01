//
//  ChartConstants.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/27.
//
import SwiftUI

/**
    图表显示的类型
        K_LINE  只显示k线
        MA_LINE 只显示MA
        K_MA_LINE 显示K线和MA线
*/
enum ChartPrintState: CaseIterable {
    case K_LINE
    case MA_LINE
    case K_MA_LINE
    case K_BOLL_LINE

    func next() -> ChartPrintState {
        let allCases = ChartPrintState.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        let nextIndex = allCases.index(after: currentIndex)
        return nextIndex < allCases.endIndex ? allCases[nextIndex] : allCases.first!
    }
}



class MAType{
    static let ma_1 = MATypeItem(interval: 1, color: .red)
    static let ma_5 = MATypeItem(interval: 5, color: Color.orange)
    static let ma_15 = MATypeItem(interval: 15, color: Color.yellow)
    static let ma_20 = MATypeItem(interval: 20, color: Color.green)
    static let ma_60 = MATypeItem(interval: 60, color: Color.gray)
    static let ma_120 = MATypeItem(interval: 120, color: Color.purple)
}

struct MATypeItem: Hashable {
    var interval:Int
    var color:Color
}

enum KLineInterval: RawRepresentable, CaseIterable  {
    
    var rawValue: KLineIntervalItem {
        switch self {
//        case .s_1:
//            return KLineIntervalItem(1, .s)
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
//    case s_1
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
//        if rawValue.interval == 1, rawValue.timeUnit == .s {
//            self = .s_1
//        }
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
