//
//  KLineTypeIcon.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/1.
//
import Foundation
import SwiftUI


/**
    K线类型的小图标，根据chartPrintState属性动态更改
 */
struct KLineTypeIcon: View {
    @State private var isPressed:Bool = false
    
    @Binding var chartPrintState: ChartPrintState
    
    var clickCallBack: (ChartPrintState) -> Void
    
    var body: some View {
        Button {
            clickCallBack(chartPrintState)
            withAnimation {
                isPressed.toggle()
            }
        } label: {
            Image(getIconPath())
                .renderingMode(.original)
                .resizable()
                .foregroundStyle(Color("SystemFontColor"))
                .background(Color("MetricIconBGColor"))
                .frame(width: 20, height: 20)
                .scaledToFit()
        }
        .background(Color("MetricIconBGColor"))
        .frame(width: 20, height: 20)
        .clipShape(
            RoundedRectangle(cornerRadius: 0)
        )
        // 设置动画参数
        .animation(.spring, value: isPressed)
    }

    func getIconPath() -> String{
        switch chartPrintState{
        case .K_LINE:
            return "kline"
        case .MA_LINE:
            return "maline"
        case .K_MA_LINE:
            return "kmaline"
        case .K_BOLL_LINE:
            return "boll"
        }
    }
}

#Preview {
    @Previewable @State var state:ChartPrintState = .K_LINE
    KLineTypeIcon(chartPrintState: $state) { curent
        in
        state = state.next()
    }
}
