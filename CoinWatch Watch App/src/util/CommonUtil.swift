//
//  spotInfo.swift
//  CoinIWatch
//
//  Created by 何磊 on 2024/9/21.
//

import Foundation
import SwiftUI


extension String {
    func substring(to index: Int) -> String? {
        guard index >= 0 && index <= self.count else {
            return nil // 确保索引在有效范围内
        }
        
        let endIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[self.startIndex..<endIndex])
    }
}

class CommonUtil {
    
    static func generalCoinPrintSymbol(base: String, quote: String) -> String{
//        return base + "/" + quote
        return base
    }
    
    
    static func getCoinLogoImageUrl(base: String) -> String {
        //return URL(string: SystemConfig.COIN_LOGO_BASE_URL + "/" + base + ".png")!
        return SystemConfig.COIN_LOGO_BASE_URL + "/" + base + ".png"
    }
    
    static func buildRandomColorArray(count: Int) -> [Color] {
        var colors: [Color] = []
           for _ in 0..<count {
               colors.append(CommonUtil.randomLightColor())
           }
           return colors
    }
    
    static func getDayFromStr(str:String) -> String {
        let arr = str.split(separator: ".")
        return String(arr[arr.count - 1])
    }
    
    static func randomColor() -> Color {
        // 生成0到255之间的随机RGB值
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
          
        // 使用UIColor的初始化方法（因为SwiftUI的Color没有直接接受RGB值的初始化方法）
        // 然后桥接到SwiftUI的Color
        let uiColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return Color(uiColor)
    }
    
    static func randomLightColor() -> Color {
        // 尝试生成鲜艳的RGB颜色
         // 这里我们简单地确保RGB值中的至少一个与另外两个的差异较大
         var r: CGFloat = CGFloat.random(in: 0.2...0.8)
         var g: CGFloat = CGFloat.random(in: 0.2...0.8)
         var b: CGFloat = CGFloat.random(in: 0.2...0.8)
           
         // 调整RGB值以确保至少有一个颜色分量与另外两个有较大差异
         // 这里是一个简单的策略，可以根据需要调整
         let maxColor = max(r, max(g, b))
         let minColor = min(r, min(g, b))
           
         if maxColor - minColor < 0.3 {
             // 如果最大和最小颜色分量之间的差异太小，则调整它们
             // 这里只是简单地选择一个颜色分量并增加其值
             if r == minColor {
                 r += 0.2
             } else if g == minColor {
                 g += 0.2
             } else if b == minColor {
                 b += 0.2
             }
               
             // 确保颜色值不会超出范围
             r = min(r, 1.0)
             g = min(g, 1.0)
             b = min(b, 1.0)
         }
           
         // 使用UIColor的初始化方法，并桥接到SwiftUI的Color
         let uiColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
         return Color(uiColor)
    }
}
