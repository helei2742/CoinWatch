//
//  MALine.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/29.
//


import Foundation
import SwiftUI


/**
 绘制均线图
 */
struct MALine {
    
    /**
     均线间隔
     */
    
    var maType: MATypeItem
    
    /**
     数据
     */
    @Binding var lineDataEntryList: [LineDataEntry]
    
    /**
     高的比例
     */
    @Binding var heightRatio: Double
    
    /**
     高度的偏移
     */
    @Binding var heightOffset: Double
    
    /**
     单个k线数据的宽度
     */
    @Binding var entryWidth: Double
    
    
    @ViewBuilder
    var content: some View  {
        let maInterval = maType.interval
        let color = maType.color
        Path { path in
            if lineDataEntryList.isEmpty {
                return
            }
            
            //绘制不同间隔的MA
            var width:Double = entryWidth / 2
            
            //ma的线
            var lastPoint:CGPoint? = nil
            lineDataEntryList.forEach { dataEntry in
                
                if let ma = dataEntry.dictOfMA[maInterval] {
                    let y = ma * heightRatio - heightOffset
                    if y .isNaN {
                        return
                    }
                    let currentPoint:CGPoint = CGPoint(x: width, y: y)
                    
                    if let lastPoint = lastPoint {
                        path.move(to: lastPoint)
                    } else {
                        path.move(to: CGPoint(x: width, y: y))
                    }
                    
                    path.addLine(to: currentPoint)

                    lastPoint = currentPoint
                }
                
                width += entryWidth
            }
            
        }
        .stroke(
            color,
            lineWidth: 1
        )
    }
}

