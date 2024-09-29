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
        控制刷新
     */
    @State private var refreshViewId = Date().timeIntervalSince1970
    
    
    /**
     当前K线视图的宽度
     */
    @State private var windowWidth: Double = 0
    
    /**
     当前K线视图的高度
     */
    @State private var windowHeight: Double = 0
    
    
    /**
     当前选中的数据
     */
    @State private var selectedPosition:CGPoint? = .zero
    
    /**
     是否长按k线的某点
     */
    @State private var isLineItemLongPress = false
    
    
    /**
     当前是否在加载k线数据
     */
    @State private var isLoadingKLineData: Bool = false
    
    /**
     当前显示哪些图表
     */
    @State private var chartPrintState: ChartPrintState = .K_BOLL_LINE
    
    /**
     K线视图的Position， 可用于滚动到指定位置
     */
    @State var position:ScrollPosition = ScrollPosition(edge: .leading)
    
    /**
     当前图表滚动区域的偏移量
     */
    @State var scrollViewOffset:Double?
    
    /**
     表冠滚动的值
     */
    @State private var crownValue: Double = 0.0
    

    
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
     高度偏移量
     */
    @State var heightOffset: Double = 0
    
    
    /**
     数据集
     */
    @State var dataset: LineDataset = LineDataset(
        symbol: "BTCUSDT",
        kLineInterval: .d_1,
        dataset: [],
        windowStartIndex: 0,
        windowLength: 0
    )
    
    /**
     均线类型
     */
    var maIntervals: [MATypeItem] = []
    
    /**
     boll线设置
     */
    var bollConfig:(average:Int, n:Int) = (average: 21, n: 2)
    
    init(
        symbol: String,
        kLineInterval: KLineInterval,
        maIntervals: [MATypeItem],
        bollConfig:(average:Int, n:Int) = (average: 21, n: 2)
    ) {
        self.dataset.symbol = symbol
        self.dataset.kLineInterval = kLineInterval
        self.dataset.windowLength = viewKLineItemCount
        self.maIntervals.append(contentsOf: maIntervals)
        
        
        self.bollConfig = bollConfig
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                //背景显示的字
                Text(dataset.symbol)
                    .font(.title)
                    .foregroundStyle(.white)
                
                
                //加载动画
                if isLoadingKLineData {
                    
                }
                kLineScrollArea
                    .frame(maxWidth: .infinity, maxHeight: .infinity
                    )
                    .background(.gray.opacity(0.5))
                //图表
//                dynamicChartPrinter
                //图表控制栏
                chartInfoControlBar

                
                // 显示十字线以及按住的KLineItem的信息
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
                
                
                print("window区域宽 \(windowWidth) 高 \(windowHeight)")
                print("滚动区域宽 \(scrollAreaWidth) 高 \(scrollAreaHeight)")
                print("单个k线宽度 \(lineItemWidth)")
                print("高度比 \(heightRatio)")
            }
        }
    }
    
    func focusLineItem() -> LineDataEntry? {
        if scrollViewOffset == nil || selectedPosition == nil {
            return nil
        }
        var index:Int = Int((scrollViewOffset! + windowWidth) / lineItemWidth)
        if isLineItemLongPress && selectedPosition != nil {
            index = Int((selectedPosition!.x + scrollViewOffset!) / lineItemWidth)
        }
        return dataset.getIndex(index)
    }
    
    /**
     图表信息栏
     */
    @ViewBuilder
    var chartInfoControlBar: some View {
        //以及当前显示图表状态
        HStack {
            // 实时获取当前显示的k线数据的下标
            let lineItem = focusLineItem()
            
            if lineItem != nil, chartPrintState == .MA_LINE, chartPrintState == .K_MA_LINE {
                //显示每根均线当前位置的价值
                ForEach(maIntervals, id: \.interval) { maInterval in
                    
                    let interval = maInterval.interval
                    Text("MA(\(interval)): \(String(describing: lineItem?.dictOfMA[interval]))")
                        .font(.littleFont())
                        .foregroundStyle(maInterval.color)
                }
            }
            
            if lineItem != nil, chartPrintState == .K_BOLL_LINE {
                //显示Boll指标值
                let bollLine = lineItem!.bollLine
                Text("BOLL:(\(bollConfig.average),\(bollConfig.n))")
                    .foregroundStyle(.orange)
                Text("UP:\(bollLine.upper))")
                    .foregroundStyle(.orange)
                Text("MB:\(bollLine.ma)")
                    .foregroundStyle(.pink)
                Text("DN:\(bollLine.lower)")
                    .foregroundStyle(.purple)
            }
            
            //选择k线间隔
            List{
                Picker("k线间隔", selection: $dataset.kLineInterval) {
                    Text("15分").tag(KLineInterval.m_15)
                    Text("1时").tag(KLineInterval.h_1)
                    Text("1日").tag(KLineInterval.d_1)
                    Text("1周").tag(KLineInterval.w_1)
                    Text("1月").tag(KLineInterval.M_1)
                }
            }
            
            // 切换显示类型，选择显示的类型，
            Button {
                chartPrintState = chartPrintState.next()
            } label: {
                Label("Graph", systemImage: "chevron.right.circle")
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .padding()
                    .animation(.easeInOut, value: chartPrintState)
            }
        }
        .font(.littleFont())
        .frame (
            height: 15
        )
    }
    

    
    
    @ViewBuilder
    var maLineChart: some View {
        if dataset.count > 0 {
            //绘制均线
            ForEach(maIntervals, id: \.interval){ maInterval in
                MALine(
                    maType: maInterval,
                    lineDataEntryList: $dataset.dataset,
                    heightRatio: $heightRatio,
                    heightOffset: $heightOffset,
                    entryWidth: $lineItemWidth
                )
                .content
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity
                )
            }
        }
    }
    
    
    @ViewBuilder
    var bollLineChart: some View {
        //Boll线
        BollLine(
            lineDataEntryList: $dataset.dataset,
            heightRatio: $heightRatio,
            heightOffset: $heightOffset,
            entryWidth: $lineItemWidth
        )
        .content
        .frame(
            maxWidth: .infinity, maxHeight: .infinity
        )
    }
    /**
     动态显示当前的图表
     */
    @ViewBuilder
    var dynamicExtraChartPrinter: some View {
        if chartPrintState == .MA_LINE || chartPrintState == .K_MA_LINE {
            maLineChart
                .frame(width: scrollAreaWidth, height: scrollAreaHeight)
                .scaleEffect(x:1,y:-1)
                .id(refreshViewId)
                
        }
        
        if chartPrintState == .K_BOLL_LINE {
            bollLineChart
            .frame(width: scrollAreaWidth, height: scrollAreaHeight)
            .scaleEffect(x:1,y:-1)
            .id(refreshViewId)
        }
            
    }
    
    /**
     最新价格到y轴的线
     */
    @ViewBuilder
    var newLineDataPriceLine: some View {
        Path { path in
            if let last = dataset.dataset.last{
                let priceY = last.close * heightRatio - heightOffset
                var priceX = Double(dataset.count) * lineItemWidth
                priceX -= lineItemWidth / 2
                priceX -= scrollViewOffset ?? 0
                
                let rect = CGRect (
                    x: priceX,
                    y: priceY,
                    width: windowWidth - priceX,
                    height: 1
                )
                
                path.addRect(rect)
            }
        }
    }
    
    /**
     长按k线中的元素后展示的十字线和信息卡
     */
    @ViewBuilder
    var longPressPrintView: some View {
        //获取x坐标
        let xPosition:CGFloat = selectedPosition!.x
        let yPosition:CGFloat = selectedPosition!.y
        
        //        let windowX = xPosition - scrollViewOffset!
        
        //点击的坐标在左边还是右边
        let clickWindowLeft:Bool = xPosition < windowWidth/2
        //点击的坐标在左边还是右边
        let clickWindowTop:Bool = yPosition < windowHeight/2
        
        
        let index = Int((xPosition + scrollViewOffset!) / lineItemWidth)
        let itemData = dataset.getIndex(index)
        
        if let itemData = itemData {
            // 十字线
            Path { path in
                path.move(to: CGPoint(x: xPosition, y: 0))
                path.addLine(to: CGPoint(x: xPosition, y: scrollAreaHeight))
            }
            .stroke(
                .gray,
                lineWidth: 1
            )
            
            ZStack{
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addLine(to: CGPoint(x: windowWidth, y: yPosition))
                }
                .stroke(
                    .gray,
                    lineWidth: 1
                )
                let priceX = clickWindowLeft ? windowWidth - 25 : 20
                
                Text(String(format:"%.2f" ,(scrollAreaHeight - yPosition + heightOffset)/heightRatio))
                    .font(.littleFont())
                    .padding(3)
                    .background(.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .position(x: priceX, y: yPosition)
            }
            
            let cardX = clickWindowLeft ? xPosition + 3 : max(xPosition - windowWidth/3, 0)
            
            let cardY = clickWindowTop ? yPosition : yPosition - windowHeight/3
            
            
            
            //信息卡片
            HStack {
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
            }
            .padding(10)
            .font(.littleFont())
            .background(Color.black.opacity(0.5))
            .foregroundStyle(.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .position(x: cardX, y: cardY)
        }
    }
    
    @ViewBuilder
    var KLineItemList: some View {
        LazyHStack(spacing: 0){
            // 绘制每一根蜡烛
            ForEach(dataset.dataset) { lineDataEntry in
                CandlesstickShape(
                    lineDataEntry: lineDataEntry,
                    heightRatio: heightRatio,
                    heightOffset: heightOffset
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
                .id(lineDataEntry.id)
            }
        }
        .scrollTargetLayout()
        .overlay(
            //K线上显示的所有额外图表
            dynamicExtraChartPrinter
        )
        .overlay(   //X 轴
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
            //首次，加载数据，滚动到最后
            loadLineDataNetwork(beforeSuccessComplate: {
                if dataset.count >= viewKLineItemCount {
                    print("第一次加载数据完毕，scrollTo x-\(scrollAreaWidth)")
                    print("scrollOffset:\(String(describing: scrollViewOffset)), position\(String(describing: scrollPosition))")
                    
                    position.scrollTo(x: scrollAreaWidth)
                    updateHeightRatioAndOffset(windowStart: 0)
                    
                    print("滑动完毕")
                    print("scrollOffset:\(String(describing: scrollViewOffset)), position\(String(describing: scrollPosition))")
                }
                
            })
        }
    }
    
    /**
     K线滚动区域，添加了x，y轴
     */
    @ViewBuilder
    var kLineScrollArea: some View {
        HStack {
            // 绘制可滚动的k线展示区域以及x轴
            ScrollView(.horizontal) {
                KLineItemList
            }
            .scrollPosition($position)
            .onScrollGeometryChange( // 更新实偏移
                for: CGFloat.self,
                of: { geo in geo.contentOffset.x},
                action:{ old, new in
                    print(new)
                    self.scrollViewOffset = new
                }
            )
            .onChange(of: scrollViewOffset) { old, new in
                guard let new else { return }
                
//                if !new.isPositionedByUser {  // 调用position.scrollTo() 引起的偏移不调用whenOffsetChange
//                    print("系统引起的偏移，from\(old), to\(new)")
//                    return
//                }
                
                var newOffset = new
                if newOffset < 0 {
                    newOffset = 0
                }
                if newOffset > scrollAreaWidth {
                    newOffset = scrollAreaWidth
                }
                print("用户滚动偏移：\(new.formatted())")
                
                whenOffsetChange(newOffset: newOffset)
            }
            .digitalCrownRotation( //表冠滚动
                $crownValue,
                from: 0.0,
                through: Double(dataset.count),
                by: 1.0,
                sensitivity: .low,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue){ _, newValue in
                
                let index:Int = dataset.count - Int(newValue)
                let scrollX:Double = Double(index) * lineItemWidth - windowWidth + lineItemWidth / 2
                
                position.scrollTo(x: scrollX)
                print("表冠滚动 \(newValue), index:\(index), scrollX:\(scrollX)")
            }
            .focusable(true)
            .onChange(of: dataset.kLineInterval) { _, new in //监听k线种类的改变，手动刷新
                
                loadLineDataNetwork(beforeSuccessComplate: {
                    if dataset.count >= viewKLineItemCount {
                        print("K线类型改变，加载数据完毕。scrollTo x-\(scrollAreaWidth)")
                        print("scrollOffset:\(String(describing: scrollViewOffset)), position\(String(describing: scrollPosition))")
                        
                        position.scrollTo(x: scrollAreaWidth)
                        updateHeightRatioAndOffset(windowStart: 0)
                        
                        print("scrollOffset:\(String(describing: scrollViewOffset)), position\(String(describing: scrollPosition))")
                    }
                })
            }
        }
        .overlay (  // Y轴
            HStack {
                Spacer()
                //Y轴线
                YAxisLine(
                    windowHeight: windowHeight,
                    windowWidth: windowWidth,
                    heightRatio: heightRatio,
                    heightOffset: heightOffset,
                    scaleNumber: 3
                )
                .stroke(
                    .gray,
                    lineWidth: 1
                )
                .frame(
                    width: windowWidth,
                    height: windowHeight
                )
            }
        )
        .gesture ( //手势按压
            LongPressGesture(minimumDuration: 3)
                .onChanged { value in
                    self.isLineItemLongPress = !self.isLineItemLongPress
                }
                .simultaneously(
                    with:DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            selectedPosition = value.location
                            
                            print("按压，坐标（x:\(selectedPosition!.x),y:\(selectedPosition!.y)） scrollOffset:\(scrollViewOffset) windowWidth:\(windowWidth)")
                        })
                )
        )
    }
    
    
    /**
     offset更改的回调
     */
    func whenOffsetChange(newOffset: Double) {
        //实时更新偏移量
        print("new scroll offset \(newOffset)")
        
        //剩余没展示的点不足以覆盖整个窗口，再次尝试请求数据，需要再获取k线数据
        if dataset.count >= viewKLineItemCount ,
           newOffset < (Double(viewKLineItemCount) * lineItemWidth) ,
           !isLoadingKLineData {
            
            isLoadingKLineData = true
            
            let oldOffset = newOffset
            let oldCount = dataset.count
            
            //网络请求更新数据
            loadLineDataNetwork(beforeSuccessComplate: {
                position.scrollTo(point: CGPoint(x: Double(dataset.count - oldCount)*lineItemWidth + oldOffset , y: 0))
            })
        }
        
        
        updateHeightRatioAndOffset(windowStart: Int(newOffset/lineItemWidth))
    }
    
    /**
     网络请求加载数据，并处理相应的状态
     */
    func loadLineDataNetwork(beforeSuccessComplate:(()->Void)?) {
        print("开始价值k显示数据")
        dataset.loadLineData { res in
            switch res {
            case false: // load k线数据失败
                print("Load K 线数据失败")
            case true: // 成功
                print("load k 线数据完成 \n \(dataset.count)")
                //根据K线数据个数，滚动到相应位置
                scrollAreaWidth = Double(dataset.count) * lineItemWidth
                
                print("视图状态已更新， scrollAreaWidth \(scrollAreaWidth)")
                
                beforeSuccessComplate?()
                isLoadingKLineData = false
                
                //算ma
                dataset.calculateMA(maIntervals: maIntervals)
                
                dataset.calculateBoll(maInterval: 21, n:2)
                
                //刷新
                updateViewModel()
            }
        }
    }
    
    
    /**
        刷新绑定了refreshViewId的视图
     */
    private func updateViewModel() {
        refreshViewId = Date().timeIntervalSince1970
        
    }
    
    
    /**
     更新高度比和偏移量
     */
    func updateHeightRatioAndOffset(windowStart: Int) {
        //移动后要计算最大值和最小值
        print("更新前 maxprice \(dataset.maxPrice), minprice \(dataset.minPrice),heightRatio \(heightRatio), heightOffset \(heightOffset)")
        dataset.calMaxMinPriceOfWindow(start: windowStart)
        heightRatio = windowHeight / (dataset.maxPrice - dataset.minPrice)
        heightOffset = dataset.minPrice * heightRatio
        
        print("更新完毕 maxprice \(dataset.maxPrice), minprice \(dataset.minPrice),heightRatio \(heightRatio), heightOffset \(heightOffset)")
    }
}




#Preview {
    //       let lineDataEntry = LineDataEntry(openTime: Date(), closeTime: Date(), open: 100, close: 120, high: 131, low: 98, volume: 1000)
    
    KLineChart(
        symbol: "BTCUSDT",
        kLineInterval: .d_1,
        maIntervals: [MAType.ma_20, MAType.ma_5, MAType.ma_15],
        bollConfig: (average: 21, n: 2)
    )
    //        .frame(width: 120, height: 120)
}

