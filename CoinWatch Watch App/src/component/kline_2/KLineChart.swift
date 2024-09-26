//
//  KLineChart.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/25.
//

import Foundation
import SwiftUI



struct KLineChart: View {
    
    /**
     当前K线视图的宽度
     */
    @State private var windowWidth: Double = 0
    
    /**
     当前K线视图的高度
     */
    @State private var windowHeight: Double = 0
    
    /**
     K线视图滑动的偏移量
     */
    @State private var scrollViewOffset:Double = 0
    
    /**
     当前选中的数据
     */
    @State private var selectedPosition:CGPoint? = .zero
    
    /**
     是否长按k线的某点
     */
    @GestureState private var isLineItemLongPress = false
    
    
    /**
     当前是否在加载k线数据
     */
    @State private var isLoadingKLineData: Bool = false
    
    
    /**
     当前视图显示的K线线段的个数
     */
    let viewKLineItemCount:Int = 15
    
    /**
     k线元素之间的间距
     */
    let marginOfLineItem: Double = 0
    
    
    /**
     坐标轴线的宽度
     */
    let scaleWidth: Double = 2
    
    /**
     每个K线元素的宽度
     */
    @State var lineItemWidth: Double = 0
    
    /**
     滚动区域的宽度，也就是k线图展示的区域。窗口宽度减去轴线宽度
     */
    @State var scrollAreaWidth: Double = 0
    
    /**
     滚动区域的高度，也就是k线图展示的区域。窗口高度减去轴线宽度
     */
    @State var scrollAreaHeight: Double = 0
    
