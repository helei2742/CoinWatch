//
//  MarketPage.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/3.
//

import SwiftUI

struct MarketPage: View {
    
    @State var showAlert: Bool = false
    
    /**
     行情数据
     */
    @State var marketData = MarketData.sharedInstance
    
    /**
     收藏数据
     */
    @State var starData = StarData.sharedInstance
    
    /**
     数据加载状态, -1表示失败，0表示正在加载，1表示获取成功
     */
    @State var loadState: Int = 0

    /**
     搜索框绑定的字段
     */
    @State var searchText:String = ""

    /**
     是否显示详细信息
     */
    @State var isShowDetail:Bool = false
    
    /**
     ScrollView视图的Position， 可用于滚动到指定位置
     */
    @State var position:ScrollPosition = ScrollPosition(edge: .top)
    
    /**
     显示数据的类型
     */
    @State var marketPrintType:MarketPrintType = .spotHot100
   
    /**
     行情类型
     */
    @State var marketType: MarketType = .spot
    
    var body: some View {
        NavigationStack{
            
            VStack(spacing:0){
                if loadState == 0 {
                    ProgressView()
                }
                if loadState == 1{
                    scrollArea
                }
                if loadState == -1{
                    ErrorPlaceholderView(errorMessage: "数据加载失败")
                }
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
                
                ToolbarItem(placement: .bottomBar) {
                    toolBottom
                }
            }
            // 搜索框
            .searchable(text: $searchText, prompt: "Search")
            .onAppear{
                loadMarketData()
            }
            .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("网络连接错误"),
                        message: Text("无法获取到行情数据，请检查您的网络连接或重试"),
                        primaryButton: .default(
                            Text("重试"),
                            action: {
                                loadMarketData()
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("关闭"),
                            action: {
                                loadState = -1
                            }
                        )
                    )
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
    var toolBottom: some View {
        HStack {

            Spacer()
            
            Button {
                withAnimation{
                    position.scrollTo(edge: .bottom)
                }
            } label: {
                Label("Graph", systemImage: "arrow.down.app")
                    .multilineTextAlignment(.center)
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .padding()
            }
            .buttonStyle(SelectButtonStyle())
            .frame(width: 25, height: 25)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var scrollArea: some View {
        ScrollView {
            LazyVStack {
                ForEach(filterShowMarketData()) { item in
                    MarketCoinCard(
                        marketDataItem: item,
                        quote: .USDT,
                        symbolType: item.symbolType!
                    )
                }
            }
        }
        .scrollPosition($position)
    }
    
    /**
     过滤得到需要展示的数据
     */
    func filterShowMarketData() -> [MarketDataItem] {
        var res:[MarketDataItem] = []
        
        switch marketType {
        case .star:
            starData.starList.forEach { item in
                let symbol = CommonUtil.generalCoinSymbol(base: item.base, quote: item.quote)
                //过滤
                if !searchText.isEmpty && !symbol.contains(searchText) {
                    return
                }
                    
                if let md = marketData.selectItem(
                    symbol: symbol,
                    symbolType: item.symbolType
                ) {
                    res.append(md)
                }
            }
        case .spot:
            let data = searchText.isEmpty ? marketData.selectMarketTypeData(marketPrintType: marketPrintType): marketData.allSpotData
            
            let filter = data.filter { item in
                searchText.isEmpty || item.symbol.contains(searchText)
            }
            
            res.append(contentsOf: filter)
        case .contract:
            break
        }
        return res
    }

    
    /**
     加载行情数据,失败会弹出警告
     */
    func loadMarketData() {
        loadState = 0
        marketData.loadSpotMarketData(whenComplate: { res in
            if res == false {
                showAlert = true
                loadState = -1
            } else {
                loadState = 1
            }
        })
    }
//    
//    /**
//     获取symbol的类型，将marketType转为 SymbolType
//     */
//    func getSymbolType() -> SymbolType? {
//        switch marketType {
//        case .star:
//            return nil
//        case .spot:
//            return .spot
//        case .contract:
//            return .contract
//        }
//    }
    
    func getIconPath() -> String {
        switch marketPrintType {
        case .spotHot100:
            "hot"
        case .spotRise100:
            "rise"
        case .spotFall100:
            "fall"
        }
    }
}






#Preview {
    MarketPage()
}
