//
//  CoinDetailWindow.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

struct CoinDetailWindow: View {
    @EnvironmentObject var coinInfo: CoinInfo
    @State var selectAsks: Double? = nil
    @State var selectDids: Double? = nil
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack {
                VStack{
                    CoinImageAndName(
                        baseAssert: coinInfo.base,
                        quoteAssert: coinInfo.quote
                    )
                    .frame(width: geometry.size.width*0.3, height: geometry.size.width*0.3)
                    .background(.red)
                    
                    
                    DeepInfoCard(rawSelectX: $selectAsks, deepDirection: .ASKS, deepArray: coinInfo.deepInfo.asks)
                    
                    DeepInfoCard(rawSelectX: $selectDids, deepDirection: .DIDS, deepArray: coinInfo.deepInfo.bids)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width*0.3,height:geometry.size.height)
                .background(Color.blue)
                
                VStack {
                    
                }
                .frame(width: geometry.size.width*0.7,height:geometry.size.height)
                .background(Color.green)
            }
            .font(.defaultFont())
        }
       
    }
}


struct CoinImageAndName: View {
    var baseAssert: String
    var quoteAssert: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CoinImage(imageUrl: CommonUtil.getCoinLogoImageUrl(base: baseAssert))
                    .blur(radius: 2)
                    .overlay {
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
        }
  
    }
}

#Preview {
    CoinDetailWindow().environmentObject(CoinInfo())
}
