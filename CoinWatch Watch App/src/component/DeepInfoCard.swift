//
//  DeepInfoCard.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI
import Charts


struct DeepInfoCard: View {
    @Binding var rawSelectX: Double?
    
    @State private var showingPopover = false
    
    
    var selectedData: DeepInfoPoint? {
        get {
            if let rawSelectX {
                for item in deepArray {
                    if abs(item.price - rawSelectX) < 0.01 {
                        return item
                    }
                }
            }
            
            return nil
        }
    }
    
    var deepDirection:DeepDirection
    
    var deepArray:[DeepInfoPoint]
    
    var whenPressData: (DeepInfoPoint?) -> Bool
    
    var body: some View {
        GeometryReader { geo in
           
                Chart(deepArray, id: \.price){ element in
                    PointMark (
                        x: .value("price", element.price),
                        y: .value("vol", element.volume)
                    )
                    .foregroundStyle(chartColor())
                    .symbolSize(8)
                    
                    LineMark(
                        x: .value("price", element.price),
                        y: .value("vol", element.volume)
                    )
    

                    if let rawSelectX, whenPressData(selectedData) {
                        
                        RuleMark (
                            x: .value("selected", rawSelectX)
                        )
                        .foregroundStyle(Color.blue.opacity(0.1))


                    } 
                }
                .chartXScale(domain: [deepArray[0].price,
                                      deepArray[deepArray.count-1].price])
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .foregroundStyle(chartColor().opacity(0.5))
                .chartXSelection(value: $rawSelectX)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(chartColor().opacity(0.2))
        }
    }
    
    @ViewBuilder
    var valueSelectionPopover: some View {
        if rawSelectX != nil {
            VStack(alignment: .leading) {
                HStack {
                    Text("price")
                        .foregroundStyle(.secondary)
                        .fixedSize()
                    Text(String(selectedData?.price ?? 0))
                }
                
                HStack {
                    Text("volume")
                        .foregroundStyle(.secondary)
                        .fixedSize()
                    Text(selectedData?.volume ?? "null")
                }
            }
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.gray.opacity(1))
            }
//            .allowsHitTesting(false)
        } else {
            Text("error")
            EmptyView()
        }
    }
    
    func chartColor() -> Color {
        switch deepDirection {
        case .ASKS:
            return .green
        case .DIDS:
            return .red
        }
    }
}

#Preview {
    @Previewable @State var x: Double?  = nil
    DeepInfoCard(
        rawSelectX: $x,
        deepDirection: .ASKS,
        deepArray: CoinInfo().deepInfo.asks,
        whenPressData:{ selectedData in
            print(selectedData)
            return true
        }
    )
}
