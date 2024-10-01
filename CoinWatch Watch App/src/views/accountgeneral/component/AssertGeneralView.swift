//
//  AssertGeneral.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import SwiftUI



struct AssertGeneralView:View {
    @EnvironmentObject var modelData: AccountGeneralModelData
    
    @State private var selection = 0
    
    var body: some View {
        // 定义一个 Button，点击时触发 Alert
        TabView(selection: $selection) {
            // 第一个标签页
            SpotAssertGeneralView()
                .environmentObject(modelData)
                .tabItem {
                    Label("现货", systemImage: "house.fill")
                }
                .tag(0) // 与selection绑定，表示这是第一个标签页
                
            
            // 第二个标签页
            ContractAssertGeneralView()
                .environmentObject(modelData)
                .tabItem {
                    Label("合约", systemImage: "gearshape.fill")
                }
                .tag(1) // 与selection绑定，表示这是第二个标签页
        }
        .accentColor(.blue) // 设置标签栏的强调色
        
    }
}

struct SpotAssertGeneralView:View {
    @EnvironmentObject var modelData: AccountGeneralModelData

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("现货资产")
                    
                    Spacer()
                    
                    Text(String(modelData.spotTotalCount))
                        .font(.numberFont_0())
                        .foregroundStyle(Color.pink)
                    
                    Text("种")
                }
                .padding(10)
                .frame(width:  geometry.size.width, height: geometry.size.height*0.2)
                .offset(x: 0, y: -10)
                
                
                HStack {
                    DollarIcon()
                    
                    Text(String(modelData.spotTotalValue.coinPriceFormat()))
                        .font(.numberFont_0())
                        .foregroundStyle(.green)
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
                    Text("合约仓位")
                    
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


#Preview(body: {
    AssertGeneralView().environmentObject(AccountGeneralModelData.sharedInstance)
})
