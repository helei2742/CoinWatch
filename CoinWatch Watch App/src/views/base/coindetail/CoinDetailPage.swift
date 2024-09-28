//
//  CoinDetailPage.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

struct CoinDetailPage: View {
    var coinInfo: CoinInfo = CoinInfo()
    
    init() {
        self.defaultInit()
    }
    
    var body: some View {
        ZStack {
            CoinDetailWindow()
                .environmentObject(coinInfo)
            
//            BackButton(width: 20)
//                .position(x: 20, y: -20)
        }
        .frame(width: .infinity, height: .infinity)
        .onAppear {
            if let payload = ViewRouter.getPayLoad(viewName: .CoinDetail){
                print(payload)
                coinInfo.base = payload[SystemConstant.COIN_BASE_KEY] as! String
                coinInfo.quote = payload[SystemConstant.COIN_QUOTE_KEY] as! String
            } else {
                defaultInit()
            }
        }
    }
    
    func defaultInit() {
        coinInfo.base = SystemConstant.DEFAULT_BASE
        coinInfo.quote  = SystemConstant.DEFAULT_QUOTE
    }
}

#Preview {
    CoinDetailPage()
}