    /**
     组件item的高度比例，因为y轴是价格，所以表示单位价格的长度 height / (maxPrice - minPrice)
     */
    @State var heightRatio: Double = 1
    
    
    /**
     数据集
     */
    @State var dataset: LineDataset = LineDataset(
        symbol: "BTCUSDT",
        kLineInterval: .d_1,
        dataset: []
    )
    
    
    init(symbol: String, kLineInterval: KLineInterval) {
        self.dataset.symbol = symbol
        self.dataset.kLineInterval = kLineInterval
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                //背景显示的字
                Text(dataset.symbol).font(.title)
                
                //x线图
                kLineScrollArea
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity
                    )
                
                
                //                显示十字线以及按住的KLineItem的信息
                if isLineItemLongPress { //在长按
                    if selectedPosition != .zero {
                        longPressPrintView
                    }
                }
            }
            .frame(
                width: .infinity,
                height: .infinity
            )
            .onAppear{
                //设置K线视图宽度、高度
                windowWidth = geometry.size.width
                windowHeight = geometry.size.height
                lineItemWidth = windowWidth / Double(viewKLineItemCount) - marginOfLineItem
                scrollAreaWidth = windowWidth
                scrollAreaHeight = windowHeight
                
                isLoadingKLineData = true
                
                //heightRatio = windowHeight / (dataset.maxPrice - dataset.minPrice)
                
                print("window区域宽 \(windowWidth) 高 \(windowHeight)")
                print("滚动区域宽 \(scrollAreaWidth) 高 \(scrollAreaHeight)")
                print("单个k线宽度 \(lineItemWidth)")
                print("高度比 \(heightRatio)")
            }
        }
    }
    
    /**
     长按k线中的元素后展示的十字线和信息卡
     */
    @ViewBuilder
    var longPressPrintView: some View {
        
        // 十字线
        
        //获取相对于视图的x坐标
        let xPosition:CGFloat = selectedPosition!.x
        let index = dataset.count - Int((scrollViewOffset + xPosition) / lineItemWidth) - 1
        let itemData = dataset.getIndex(index)
        
        Path { path in
            path.move(to: CGPoint(x: xPosition, y: 0))
            path.addLine(to: CGPoint(x: xPosition, y: scrollAreaHeight))
        }
        
        //信息卡片
        
        //显示在坐标还是右边
        let showOnLeft:Bool = xPosition > windowWidth / 2
        HStack {
            if showOnLeft == false {
                Spacer()
            }
            
            VStack {
                Text("时间")
                Text("开")
                Text("高")
                Text("低")
                Text("收")
            }
            
            VStack{
                Text(DateUtil.dateToStr(date: itemData.openTime))
                Text(itemData.open.coinPriceFormat())
                Text(itemData.high.coinPriceFormat())
                Text(itemData.low.coinPriceFormat())
                Text(itemData.close.coinPriceFormat())
            }
            
            
            if showOnLeft {
                Spacer()
            }
        }
        .font(.littleFont())
        .background(Color.black.opacity(0.5))
        .foregroundStyle(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
    }
    
    /**
     K线滚动区域，添加了x，y轴
     */
    @ViewBuilder
    var kLineScrollArea: some View {
        HStack {
            // 绘制可滚动的k线展示区域以及x轴
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 0){
                        // 绘制每一根蜡烛
                        //                            let lineDataEntry = LineDataEntry(openTime: Date(), closeTime: Date(), open: 100, close: 120, high: 131, low: 98, volume: 1000)
                        //
                        Text(String(dataset.count))
                        if dataset.count > 0 {
                            
                            ForEach(dataset.dataset.reversed()) { lineDataEntry in
                                CandlesstickShape(
                                    lineDataEntry: lineDataEntry,
                                    heightRatio: heightRatio,
                                    heightOffset: dataset.minPrice * heightRatio
                                )
                                .fill(lineDataEntry.getColor())
                                .stroke(
                                    lineDataEntry.getColor(),
                                    lineWidth: 1
                                )
                                .frame(
                                    width: lineItemWidth,
                                    height: scrollAreaHeight
                                )
                                .scaleEffect(x:1,y:-1)
                            }
                        }
                    }
                    .overlay(
                        VStack {
                            Spacer()
                            XAxisLine()
                                .stroke(
                                    .gray,
                                    lineWidth: 1
                                )
                                .frame(width: scrollAreaWidth, height: 2)
                        }
                    )
                    .frame( //动态设置scollview的宽度
                        width: scrollAreaWidth,
                        height: scrollAreaHeight
                    )
                    .onAppear {
                        dataset.loadLineData { res in
                            heightRatio = windowHeight / (dataset.maxPrice - dataset.minPrice)
                            
                            
                            print("load k 线数据完成 \n \(dataset.count)")
                            //根据K线数据个数，滚动到相应位置
                            scrollAreaWidth = Double(dataset.count) * lineItemWidth
                            
                            if dataset.count >= viewKLineItemCount {
                                proxy.scrollTo(scrollAreaWidth)
                            }
                            
                            print("视图已更新， heightRatio\(heightRatio), scrollAreaWidth \(scrollAreaWidth)")
                            isLoadingKLineData = false
                        }
                        
                    }
                    .gesture (
                        LongPressGesture(minimumDuration: 1)
                            .updating($isLineItemLongPress){ currentState, gestureState, transaction in
                                gestureState = currentState
                            }
                            .simultaneously(
                                with:DragGesture(minimumDistance: 0)
                                    .onChanged({ value in
                                        selectedPosition = value.location
                                    })
                            )
                    )
                }

//                .onPreferenceChange(ViewOffsetKey.self) {
//                    //实时更新偏移量
//                    scrollViewOffset = $0
//                    print("scroll offset \(scrollViewOffset)")
//                    //剩余没展示的点不足以覆盖整个窗口，再次尝试请求数据，需要再获取k线数据
//                    let currentIndex:Int = scrollViewOffset > 0 ? Int(Double(scrollViewOffset) / Double(lineItemWidth)) :
//                    max(dataset.count, 0)
//                    
//                    if dataset.count >= viewKLineItemCount , currentIndex < viewKLineItemCount , !isLoadingKLineData {
//                        isLoadingKLineData = true
//                        
//                        dataset.loadLineData(
//                            whenComplate: { res in
//                                // 闭包，网络请求完成后调用
//                                let oldWidth = scrollAreaWidth
//                                let oldIndex = currentIndex
//                                
//                                switch res {
//                                case false: // load k线数据失败
//                                    print("e")
//                                case true: // 成功
//                                    //计算当前点在加载新数据后，所在的位置，并将ScrollView移到该位置
//                                    let newWidth = scrollAreaWidth
//                                    let newScollOffset = (newWidth - oldWidth) + Double(oldIndex) * lineItemWidth
//                                    proxy.scrollTo(newScollOffset)
//                                }
//                                isLoadingKLineData = false
//                            }
//                        )
//                        
//                    }
//                }
                
            }
        }
        .overlay (
            HStack {
                Spacer()
                //Y轴线
                YAxisLine(
                    height: windowHeight,
                    max: dataset.maxPrice,
                    min: dataset.minPrice,
                    scaleNumber: 3
                )
                .stroke(
                    .gray,
                    lineWidth: 1
                )
                .frame(
                    width: scaleWidth,
                    height: windowHeight
                )
            }
        )
    }
}


