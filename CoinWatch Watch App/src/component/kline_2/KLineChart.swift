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
    @State private var windowWidth: CGFloat = 0

    /**
        当前K线视图的高度
    */
    @State private var windowHeight: CGFloat = 0

    /**
        K线视图滑动的偏移量
    */
    @State private var scrollViewOffset:CGFloat = 0

    /**
        当前选中的数据
    */
    @State private var selectedLineItem: (scrollPosition:CGFloat, itemData:LineDataset?) = (0, nil)

    /**
        是否长按k线的某点
    */
    @GestureState private var isLineItemLongPress = false


    /**
        当前是否在价值k线数据
    */
    @State private var isLoadingKLineData: Bool = false

    /**
        当前视图显示的K线线段的个数
    */
    let viewKLineItemCount:Int = 15

    /**
        k线元素之间的间距
    */
    let marginOfLineItem: CGFloat = 10


    /**
        坐标轴线的宽度
    */
    let scaleWidth: CGFloat = 2

    /**
        每个K线元素的宽度
    */
    var lineItemWidth: Double {
        get {
            return windowWidth / Double(viewKLineItemCount) - marginOfLineItem
        }
    }

    /**
        滚动区域的宽度，也就是k线图展示的区域。窗口宽度减去轴线宽度
    */
    @State var scrollAreaWidth: Double {
        get {
            lineItemWidth * Double(dataset.count)
        }
    }

    /**
        滚动区域的高度，也就是k线图展示的区域。窗口高度减去轴线宽度
    */
    var scrollAreaHeight: Double {
        get {
            windowHeight - scaleWidth
        }
    }

    /**
        组件item的高度比例，因为y轴是价格，所以表示单位价格的长度 height / (maxPrice - minPrice)
    */
    var heightRatio: Double  {
        get {
            windowHeight / (dataset.maxPrice - dataset.minPrice)
        }
    }


    /**
        数据集
    */
    var dataset: LineDataset


    init(dataset: LineDataset) {
        self.dataset = dataset
    }

    var body: some View {
        
        ZStack {

           //背景显示的字
//           Text(dataset.symbol).font(.title)

           //x线图
           kLineScrollArea

           //显示十字线以及按住的KLineItem的信息
           if isLineItemLongPress { //在长按
                if selectedLineItem.itemData != nil {
                    longPressPrintView
                }
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
        let xPosition = selectedLineItem.scrollPosition - scrollViewOffset
        let itemData = selectedLineItem.itemData
        
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
//                Text(DateUtil.dateToStr(date: itemData.openTime?))
//                Text(itemData.open.coinPriceFormat())
//                Text(itemData.high.coinPriceFormat())
//                Text(itemData.low.coinPriceFormat())
//                Text(itemData.close.coinPriceFormat())
            }
            .font(.littleFont())
            .background(Color.black.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )


            if showOnLeft {
                Spacer()
            }
        }
    }

    /**
        K线滚动区域，添加了x，y轴
    */
    @ViewBuilder
    var kLineScrollArea: some View {
        HStack {
            // 绘制可滚动的k线展示区域以及x轴
            ScrollViewReader { proxy in
                ScrollView {
                    GeometryReader { geometry in
                        HStack{
                            var idx = 0
                            // 绘制每一根蜡烛
                            ForEach(dataset.usableDataset, id: \.id) { lineDataEntry in
                                CandlesstickShape(
                                    lineDataEntry: lineDataEntry,
                                    heightRatio: heightRatio
                                )
                                .stroke(
                                    lineDataEntry.getColor(),
                                    lineWidth: 2
                                )
                                .frame(
                                    width: lineItemWidth,
                                    height: windowHeight
                                )
//                                .gesture {
//                                    LongPressGesture(minimumDuration: 0.5)
//                                        .updating($isLineItemLongPress){ currentState, gestureState, transaction in
//                                            gestureState = currentState
//                                        }
//                                        .onChanged { _ in
                                            //长按选中更新选中的数据以及x坐标
//                                            selectedLineItem.itemData = lineDataEntry?
//                                            selectedLineItem.scrollPosition = idx * lineItemWidth + lineItemWidth / 2.0
//                                        }
//                                }
                            }
                        }
                        .frame( //动态设置scollview的宽度
                            width: scrollAreaWidth,
                            height: scrollAreaHeight
                        )
                        .overlay ( //x轴
                            VStack {
                                Spacer()
                            }
                        )
                        // .overlay ( // y轴

                        // )
                        .onAppear {
                            //设置K线视图宽度、高度
                            windowWidth = geometry.size.width
                            windowHeight = geometry.size.height
                            
                            isLoadingKLineData = true
                            dataset.loadLineData { res in
                                isLoadingKLineData = false
                                print("load k 线数据完成 \n \(dataset.count)")
                                //根据K线数据个数，滚动到相应位置
                                if dataset.count >= viewKLineItemCount {
                                    proxy.scrollTo(scrollAreaWidth)
                                }
                            }
                            
                        }
                        .background(.blue)
                        .onPreferenceChange(ViewOffsetKey.self) {
                            //实时更新偏移量
                            scrollViewOffset = $0

                            //剩余没展示的点不足以覆盖整个窗口，再次尝试请求数据，需要再获取k线数据
                            let currentIndex:Int = Int(scrollViewOffset / lineItemWidth)
                            if dataset.count >= viewKLineItemCount , currentIndex < viewKLineItemCount , !isLoadingKLineData {
                                isLoadingKLineData = true
                                
                   
                                dataset.loadLineData(
                                    whenComplate: { res in
                                        // 闭包，网络请求完成后调用
                                        let oldWidth = scrollAreaWidth
                                        let oldIndex = currentIndex
                                        
                                        switch res {
                                        case false: // load k线数据失败
                                            print("e")
                                        case true: // 成功
                                            //计算当前点在加载新数据后，所在的位置，并将ScrollView移到该位置
                                            let newWidth = scrollAreaWidth
                                            let newScollOffset = (newWidth - oldWidth) + Double(oldIndex) * lineItemWidth
                                            proxy.scrollTo(newScollOffset)
                                        }
                                        isLoadingKLineData = false
                                    }
                                )

                            }
                        }
                    }
                }
            }

            //Y轴线
             YAxisLine(
                height: windowHeight,
                max: dataset.maxPrice,
                min: dataset.minPrice,
                scaleNumber: 3
            )
             .stroke(
                 .black,
                 lineWidth: 1
             )
            .frame(
                width: scaleWidth,
                height: windowHeight
            )
        }
    }
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
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
    
    func path(in rect: CGRect) -> Path {
        let itemWidth = rect.width
        
        return Path { path in
            //绘制上下影线s
            path.move(to: CGPoint(x: itemWidth / 2, y: lineDataEntry.open * heightRatio))
            path.addLine(to: CGPoint(x: itemWidth / 2, y: lineDataEntry.close * heightRatio))

            //绘制实体部分 (矩形)
            let rect = CGRect (
                x: (itemWidth / 2) - (itemWidth / 4),
                y: lineDataEntry.close * heightRatio,
                width: itemWidth / 2,
                height:  CGFloat(abs(lineDataEntry.open - lineDataEntry.close) * heightRatio)
            )
            path.addRect(rect)
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
        let width = rect.width

        let heightPrice = (max - min) / height

        return Path { path in
            //画轴线
            path.move(to: CGPoint(x: width / 2, y: height))
            path.addLine(to: CGPoint(x: width / 2, y: 0))
        
            //画刻度
            let interval:CGFloat = height / Double(scaleNumber)
            
            var numbers: [Int] = Array(0...scaleNumber)
            
//            ForEach(numbers.indices, id: \.self){i in
//                let height:CGFloat = Double(i) * interval
//
//                let printPrice = height * heightPrice
//
//                //刻度线
//                Path { path in
//                    path.move(to: CGFloat(x: 0, y:height))
//                    path.addLine(to: CGPoint(x: width, y:height))
//                }
//
//                Text(String(printPrice))
//                    .font(.footnote)
//                    .position(x: 0, y: height)
//            }
        }

    }
}


#Preview {
    let dataset:LineDataset = LineDataset(
        symbol: "BTCUSDT",
        kLineInterval: .d_1,
        dataset: []
    )
    KLineChart(dataset: dataset)
}
