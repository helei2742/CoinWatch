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
        GeometryReader { geometry in
            
            HStack(spacing:2) {
                
                //坐标区域
                nameAndDeepGraph
                    .frame(width: geometry.size.width*0.3,height:geometry.size.height)
                    .background(Color("NormalBGColor").opacity(0.6))
                
                VStack { //右边区域
                    //顶部工具栏
                    topToolbar
                        .background(Color("NormalBGColor").opacity(0.6))
                        .frame(width: geometry.size.width*0.7)
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 0)
                    
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
                    
//                    //底部挂单情况
//                    VStack{
//                        Text("显示用户仓位和挂单")
//                    }
//                    .frame(height: geometry.size.height * 0.2)
//                    .background(Color("NormalBGColor").opacity(0.6))
                }
                //                .ignoresSafeArea()
                .frame(width: geometry.size.width*0.7,height:geometry.size.height)
            }
            .font(.defaultFont())
            .onAppear{
                isLoadingDeep = true
                
                coinInfo.loadDeepInfo { res in
                    print("loadsuccess")
                    isLoadingDeep = false
                }
            }
        }
    }
    
    /**
    名字和深度图
     */
    @ViewBuilder
    var nameAndDeepGraph: some View {
        VStack(spacing:0){
            //图标和名称
            //                    CoinImage(imageUrl: CommonUtil.getCoinLogoImageUrl(base: coinInfo.base))
            //                    .frame(width: geometry.size.width*0.12,height: geometry.size.width*0.12)
            //                    .edgesIgnoringSafeArea(.top)
            //                    .background(.red)
            
            VStack {
                Spacer()
                
                Text("\(coinInfo.base)")
                    .padding(0)
                    .font(.largeFont())
                    .lineLimit(1)
                Spacer()
//                HStack{
//                    Text("成交量")
//                        .font(.littleFont())
//                        .padding(0)
//                        .lineLimit(1)
//                    Text("200万")
//                        .font(.littleFont())
//                        .padding(0)
//                        .lineLimit(1)
//                }
//                
//                HStack{
//                    Text("净流入")
//                        .font(.littleFont())
//                        .padding(0)
//                        .lineLimit(1)
//                    Text("100万")
//                        .font(.littleFont())
//                        .padding(0)
//                        .lineLimit(1)
//                }
            }
            .padding(.bottom)
            
 
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
            

            Spacer()
        }
        .ignoresSafeArea()
        .padding(.trailing, 1)
    }
    
    
    
    @ViewBuilder
    var topToolbar: some View {
        GeometryReader { geometry in
            VStack{
                Spacer()
                HStack(spacing: 2){
                    
                    //选择k线间隔
                    KLineIntervalPicker(kLineInterval: $kLineInterval)
                    
                    // 切换显示类型，选择显示的类型，
                    KLineTypeIcon(chartPrintState: $chartPrintState, clickCallBack: { cur in
                        chartPrintState = chartPrintState.next()
                        print(chartPrintState)
                    })
                    
                    fullScreenButton
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 2)
        }
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
