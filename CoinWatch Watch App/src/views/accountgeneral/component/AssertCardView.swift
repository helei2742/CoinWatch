//
//  AssertCardView.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import SwiftUI
import Kingfisher


struct AssertCardView: View {
    
    @EnvironmentObject var modelData:AccountGeneralModelData
    
   
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                HStack(spacing: 3){
                    let length = geometry.size.height
                    
                    ForEach(modelData.accountSpot) { accountSpotItem in
                        
                        SpotLittleCard(
                            accounSpotItem: accountSpotItem,
                            quote: modelData.spotUnit.rawValue
                        )
                        .onTapGesture {
                            //跳转到币种详情界面
                            ViewRouter.routeTo(newView: .CoinDetail, payload: [
                                SystemConstant.COIN_BASE_KEY: accountSpotItem.baseAsset,
                                SystemConstant.COIN_QUOTE_KEY: modelData.spotUnit.rawValue
                            ])
                        }
                        .padding(2)
                        .frame(height:length)
                        .background(Color("NormalBGColor").opacity(0.5))
                        .border(
                            LinearGradient(colors:
                                            [Color.black, Color.gray, Color.white,Color.gray, Color.black,
                                             Color.black, Color.gray, Color.white,Color.gray, Color.black],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                }
                .foregroundStyle(Color("AssertCardFontColor"))
            }
        }
    }
}


struct SpotLittleCard: View {
    var accounSpotItem:AccountSpotItem
    
    @State var spotInfo:SpotInfo = SpotInfo.sharedInstance
    
    var quote: String
    
    var body: some View {
        ZStack {
            CoinImage(imageUrl: CommonUtil.getCoinLogoImageUrl(base: accounSpotItem.baseAsset))
                .blur(radius: 2)
            
            
            Text(accounSpotItem.baseAsset)
                .font(.title.bold())
                .foregroundStyle(
                    LinearGradient(colors: CommonUtil.buildRandomColorArray(count: 4),
                                   startPoint: .leading, endPoint: .bottom)
                )
            
            VStack(spacing: 0) {
                let newPrice = spotInfo.findSpotInfo(base: accounSpotItem.baseAsset, quote: quote)?.newPrise ?? 0.0
                let lastPrice = spotInfo.findSpotInfo(base: accounSpotItem.baseAsset, quote: quote)?.lastNewPrise ?? 0.0
                
                AssertCardNumberRaw(
                    number: newPrice * accounSpotItem.count,
                    lastNumber: lastPrice * accounSpotItem.lastCount,
                    title: "价 值",
                    quote: quote
                )
                
                AssertCardNumberRaw(
                    number: newPrice,
                    lastNumber: lastPrice,
                    title: "最新价",
                    quote: quote
                )
                
                
                Spacer()
            }
            .background(Color("NormalBGColor").opacity(0.3))
            
        }
    }
}
