//
//  CandlesstickShape.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/27.
//
import SwiftUI

/**
 一根蜡烛的形状
 */
struct CandlesstickShape: Shape  {
    
    /**
     一根k线图的数据
     */
    let lineDataEntry: LineDataEntry
    
    /**
     高的比例，所有与高有关的数据都要乘
     */
    let heightRatio: Double
    
    let heightOffset: Double
    
    func path(in rect: CGRect) -> Path {
        let itemWidth = rect.width
        return Path { path in
            
            //绘制上下影线s
            path.move(to: CGPoint(x: itemWidth / 2, y: lineDataEntry.high * heightRatio - heightOffset))
            path.addLine(to: CGPoint(x: itemWidth / 2, y: lineDataEntry.low * heightRatio - heightOffset))
            
            //绘制实体部分 (矩形)
            if lineDataEntry.open < lineDataEntry.close { //涨
                let rect = CGRect (
                    x: (itemWidth / 2) - (itemWidth / 4),
                    y: lineDataEntry.open * heightRatio - heightOffset,
                    width: itemWidth / 2,
                    height:  CGFloat(abs(lineDataEntry.open - lineDataEntry.close) * heightRatio)
                )
                path.addRect(rect)
            } else {
                let rect = CGRect (
                    x: (itemWidth / 2) - (itemWidth / 4),
                    y: lineDataEntry.close * heightRatio - heightOffset,
                    width: itemWidth / 2,
                    height:  CGFloat(abs(lineDataEntry.open - lineDataEntry.close) * heightRatio)
                )
                path.addRect(rect)
            }
            
            
        }
    }
}
