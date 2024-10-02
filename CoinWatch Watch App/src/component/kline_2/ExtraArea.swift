//
//  ExtraArea.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/2.
//

import SwiftUI

struct ExtraArea {
    @State var position:ScrollPosition = ScrollPosition(edge: .leading)

    @Binding var height: Double
    
    @Binding var lineItemWidth: Double
    
    @Binding var windowWidth: Double

    @Binding var lineDataList: [LineDataEntry]
    
    @Binding var windowStartIndex: Int?
    
    @Binding var windowEndIndex: Int?
    
    

    
    @ViewBuilder
    var content: some View {
        ZStack {
            buildShape(isUp: true)?.fill(.green)
            buildShape(isUp: false)?.fill(.red)
        }
    }
    
    func buildShape(isUp: Bool) -> Path? {
        if let retio = calHeightRetio() {
            return Path { path in
                var x:Double = 0.0
                for idx in (windowStartIndex!...windowEndIndex!){
                    let lineData = lineDataList[idx]
                    if isUp && lineData.close < lineData.open {
                        x += lineItemWidth
                        continue
                    }
                    
                    if !isUp && lineData.close > lineData.open {
                        x += lineItemWidth
                        continue
                    }
                    
                    path.move(to: CGPoint(x: x, y: 0))
                    let rect = CGRect (
                        x: x,
                        y: 0,
                        width: lineItemWidth,
                        height:  lineData.volume * retio
                    )
                    print("\(rect)")
                    path.addRect(rect)
                    x += lineItemWidth
                }
            }
        }
        return nil
    }
    
    
    func calHeightRetio() -> Double? {
        if windowStartIndex == nil || windowEndIndex == nil {
            return nil
        }
        
        var maxVol: Double = 0
        for idx in (windowStartIndex!...windowEndIndex!) {
            maxVol = max(maxVol, lineDataList[idx].volume)
        }
        
        return height / maxVol
    }
}

