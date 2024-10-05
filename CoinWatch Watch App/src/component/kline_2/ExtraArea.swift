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
    
    @Binding var scrollViewOffset: Double?

    
    @ViewBuilder
    var content: some View {
        GeometryReader { geo in
            ZStack {
                buildShape(isUp: true)?.fill(.green)
                    .clipShape(Path { path in
                        path.addRect(CGRect(
                            x: 0,
                            y: 0,
                            width: geo.size.width,
                            height:  geo.size.height
                        ))
                    })
                
                buildShape(isUp: false)?.fill(.red)
                    .clipShape(Path { path in
                        path.addRect(CGRect(
                            x: 0,
                            y: 0,
                            width: geo.size.width,
                            height:  geo.size.height
                        ))
                    })
            }
        }
    }
    
    func buildShape(isUp: Bool) -> Path? {
        if let retio = calHeightRetio() {
            return Path { path in
                var x:Double = Double(windowStartIndex ?? 0) * lineItemWidth - (scrollViewOffset ?? 0)
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
        let end = min(windowEndIndex!, lineDataList.count - 1)
        
        
        var maxVol: Double = 0
        for idx in (windowStartIndex!...end) {
            maxVol = max(maxVol, lineDataList[idx].volume)
        }
        
        return height / maxVol
    }
}

