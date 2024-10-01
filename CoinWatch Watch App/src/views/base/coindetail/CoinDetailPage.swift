//
//  CoinDetailPage.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

struct CoinDetailPage: View {
    
    @State var coinInfo: CoinInfo
    
    init(base: String, quote: String) {
        coinInfo = CoinInfo(base: base, quote: quote)
    }
    
    var body: some View {
        ZStack {
            CoinDetailWindow(coinInfo: $coinInfo)
            
//            BackButton(width: 20)
//                .ignoresSafeArea()
//                .position(x: 40, y: 0)
        }
        .frame(width: .infinity, height: .infinity)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 { // 滑动距离阈值
                        ViewRouter.backLastView()
                    }
                }
        )
    }
    
    func defaultInit() {
        coinInfo.base = SystemConstant.DEFAULT_BASE
        coinInfo.quote  = SystemConstant.DEFAULT_QUOTE
    }
}

#Preview {
    CoinDetailPage(base: "ETC", quote: "USDT")
}
