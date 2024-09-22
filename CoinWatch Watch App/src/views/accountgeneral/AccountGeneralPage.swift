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
    
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 5){
                
                AssertGeneralView()
                    .environmentObject(modelData)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.3)

                
                AssertCardView()
                    .environmentObject(modelData)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.35)
                
                
                AssertChangeView()
                    .environmentObject(modelData)
                    .frame( width: geometry.size.width, height: geometry.size.height * 0.35)
            }
            .font(.defaultFont())
        }
       
    }
}


#Preview {
    AccountGeneralPage()
}
