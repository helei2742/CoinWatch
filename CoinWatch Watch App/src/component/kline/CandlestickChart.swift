//
//  CandlestickChart.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/24.
//

import SwiftUI


struct Candlestick: Identifiable {
    let id = UUID()
    var openTime: Date = Date()
    var volume: Double = 0.0

    let open: Double
    let close: Double
    let high: Double
    let low: Double
}


struct CandlestickChartView: View {
    let data: [Candlestick]
    let maxY: Double
    let minY: Double

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width / CGFloat(data.count)
            

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(data) { candlestick in
                    VStack {
                        Spacer()

                        //绘制上下影线
                        LineView(
                            high: candlestick.high,
                            low: candlestick.low,
                            maxY: maxY,
                            minY: minY
                        )

                        //绘制实体部分 (矩形)
                        Rectangle()
                        .fill(candlestick.close > candlestick.open ? Color.green : Color.red)
                        .frame(width: width * 0.8, height: CGFloat(abs(candlestick.open - candlestick.close)/(maxY-minY)*geometry.size.height))
                    }
                    .frame(width:width, height: geometry.size.height)
                }
            }
        }
    }
}


struct LineView: Shape {
    let high: Double
    let low: Double
    let maxY: Double
    let minY: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let yHigh = CGFloat(maxY - high)/(maxY - minY) * rect.height
        let yLow = CGFloat(maxY - low)/(maxY - minY) * rect.height
    
        path.move(to: CGPoint(x: rect.midX, y:yHigh))
        path.addLine(to: CGPoint(x: rect.midX, y: yLow))
        return path
    }
}
