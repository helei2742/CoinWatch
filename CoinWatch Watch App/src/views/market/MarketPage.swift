//
//  MarketPage.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/3.
//

import SwiftUI

struct MarketPage: View {
    @State var marketData = MarketData.sharedInstance
    
    /**
     数据加载状态
     */
    @State var loadState: Bool = false
    
    /**
     是否显示详细信息
     */
    @State var isShowDetail = false

    /**
     显示数据的类型
     */
    @State var marketPrintType:MarketPrintType = .hot100
   
    /**
     行情类型
     */
    @State var marketType: MarketType = .spot
    
    var body: some View {
        NavigationStack{
            
            VStack(spacing:0){
                scrollArea
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    toolbarLeft
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        marketPrintType = marketPrintType.next()
                    } label: {
                        Image(getIconPath())
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("SystemFontColor"))
                            .frame(width: 25, height: 25)
                            .background(.clear)
                    }
                    .background(Color("MetricIconBGColor"))
                    .buttonStyle(SelectButtonStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .onAppear{
                marketData.loadMarketData(whenComplate: { res in
                    loadState = res
                })
            }
        }
    }
    
    @ViewBuilder
    var toolbarLeft: some View {
        HStack{
            Button {
                marketType = .star
            } label: {
                Label("Graph", systemImage: "star")
                    .multilineTextAlignment(.center)
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .padding()
            }
            .buttonStyle(SelectButtonStyle())
            .frame(width: 25, height: 25)
            .overlay {
                if marketType == .star {
                    VStack{
                        Spacer()
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 2)
                            .offset(y:6)
                    }
                }
            }
            
            Button {
                marketType = .spot
            } label: {
                Text("现货")
            }
            .buttonStyle(SelectButtonStyle())
            .overlay {
                if marketType == .spot {
                    VStack{
                        Spacer()
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 2)
                            .offset(y:6)
                    }
                }
            }
            
            Button {
                //TODO 合约逻辑
                marketType = .contract
            } label: {
                Text("合约") .background(.clear)
            }
            .buttonStyle(SelectButtonStyle())
            .overlay {
                if marketType == .contract {
                    VStack{
                        Spacer()
                        RoundedRectangle(cornerRadius: 0)
                            .frame(height: 2)
                            .offset(y:6)
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    var scrollArea: some View {
        ScrollView {
            VStack {
                let data = marketData.selectMarketTypeData(marketPrintType: marketPrintType)
                ForEach(data) { item in
                    MarketCoinCard(marketDataItem: item, quote: .USDT)
                }
            }
        }
    }
    
    func getIconPath() -> String {
        switch marketPrintType {
        case .hot100:
            "hot"
        case .rise100:
            "rise"
        case .fall100:
            "fall"
        }
    }
}






#Preview {
    MarketPage()
}
