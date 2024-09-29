//
//  CoinDetailWindow.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

struct CoinDetailWindow: View {
    @EnvironmentObject var coinInfo: CoinInfo
    @EnvironmentObject var natificationBar: NatificationBar
    
    @State var selectAsks: Double? = nil
    @State var selectDids: Double? = nil
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack(spacing:0) {
                VStack{
                    ZStack {
                        //图标和名称
                        CoinImageAndName(
                            baseAssert: coinInfo.base,
                            quoteAssert: coinInfo.quote
                        )
                        
                    }
                    .background(.red)
                    
                    //深度图
                    DeepInfoCard(
                        rawSelectX: $selectAsks,
                        deepDirection: .ASKS,
                        deepArray: coinInfo.deepInfo.asks
                    )
                    
                    DeepInfoCard(
                        rawSelectX: $selectDids,
                        deepDirection: .DIDS,
                        deepArray: coinInfo.deepInfo.bids
                    )
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: geometry.size.width*0.3,height:geometry.size.height)
                .background(Color.blue)
                
                VStack { //K 线图
                    KLineChart(
                        symbol: CommonUtil.generalCoinSymbol(base: coinInfo.base,quote: coinInfo.quote),
                        kLineInterval: .d_1,
                        maIntervals: [MAType.ma_15, MAType.ma_20])
                        .frame(height: geometry.size.height * 0.7)
                    VStack{
                        Text("显示用户仓位和挂单")
                    }
                    .frame(height: geometry.size.height * 0.3)
                    
                }
                .frame(width: geometry.size.width*0.7,height:geometry.size.height)
                .background(Color.green)
            }
            .font(.defaultFont())
        }
       
    }
}


struct CoinImageAndName: View {
    @State private var showImage: Bool = true
    
    var baseAssert: String
    var quoteAssert: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showImage {
                    CoinImage(imageUrl: CommonUtil.getCoinLogoImageUrl(base: baseAssert))
                } else {
                    VStack {
                        Text("\(baseAssert)")
                            .lineLimit(1)
                        Text("\(quoteAssert)")
                            .font(.littleFont())
                    }
                    .frame(width:geometry.size.width, height: geometry.size.width)
                    .background(Color.gray.opacity(0.4))
                    .clipShape(Circle())
                }
            }
            .offset(y: 10)
            .onTapGesture{
                showImage = !showImage
            }
        }
  
    }
}

#Preview {
    CoinDetailWindow().environmentObject(CoinInfo())
}
