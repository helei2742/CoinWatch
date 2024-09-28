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
       窗口高度
     */
    let windowHeight: CGFloat
    
    /**
       窗口宽度
     */
    let windowWidth: CGFloat
    
    /**
     组件item的高度比例，因为y轴是价格，所以表示单位价格的长度 height / (maxPrice - minPrice)
     */
    let heightRatio: Double
    
    /**
     高度偏移量
     */
    let heightOffset: Double
    
    /**
     刻度数
     */
    let scaleNumber:Int
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width:CGFloat = rect.width
                        
            //画轴线
            path.move(to: CGPoint(x: width - 2, y: windowHeight))
            path.addLine(to: CGPoint(x: width - 2, y: 0))
            
            //画刻度
            let interval:CGFloat = windowHeight / Double(scaleNumber)
            
            let numbers: [Int] = Array(0...scaleNumber)
            numbers.forEach { i in
                let height:CGFloat = Double(i) * interval
                
                let printPrice = (windowHeight - height + heightOffset)/heightRatio
                
                //刻度线
                path.move(to: CGPoint(x: width - 10, y:height))
                path.addLine(to: CGPoint(x: width, y:height))
            }
        
        }
        
    }
}
