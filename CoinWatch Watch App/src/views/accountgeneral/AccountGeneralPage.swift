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
    
    /**
     显示类型，0表示现货，1表示合约
     */
    @State var printType: SymbolType = .spot
    
    @Binding var loadState: Int
    
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                
                VStack (spacing: 5){
                    switch printType {
                    case .spot:
                        // 第一个标签页
                        SpotAssertGeneralView()
                            .environmentObject(modelData)
                    case .contract:
                        // 第二个标签页
                        ContractAssertGeneralView()
                            .environmentObject(modelData)
                    }
                    
                    AssertCardView()
                        .environmentObject(modelData)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.35)

                    AssertChangeView()
                        .environmentObject(modelData)
                        .ignoresSafeArea()
                        .frame( width: geometry.size.width, height: geometry.size.height * 0.35)
                }
                .toolbar{
                    ToolbarItem(placement: .topBarLeading){
                        toolbarLeft
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        toolbarRight
                    }
                }
                .font(.defaultFont())
            
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
    
    @ViewBuilder
    var toolbarLeft: some View {
        HStack{
            switch printType {
            case .spot:
                Text("现货资产")
                    .font(.defaultFont())
                Text(String(modelData.spotTotalCount))
                    .font(.numberFont_0())
                    .foregroundStyle(Color.pink)
                Text("种")
            case .contract:
                Text("合约仓位")
                    .font(.defaultFont())
                Text(String(modelData.contractTotalCount))
                    .font(.numberFont_0())
                    .foregroundStyle(Color.pink)
                Text("种")
            }
        }
    }
    
    @ViewBuilder
    var toolbarRight: some View {
        HStack{
            
            Button {
                printType = printType.next()
            }label: {
                Image("exchange")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color("SystemFontColor"))
                    .frame(width: 25, height: 25)
                    .background(.clear)
            }
            .buttonStyle(SelectButtonStyle())
        }
    }
}

#Preview {
    @Previewable @State var state = 0
    AccountGeneralPage(loadState: $state)
}
