//
//  SimpleAreaChart.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI
import Charts

struct SimpleAreaChart: View {
    @EnvironmentObject var modelData: AccountGeneralModelData
    
    @Binding var rawSelectDate: Date?
    
    var selectedData: AccountSpotDayInfo? {
        get {
            if let rawSelectDate {
                for dayInfo in  modelData.spotTotalValueDayHistory {
                    if DateUtil.areDatesOnSameDay(rawSelectDate, dayInfo.date) {
                        return dayInfo
                    }
                }
            }
            
            return nil
        }
    }
    
    var body: some View {
        ZStack{
            HStack{
                
                VStack{
                    
                    Text("资产变化")
                        .padding(10)
                        .font(.defaultFont())
                        .foregroundStyle(Color("SystemFontColor"))
                    Spacer()
                }
                
                Spacer()
            }
            
            
            Chart(modelData.spotTotalValueDayHistory, id: \.date) { element in
                LineMark (
                    x: .value("日期", element.date, unit: .day),
                    y: .value("美元", element.spotTotalValue.coinPriceFormat())
                )
                .foregroundStyle(Color.orange)
//                .symbolSize(8)
                
                AreaMark (
                    x: .value("日期", element.date, unit: .day),
                    y: .value("美元", element.spotTotalValue)
                )
                .foregroundStyle(Color.orange.opacity(0.6))
                
                if let rawSelectDate {
                    RuleMark (
                        x: .value("selected", rawSelectDate, unit: .day)
                    )
                    .foregroundStyle(Color.blue.opacity(0.1))
                    .zIndex(-1)
                    .annotation(
                        position: .top, spacing: 0,
                        overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .disabled
                        )
                    ) {
                        valueSelectionPopover
                    }
                }
                
            }
            
            .chartYAxis(.hidden)
            .chartXSelection(value: $rawSelectDate)
        }
    }
    
    
    @ViewBuilder
    var valueSelectionPopover: some View {
        if let selectedData {
            VStack(alignment: .leading) {
                Text("Average on ")
                    .foregroundStyle(.secondary)
                    .fixedSize()
                
                Text(
                    DateUtil.toYearMonthDayStr(date: selectedData.date)
                )
                .foregroundStyle(.white)
                .fixedSize()
                HStack(spacing: 20) {
                    Text("资产价值:")
                    
                    HStack (spacing: 5){
                        Text(String(selectedData.spotTotalValue))
                        
                        DollarIcon()
                            .frame(height: 12)
                            .foregroundStyle(.green)
                    } .frame(height: 18)
                }
            }
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.gray.opacity(1))
            }
        } else {
            Text("error")
            EmptyView()
        }
    }
    
}


