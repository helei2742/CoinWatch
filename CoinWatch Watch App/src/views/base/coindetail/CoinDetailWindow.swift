//
//  CoinDetailWindow.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

struct CoinDetailWindow: View {
    /**
    该页面显示币种信息的数据，包含深度数据
     */
    @Binding var coinInfo: CoinInfo
    
    /**
     弹出框
     */
    var natificationBar: NatificationBar = NatificationBar.getInstance()
    
    /**
     是否全屏
     */
    @State var isFullScreen: Bool = false
    
    /**
     是否在加载深度信息
     */
    @State var isLoadingDeep: Bool = false
    
    /**
     当前选中的
     */
    @State var selectAsks: Double? = nil
    
    /**
     当前选中的
     */
    @State var selectDids: Double? = nil
    
    
    /**
     k线图表显示的类型
     */
    @State var chartPrintState: ChartPrintState = ChartPrintState.K_MA_LINE
    
    /**
     k线间隔
     */
    @State var kLineInterval: KLineInterval = .d_1
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                
                VStack(spacing:0) {
                    HStack(spacing:0){
                        //左边区域
                        deepGraph
                                                
                        //中间k线图
                        KLineChart(
                            symbol: CommonUtil.generalCoinSymbol(
                                base: coinInfo.base,quote: coinInfo.quote
                            ),
                            kLineInterval: $kLineInterval,
                            maIntervals: [MAType.ma_15, MAType.ma_20],
                            getPrintState: {
                                chartPrintState
                            }
                        )
                        .frame(width: geometry.size.width*0.7)
                    }
                }
                .font(.defaultFont())
                .navigationTitle(
                    Text("\(coinInfo.base)")
                )
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        KLineIntervalPicker(kLineInterval: $kLineInterval)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
//                        topToolbar
                        KLineTypeIcon(chartPrintState: $chartPrintState, clickCallBack: { cur in
                            chartPrintState = chartPrintState.next()
                            print(chartPrintState)
                        })
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        fullScreenButton
                    }
                }
                .onAppear{
                    isLoadingDeep = true
                    
                    coinInfo.loadDeepInfo { res in
                        print("loadsuccess")
                        isLoadingDeep = false
                    }
                }
            }
        }
    }
    
    /**
    名字和深度图
     */
    @ViewBuilder
    var deepGraph: some View {
        VStack(spacing:0){
            Divider()
                //深度图
            DeepInfoCard(
                rawSelectX: $selectAsks,
                deepDirection: .ASKS,
                deepArray: coinInfo.asks,
                whenPressData: printDeepInfo
            )
            .overlay {
                if isLoadingDeep {
                    ProgressView()
                }
            }
            
            Divider()
            
            DeepInfoCard(
                rawSelectX: $selectDids,
                deepDirection: .BIDS,
                deepArray: coinInfo.bids,
                whenPressData: printDeepInfo
            )
            .overlay {
                if isLoadingDeep {
                    ProgressView()
                }
            }
            Divider()
        }
        .padding(.trailing, 1)
    }
    
    
    @ViewBuilder
    var fullScreenButton: some View {
        Button {
            withAnimation {
                isFullScreen.toggle()
            }
        } label: {
            Image("fullscreen")
                .renderingMode(.original)
                .resizable()
                .foregroundStyle(Color("SystemFontColor"))
                .background(Color("MetricIconBGColor"))
                .frame(width: 20, height: 20)
                .scaledToFit()
        }
        .buttonStyle(SelectButtonStyle())
        .background(Color("MetricIconBGColor"))
        .frame(width: 20, height: 20)
        .clipShape(
            RoundedRectangle(cornerRadius: 0)
        )
        // 设置动画参数
        .sheet(isPresented: $isFullScreen) {
            KLineChart(
                symbol: CommonUtil.generalCoinSymbol(
                    base: coinInfo.base,quote: coinInfo.quote
                ),
                kLineInterval: $kLineInterval,
                maIntervals: [MAType.ma_15, MAType.ma_20],
                getPrintState: {
                    chartPrintState
                }
            )
        }
    }
    
    
    func printDeepInfo(selectedData: DeepInfoPoint?) -> Bool {
        if let selectedData {
            natificationBar.printContent(content: ["price: \(selectedData.price.coinPriceFormat())", "volume: \(selectedData.volume)"])
            return true
        }
        return true
    }
}


struct CoinImageAndName: View {
    @State private var showImage: Bool = true
    
    var baseAssert: String
    var quoteAssert: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showImage {
                    CoinImage(imageUrl: CommonUtil.getCoinLogoImageUrl(base: baseAssert))
                } else {
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
            .offset(y: 10)
            .onTapGesture{
                showImage = !showImage
            }
        }
        
    }
}
