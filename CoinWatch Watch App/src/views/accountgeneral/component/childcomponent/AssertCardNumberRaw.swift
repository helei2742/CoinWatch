//
//  AssertCardNumberRaw.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI

struct AssertCardNumberRaw: View {
    var number: Double
    var lastNumber: Double
    
    var title: String = "title"
    var quote: String = "USDT"
    
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                
                Text(String(number.coinPriceFormat()))
                
                ArrowIcon(judge: number - lastNumber)
            }
            
            Spacer()
            
            VStack {
                Spacer()
                
                VStack{
                    Text(title)
                    Text(quote)
                }
                .font(.littleFont())
            }
        }
        .padding(2)
        .foregroundStyle(Color.white)
    }
}