/**
 一根蜡烛的形状
 */
struct CandlesstickShape: Shape  {
    
    /**
     一根k线图的数据
     */
    let lineDataEntry: LineDataEntry
    
    /**
     高的比例，所有与高有关的数据都要乘
     */
    let heightRatio: Double
    
    let heightOffset: Double
    
    func path(in rect: CGRect) -> Path {
        let itemWidth = rect.width
        return Path { path in
            
            //绘制上下影线s
            path.move(to: CGPoint(x: itemWidth / 2, y: lineDataEntry.high * heightRatio - heightOffset))
            path.addLine(to: CGPoint(x: itemWidth / 2, y: lineDataEntry.low * heightRatio - heightOffset))
            
            //绘制实体部分 (矩形)
            if lineDataEntry.open < lineDataEntry.close { //涨
                let rect = CGRect (
                    x: (itemWidth / 2) - (itemWidth / 4),
                    y: lineDataEntry.open * heightRatio - heightOffset,
                    width: itemWidth / 2,
                    height:  CGFloat(abs(lineDataEntry.open - lineDataEntry.close) * heightRatio)
                )
                path.addRect(rect)
            } else {
                let rect = CGRect (
                    x: (itemWidth / 2) - (itemWidth / 4),
                    y: lineDataEntry.close * heightRatio - heightOffset,
                    width: itemWidth / 2,
                    height:  CGFloat(abs(lineDataEntry.open - lineDataEntry.close) * heightRatio)
                )
                path.addRect(rect)
            }
            
            
        }
    }
}

/**
 Y轴线
 */
struct YAxisLine: Shape {
    
    /**
     轴线高度
     */
    let height: CGFloat
    
    /**
     最大值
     */
    let max: CGFloat
    
    /**
     最小值
     */
    let min: CGFloat
    
    /**
     刻度数
     */
    let scaleNumber:Int
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width:CGFloat = rect.width
            
            let heightPrice:Double = (max - min) / height
            
            //画轴线
            path.move(to: CGPoint(x: width / 2, y: height))
            path.addLine(to: CGPoint(x: width / 2, y: 0))
            
            //画刻度
            let interval:CGFloat = height / Double(scaleNumber)
            
            let numbers: [Int] = Array(0...scaleNumber)
            numbers.forEach { i in
                let height:CGFloat = Double(i) * interval
                
                let printPrice = height * heightPrice
                
                //刻度线
                path.move(to: CGPoint(x: 0, y:height))
                path.addLine(to: CGPoint(x: width, y:height))
                
                
                Text(String(printPrice))
                    .font(.footnote)
                    .position(x: 0, y: height)
            }
        
        }
        
    }
}

/**
    X轴线
*/
struct XAxisLine: Shape {
    func path(in rect: CGRect) -> Path {
        let height = rect.height
        let width = rect.width
        var path = Path()
        //画轴线
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width, y: height))

        //画刻度
//        let interval:CGFloat = height / Double(scaleNumber)
        
        return path
    }
}


#Preview {
    
    KLineChart(symbol: "BTCUSDT", kLineInterval: .d_1)
    //        .frame(width: 120, height: 120)
}


