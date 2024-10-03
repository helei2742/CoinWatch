//
//  AccountGeneralPage.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import SwiftUI

/**
 账户概况
 需要用户授权ApiKey才可使用
 */
struct AccountGeneralPage: View {
    var modelData: AccountGeneralModelData = AccountGeneralModelData.sharedInstance
    
    @Binding var loadState: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack (spacing: 5){
                    
                    AssertGeneralView()
                        .environmentObject(modelData)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.3)
                    
                    AssertCardView()
                        .environmentObject(modelData)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.35)

                    AssertChangeView()
                        .environmentObject(modelData)
                        .ignoresSafeArea()
                        .frame( width: geometry.size.width, height: geometry.size.height * 0.35)
                }
                
                .font(.defaultFont())
            }
        }
        .onChange(of: modelData.accountSpot) { oldValue, newValue in
            loadState += 1
        }
        .onChange(of: modelData.spotTotalValueDayHistory) { oldValue, newValue in
            loadState += 1
        }
        .onChange(of: modelData.spotTotalValue) { oldValue, newValue in
            loadState += 1
        }
    }
}
