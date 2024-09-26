//
//  DateUtil.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/21.
//

import Foundation
  

class DateUtil {
    
    static let inner: Inner = Inner(pattern: "yyyy-MM-dd HH:mm:ss")
    
    
    static func strToDate(str:String) -> Date {
        return inner.strToDate(str: str) ?? Date()
    }
    
    static func dateToStr(date: Date) -> String {
        return inner.dayFormatter.string(from: date)
    }
    
    static func calDate(from date: Date, days: Int) -> Date? {
        // 使用当前日历对象来进行日期计算
        let calendar = Calendar.current
        // 通过 subtracting 天数来获取目标日期
        return calendar.date(byAdding: .day, value: days, to: date)
    }
    
    static func dateToDay(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        return calendar.date(from: components)!
    }
    
    static func areDatesOnSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
          
        // 通过比较两个日期的年、月、日组件来确定它们是否是同一天
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
          
        // 检查这些组件是否相同
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }
    
    static func toYearMonthDayStr(date: Date) -> String {
        return inner.dayFormatter.string(from: date)
    }
    
    class Inner {
        let dateFormatter:DateFormatter
        
        let dayFormatter: DateFormatter
        
        init(pattern: String) {
            self.dateFormatter = DateFormatter()
            self.dateFormatter.dateFormat = pattern
            
            self.dayFormatter = DateFormatter()
            self.dayFormatter.dateFormat = "yyyy-MM-dd"
        }

        func strToDate(str: String) -> Date? {
            // 设置日期格式以匹配你的字符串
            
            return dateFormatter.date(from: str)
        }
    }

}
