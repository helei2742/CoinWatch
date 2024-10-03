//
//  BollLine.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/29.
//



import Foundation
import SwiftUI


/**
 绘制Boll线
 */
struct BollLine {
    
    
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
    
    func aLine(getPrice: (LineDataEntry) -> Double) -> Path {
        var lastPoint:CGPoint? = nil
        return Path() { path in
            var x = entryWidth / 2
            lineDataEntryList.forEach{ entry in
                if entry.isPredictData {
                    return
                }
                
                lastPoint = addLine(path: &path, lastPoint: lastPoint, x: x, price: getPrice(entry))
                x += entryWidth
            }
        }
    }
    
    
    @ViewBuilder
    var content: some View {
        if lineDataEntryList.isEmpty {
            EmptyView()
        }
        
        ZStack{
            aLine(getPrice: { entry in
                entry.bollLine.upper
            })
            .stroke(
                .orange,
                lineWidth: 1
            )
            
            aLine(getPrice: { entry in
                entry.bollLine.ma
            })
            .stroke(
                .pink,
                lineWidth: 1
            )
            
            aLine(getPrice: { entry in
                entry.bollLine.lower
            })
            .stroke(
                .purple,
                lineWidth: 1
            )
        }

    }
    
    
    func addLine(path: inout Path, lastPoint:CGPoint?, x: Double, price: Double) -> CGPoint {
        let y = price * heightRatio - heightOffset
        let currentPoint:CGPoint = CGPoint(x: x, y: y)
        
        if let lastPoint = lastPoint {
            path.move(to: lastPoint)
        } else {
            path.move(to: currentPoint)
        }
        
        path.addLine(to: currentPoint)
        return currentPoint
    }
}
