//
//  AxisLine.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/27.
//

import SwiftUI
/**
    X轴线
*/
struct XAxisLine: Shape {
    func path(in rect: CGRect) -> Path {
        let height = rect.height
        let width = rect.width
        var path = Path()
        //画轴线
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))

        //画刻度
//        let interval:CGFloat = height / Double(scaleNumber)
        
        return path
    }
}


/**
 Y轴线
 */
struct YAxisLine: Shape {
    
    /**
     轴线高度
     */
    let height: CGFloat
    
    /**
     最大值
     */
    let max: CGFloat
    
    /**
     最小值
     */
    let min: CGFloat
    
    /**
     刻度数
     */
    let scaleNumber:Int
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width:CGFloat = rect.width
            
            let heightPrice:Double = (max - min) / height
            
            //画轴线
            path.move(to: CGPoint(x: width / 2, y: height))
            path.addLine(to: CGPoint(x: width / 2, y: 0))
            
            //画刻度
            let interval:CGFloat = height / Double(scaleNumber)
            
            let numbers: [Int] = Array(0...scaleNumber)
            numbers.forEach { i in
                let height:CGFloat = Double(i) * interval
                
                let printPrice = height * heightPrice
                
                //刻度线
                path.move(to: CGPoint(x: 0, y:height))
                path.addLine(to: CGPoint(x: width, y:height))
                
                
                Text(String(printPrice))
                    .font(.footnote)
                    .position(x: 0, y: height)
            }
        
        }
        
    }
}
