//
//  AssertGeneral.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import SwiftUI



struct SpotAssertGeneralView:View {
    @EnvironmentObject var modelData: AccountGeneralModelData

    var body: some View {
        GeometryReader { geometry in
            VStack {
//                HStack {
//                    
//                    Spacer()
//
//                }
//                .padding(10)
//                .frame(width:  geometry.size.width, height: geometry.size.height*0.2)
//                .offset(x: 0, y: -10)
               
                HStack {
                    Spacer()
                    DollarIcon()
                    
                    Text(String(modelData.spotTotalValue.coinPriceFormat()))
                        .font(.numberFont_0())
                        .foregroundStyle(.green)
                    Spacer()
                }
               
            }
            
        }
    }
}

struct ContractAssertGeneralView:View {
    @EnvironmentObject var modelData: AccountGeneralModelData

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    
                    Text(String(modelData.contractTotalCount))
                        .font(.numberFont_0())
                        .foregroundStyle(Color.pink)
                    
                    Text("个")
                }
                .padding(10)
                .frame(width:  geometry.size.width, height: geometry.size.height*0.2)
                .offset(x: 0, y: -10)
                
                
                HStack {
                    Image(systemName: "dollarsign")
                        .resizable()
                        .font(.largeTitle)
                        .scaledToFit()
                        .foregroundStyle(Color(#colorLiteral(red: 0.7304586768, green: 0.4367996454, blue: 0, alpha: 1)))
                    
                    Text(String(modelData.contractTotalValue))
                        .font(.numberFont_0())
                        .foregroundStyle(.green)
                }
            }

        }
    }
}
