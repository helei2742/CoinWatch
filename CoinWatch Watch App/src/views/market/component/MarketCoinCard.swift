//
//  MarketPageItem.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/3.
//

import SwiftUI
import Charts

struct MarketCoinCard: View {
    @State var starData: StarData = StarData.sharedInstance
    
    @State private var showDetail: Bool = false
    
    @State var kLineData: [LineDataEntry] = []
    
    @State var loadState: Int = 0
    
    var marketDataItem: MarketDataItem?
    
    var quote: CoinUnit
    
    var symbolType: SymbolType
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
                .frame(height: 42)
            
            if showDetail {
                contentArea
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .onChange(of: showDetail) { oldValue, newValue in
            if newValue == true { //加载数据
                loadKLineData()
            }
        }
        
    }
    
    
    @ViewBuilder
    var topBar: some View {
        HStack(spacing: 0) {
            if let marketDataItem = marketDataItem {
                CoinImage(imageUrl: CommonUtil.getCoinLogoImageUrl(base: marketDataItem.base))
                
                VStack {
                    Text(marketDataItem.base)
                        .font(.headline)
                    Text("💲\(marketDataItem.newPrice().coinPriceFormat())")
                        .font(.littleFont())
                }
                
                Spacer()
                
                Text(String(format:"%.2f",marketDataItem.priceChangePercent) + "%")
                    .font(.numberFont_2())
                    .fontWeight(.bold)
                    .padding(3)
                    .background(marketDataItem.getColor())
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                
                Button {
                    withAnimation(.easeInOut(duration: 1)) {
                        showDetail.toggle()
                    }
                } label: {
                    Label("Graph", systemImage: "chevron.right.circle")
                        .multilineTextAlignment(.center)
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetail ? 90 : 0))
                        .scaleEffect(showDetail ? 1.5 : 1)
                        .padding()
                }
                .padding(0)
                .frame(width: 35, height: 20)
                .clipShape(Circle())
            }else {
                ErrorPlaceholderView(errorMessage: "加载失败")
            }
        }
        .padding(.leading, 5)
        .padding(.top, 5)
        .padding(.bottom, 5)
        .background(.blue)
    }
    
    @ViewBuilder
    var contentArea: some View {
        VStack {
            HStack(spacing: 0) {
                WordAndPrice(
                    word: "24h最高价",
                    number: marketDataItem!.highPrice,
                    isPrice: true,
                    priceColor: .red
                )
                
                Spacer()
                WordAndPrice(
                    word: "24h最低价",
                    number: marketDataItem!.lowPrice,
                    isPrice: true,
                    priceColor: .green
                )
                Spacer()
                
                WordAndPrice(word: "24h成交量", number: marketDataItem!.volume)
            }
            
            Spacer()
            Divider()
            
            detailAndStar
            
            Divider()
            
            chartArea
        }
        .padding(4)
        .background(.gray)
        
    }
    
    @ViewBuilder
    var detailAndStar: some View {
        HStack{
            Button {
                // 双击时触发的动作
                starData.starCoin(
                    base: marketDataItem!.base,
                    quote: quote.rawValue,
                    symbolType: symbolType
                )
                //震动
                WKInterfaceDevice.current().play(.success)
            } label: {
                Label("Graph", systemImage: "star.fill")
                    .multilineTextAlignment(.center)
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .padding()
            }
            .buttonStyle(SelectButtonStyle())
            .frame(width: 22, height: 22)
            .foregroundStyle(
                starData.isStarCoin(
                    base: marketDataItem!.base,
                    quote: quote.rawValue,
                    symbolType: symbolType
                ) ? .yellow : .white
            )
            Spacer()
            
            Button{
                ViewRouter.routeTo(newView: .CoinDetail, payload: [
                    "baseAssert": marketDataItem!.base,
                    "quoteAssert": quote.rawValue
                ])
            }label: {
                Text("查看详情")
                    .font(.defaultFont())
            }
            .buttonStyle(SelectButtonStyle())
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var chartArea: some View {
        switch loadState {
        case 1:
            let maxAmin = calMaxAndMin(list: kLineData)
            
            Chart(kLineData){ element in
                LineMark(
                    x: .value("日期", element.openTime),
                    y: .value("价格", element.close)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 100)
            .chartYScale(domain: maxAmin.min...maxAmin.max)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if value.as(Date.self) != nil {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour().minute()) // 时间刻度
                    }
                }
            }
            
        case -1:
            Text("加载失败")
        default:
            ProgressView()
        }
    }
    
    func calMaxAndMin(list: [LineDataEntry]) -> (max:Double, min: Double) {
        if list.isEmpty {
            return (0, 0)
        }
        var maxP:Double = 0
        var minP:Double = list[0].low
        
        kLineData.forEach { entry in
            maxP = max(maxP, entry.close)
            minP = min(minP, entry.close)
        }
        return (maxP,minP)
    }
    
    func loadKLineData() {
        if let marketDataItem = marketDataItem {
            kLineData.removeAll()
            loadState = 0
            BinanceApi.spotApi.kLineData(
                symbol: marketDataItem.symbol,
                interval: .m_15,
                limit: 50) { data, _ in
                    let arr:[LineDataEntry] = LineDataEntry.generalJSONToLineDataEntryArray(data: data)
                    kLineData.append(contentsOf: arr)
                    loadState = 1
                } failureCall: { error in
                    loadState = -1
                }
        }
    }
}

struct WordAndPrice: View {
    var word: String
    var number: Double
    var isPrice: Bool = false
    var priceColor: Color = .white
    
    var body: some View {
        VStack{
            Text(word)
                .foregroundStyle(Color("LittleFontColor"))
                .font(.littleFont())
            
            let text = isPrice ? "💲\(number.coinPriceFormat())" : "\(number.coinPriceFormat())"
            
            Text(text)
                .foregroundStyle(priceColor)
                .fontWeight(.black)
                .font(.numberFont_2())
        }
    }
}

#Preview {
    let item = MarketDataItem(
        symbol: "BTCUSDT", base: "BTC", priceChange: 1.0, priceChangePercent: 100.01, weightedAvgPrice: 600000, lastPrice: 600000, lastQty: 90, openPrice: 90, highPrice: 101, lowPrice: 80, volume: 100000, quoteVolume: 123, openTime: Date(), closeTime: Date())
    MarketCoinCard(marketDataItem: item, quote: .USDT, symbolType:.spot)
    //    MarketCoinCard(marketDataItem: $item)
    //    MarketCoinCard(marketDataItem: $item)
    
}
