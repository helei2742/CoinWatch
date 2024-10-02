//
//  ExtraArea.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/2.
//

import SwiftUI

struct ExtraArea: View {
    @State var position:ScrollPosition = ScrollPosition(edge: .leading)

    @State var height: Double = 0
    
    @Binding var lineItemWidth: Double
    
    @Binding var scrollAreaWidth: Double

    @Binding var scrollAreaOffset: Double?

    @Binding var lineDataList: [LineDataEntry]
    
    @Binding var windowStartIndex: Int?
    
    @Binding var windowEndIndex: Int?
    
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                volumeChart
            }
            .scrollPosition($position)
            .onAppear{
                self.height = geo.size.height
            }
            .onChange(of:scrollAreaWidth) { oldValue, newValue in
                //滑动区域发生变化，说明k图数据变化
            }
            .onChange(of: scrollAreaOffset) { oldValue, newValue in
                //offset变化，同步
                position.scrollTo(x: scrollAreaOffset ?? 0)
            }
        }
    }
    
    @ViewBuilder
    var volumeChart: some View {
        if let retio = calHeightRetio() {
            var x:Double = 0.0
            ForEach(lineDataList) { lineData in
                Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    let rect = CGRect (
                        x: x,
                        y: lineData.volume * retio ,
                        width: lineItemWidth,
                        height:  0
                    )
                    path.addRect(rect)
                    x += lineItemWidth
                }
                .fill(lineData.getColor())
            }
        }
    }
    
    func calHeightRetio() -> Double? {
        if windowStartIndex == nil || windowEndIndex == nil {
            return nil
        }
        
        var maxVol: Double = 0
        for idx in (windowStartIndex!...windowEndIndex!) {
            maxVol = max(maxVol, lineDataList[idx].volume)
        }
        
        return maxVol / height
    }
}

