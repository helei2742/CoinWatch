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
    额外区域的高度
     */
    @State private var extraAreaHeight: Double = 0
    
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
     是否显示警告
     */
    @State private var isShowAlert:Bool = false
    
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
    当前窗口最左边位置在原数据数组的下标
     */
    @State var windowStartIndex: Int?
    
    /**
    当前窗口最右边位置在原数组的下标
     */
    @State var windowEndIndex: Int?
    
    
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
    @State var dataset: LineDataset
    
    /**
     均线类型
     */
    var maIntervals: [MATypeItem] = []
    
    /**
     boll线设置
     */
    var bollConfig:(average:Int, n:Int) = (average: 21, n: 2)
    
    /**
     当前显示哪些图表
     */
    var getPrintState: () -> ChartPrintState = {
        ChartPrintState.K_MA_LINE
    }
    
    @Binding var klineInterval: KLineInterval
    
    /**
     回调，监听刷新k线
     */
    private var whenRefiresh:  ((Double) -> Void)? = nil
        
    init(
        symbol: String,
        kLineInterval: Binding<KLineInterval>,
        maIntervals: [MATypeItem],
        bollConfig:(average:Int, n:Int)? = (average: 21, n: 2),
        getPrintState: @escaping () -> ChartPrintState,
        whenRefiresh:((Double) -> Void)? = nil
    ) {
        self._klineInterval = kLineInterval
        
        self.dataset = LineDataset(
            symbol: symbol,
            kLineInterval: .d_1, //默认值，监听klinechart的该属性，更改dataset中的该属性
            dataset: [],
            windowStartIndex: 0,
            windowLength: viewKLineItemCount
        )
                
        self.maIntervals.append(contentsOf: maIntervals)
        
        self.getPrintState = getPrintState
        
        self.bollConfig = bollConfig ?? (average: 21, n: 2)
        
        self.whenRefiresh = whenRefiresh
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing:0){
                ZStack {
                    //背景显示的字
                    Text(dataset.symbol)
                        .font(.title)
                        .foregroundStyle(Color("SystemFontColor").opacity(0.4))
                    
                    
                    //加载动画
                    if isLoadingKLineData {
                        ProgressView()
                    }
                    
                    if dataset.count > 0 {
                        kLineScrollArea
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color("SystemBGColor").opacity(0.5))
                        
                        //最后一个k到y轴低线
                        newLineDataPriceLine
                    }
                    
                    // 显示十字线以及按住的KLineItem的信息
                    if isLineItemLongPress { //在长按
                        if selectedPosition != .zero {
                            longPressPrintView
                        }
                    }
                }
                
                
                ExtraArea(
                    height: $extraAreaHeight,
                    lineItemWidth: $lineItemWidth,
                    windowWidth: $windowWidth,
                    lineDataList: $dataset.dataset,
                    windowStartIndex: $windowStartIndex,
                    windowEndIndex: $windowEndIndex
                )
                .content
                .scaleEffect(x:1,y:-1)
                .frame(width: windowWidth, height: extraAreaHeight)
                
                Divider()
                
                Spacer()
            }
            .onAppear{
                //设置K线视图宽度、高度
                windowWidth = geometry.size.width
                windowHeight = geometry.size.height
                extraAreaHeight = windowHeight / 4
                
                lineItemWidth = windowWidth / Double(viewKLineItemCount) - marginOfLineItem
                
                scrollAreaWidth = windowWidth
                scrollAreaHeight = windowHeight - extraAreaHeight
                
                isLoadingKLineData = true
                
                dataset.kLineInterval = klineInterval
                
                //首次，加载数据，滚动到最后
                loadLineDataNetwork(beforeSuccessComplate: {
                    scrollToLast()
                })
            }
            .onChange(of: klineInterval) { _, new in //监听k线种类的改变，手动刷新
                dataset.kLineInterval = new
                windowStartIndex = nil
                windowEndIndex = nil
                isLoadingKLineData = true
                loadLineDataNetwork(beforeSuccessComplate: {
                    scrollToLast()
                })
            }
            .onChange(of: geometry.size.width){ _, new in
                windowWidth = new
            }
            .alert(isPresented: $isShowAlert) {
                    Alert(
                        title: Text("网络连接错误"),
                        message: Text("无法获取到k线数据，请检查您的网络连接或重试"),
                        primaryButton: .default(
                            Text("重试"),
                            action: {
                                loadLineDataNetwork(beforeSuccessComplate: {
                                    scrollToLast()
                                })
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("关闭"),
                            action: {
                                stopRefreshLineData()
                            }
                        )
                    )
            }
        }
        
    }
    
    
    
    /**
     图表信息栏
     */
    @ViewBuilder
    var chartInfoBar: some View {
        //当前显示图表状态
        VStack{
            // 实时获取当前显示的k线数据的下标
            let lineItem = focusLineItem()
            let chartPrintState = getPrintState()
            
            if lineItem != nil, chartPrintState == .MA_LINE, chartPrintState == .K_MA_LINE {
                //显示每根均线当前位置的价值
                ForEach(maIntervals, id: \.interval) { maInterval in
                    
                    let interval = maInterval.interval
                    Text("MA(\(interval)): \(String(describing: lineItem?.dictOfMA[interval]))")
                        .lineLimit(1)
                        .font(.littleFont())
                        .foregroundStyle(maInterval.color)
                }
            }
            
            if lineItem != nil, chartPrintState == .K_BOLL_LINE {
                //显示Boll指标值
                let bollLine = lineItem!.bollLine
                Text("BOLL:(\(bollConfig.average),\(bollConfig.n))")
                    .fixedSize()
                    .lineLimit(1)
                    .foregroundStyle(.orange)
                Text("UP:\(bollLine.upper.coinPriceFormat()))")
                    .fixedSize()
                    .lineLimit(1)
                    .foregroundStyle(.orange)
                Text("MB:\(bollLine.ma.coinPriceFormat())")
                    .fixedSize()
                    .lineLimit(1)
                    .foregroundStyle(.pink)
                Text("DN:\(bollLine.lower.coinPriceFormat())")
                    .fixedSize()
                    .foregroundStyle(.purple)
                    .lineLimit(1)
            }
        }
        
        .font(.littleFont())
        
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
        let chartPrintState = getPrintState()
        
        
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
        //取第一预测数据的index
        let lastIdx:Int = (dataset.dataset.firstIndex { entry in
            entry.isPredictData
        } ?? 0) - 1
        
        if lastIdx >= 0 && lastIdx < dataset.count {
            let last = dataset.dataset[lastIdx]
            
            let priceY = last.close * Double(heightRatio) - heightOffset
            //let  priceX = Double(lastIdx) * lineItemWidth + lineItemWidth/2
            
            
            Path { path in
                path.move(to: CGPoint(x:0, y: priceY))
                path.addLine(to: CGPoint(x: windowWidth, y: priceY))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
            .scaleEffect(x:1,y:-1)
            .overlay{
                Text(String(format:"%.2f", last.close))
                    .font(.littleFont())
                    .padding(3)
                    .background(Color("NormalBGColor").opacity(0.5))
                    .foregroundColor(Color("SystemFontColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .frame(width: 50)
                    .position(x: windowWidth - 20,y: scrollAreaHeight - priceY)
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
        let clickWindowTop:Bool = yPosition < scrollAreaHeight/2
        
        
        let index = Int((xPosition + scrollViewOffset!) / lineItemWidth)
        let itemData = dataset.getIndex(index)
        
        if let itemData = itemData {
            // 十字线
            Path { path in
                path.move(to: CGPoint(x: xPosition, y: 0))
                path.addLine(to: CGPoint(x: xPosition, y: scrollAreaHeight))
            }
            .stroke(
                Color("SystemFontColor"),
                lineWidth: 1
            )
            
            ZStack{
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addLine(to: CGPoint(x: windowWidth, y: yPosition))
                }
                .stroke(
                    Color("SystemFontColor"),
                    lineWidth: 1
                )
                let priceX = clickWindowLeft ? windowWidth - 25 : 20
                
                Text(String(format:"%.2f" ,(scrollAreaHeight - yPosition + heightOffset)/heightRatio))
                    .font(.littleFont())
                    .padding(3)
                    .background(Color("NormalBGColor").opacity(0.5))
                    .foregroundColor(Color("SystemFontColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .position(x: priceX, y: yPosition)
            }
            
            let cardX = clickWindowLeft ? xPosition + 3 : max(xPosition - windowWidth/3, 0)
            
            let cardY = clickWindowTop ? yPosition : yPosition - scrollAreaHeight/3
            
            
            
            //信息卡片
            HStack {
                VStack {
                    Text("时间")
                    Text("开")
                    Text("高")
                    Text("低")
                    Text("收")
                    Text("量")
                }
                VStack{
                    Text(DateUtil.dateToStr(date: itemData.openTime))
                    Text(itemData.open.coinPriceFormat())
                    Text(itemData.high.coinPriceFormat())
                    Text(itemData.low.coinPriceFormat())
                    Text(itemData.close.coinPriceFormat())
                    Text(itemData.volume.coinPriceFormat())
                }
                
            }
            .padding(10)
            .font(.littleFont())
            .background(Color("NormalBGColor").opacity(0.5))
            .foregroundStyle(Color("SystemFontColor"))
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
            .position(x: cardX, y: cardY)
        }
    }
    
    @ViewBuilder
    var KLineItemList: some View {
        LazyHStack(spacing: 0){
            if getPrintState() != .MA_LINE { // 需要画蜡烛的情况
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
        }
        .scrollTargetLayout()
        .overlay(
            ZStack {
                //K线上显示的所有额外图表
                dynamicExtraChartPrinter
            }
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
                    self.scrollViewOffset = new
                }
            )
            .onChange(of: scrollViewOffset) { old, new in
                guard let new else { return }
                var newOffset = new
                if newOffset < 0 {
                    newOffset = 0
                }
                if newOffset > scrollAreaWidth {
                    newOffset = scrollAreaWidth
                }
                
                whenOffsetChange(newOffset: newOffset)
            }
            .focusable(true)
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
                //                print("表冠滚动 \(newValue), index:\(index), scrollX:\(scrollX)")
            }
            
        }
        .overlay (  // Y轴
            HStack {
                Spacer()
                //Y轴线
                YAxisLine(
                    scrollAreaHeight: scrollAreaHeight,
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
                    height: scrollAreaHeight
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
        if windowStartIndex != nil &&
            windowStartIndex! < viewKLineItemCount
        {
            
            isLoadingKLineData = true
            
            let oldOffset = newOffset
            let oldCount = dataset.count
            
            //网络请求更新数据
            loadLineDataNetwork(beforeSuccessComplate: {
                if oldCount == 0 { //第一次
                    scrollToLast()
                } else {
                    position.scrollTo(x: Double(dataset.count - oldCount)*lineItemWidth + oldOffset)
                }
            })
        }
        
        
        updateWindowState(newOffset: newOffset)
    }
    
    func updateWindowState(newOffset: Double) {
        //更新窗口
        if newOffset >= 0 {
            if lineItemWidth != 0 {
                windowStartIndex = Int(newOffset/lineItemWidth)
                let end:Int = Int((newOffset + windowWidth)/lineItemWidth)
                windowEndIndex = end >= dataset.count ? dataset.count - 1: end
            }
        } else {
            windowStartIndex = nil
            windowEndIndex = nil
        }
       
        if let windowStartIndex = windowStartIndex {
            //更新高度比和偏移
            updateHeightRatioAndOffset(windowStart: windowStartIndex)
        }
    }
    /**
     网络请求加载数据，并处理相应的状态
     */
    func loadLineDataNetwork(beforeSuccessComplate:(()->Void)?) {
        print("开始加载k显示数据")
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
                //算boll
                dataset.calculateBoll(maInterval: 21, n:2)
                
                //刷新
//                updateViewModel()
                startRefreshLineData()
            }
        }
    }
    
    

    /**
     开始刷新k线数据
     */
    func startRefreshLineData() {
        //开始刷k线数据
        dataset.startRefresh { (res, count, newPrice) in
            if !res {
                stopRefreshLineData()
                isShowAlert = true
            } else {
                scrollAreaWidth = Double(dataset.count) * lineItemWidth
                updateWindowState(newOffset: scrollViewOffset! + Double(count) * lineItemWidth)

                if count > 0 {
                    //算ma
                    dataset.calculateMA(maIntervals: maIntervals)
                    //算boll
                    dataset.calculateBoll(maInterval: 21, n:2)
                }
                
                whenRefiresh?(newPrice)
            }
        }
    }
    
    /**
     停止刷新数据
     */
    func stopRefreshLineData() {
        dataset.stopRefresh()
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
        //        print("更新前 maxprice \(dataset.maxPrice), minprice \(dataset.minPrice),heightRatio \(heightRatio), heightOffset \(heightOffset)")
        dataset.calMaxMinPriceOfWindow(start: windowStart)
        heightRatio = scrollAreaHeight / (dataset.maxPrice - dataset.minPrice)
        heightOffset = dataset.minPrice * heightRatio
        
        //        print("更新完毕 maxprice \(dataset.maxPrice), minprice \(dataset.minPrice),heightRatio \(heightRatio), heightOffset \(heightOffset)")
    }
    
    
    
    /**
     获取当前选择的k线数据
     */
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
    
    func scrollToLast() {
        print("滚动到 - \(lineItemWidth * Double(dataset.count) - windowWidth)")
        position.scrollTo(x: lineItemWidth * Double(dataset.count) + windowWidth)
    }
}




#Preview {
    @Previewable @State var kline:KLineInterval = .M_1
    let state:ChartPrintState = .K_MA_LINE
   
    KLineChart(
        symbol: "BTCUSDT",
        kLineInterval: $kline,
        maIntervals: [MAType.ma_20, MAType.ma_5, MAType.ma_15],
        bollConfig: (average: 21, n: 2),
        getPrintState: {
            state.next()
        }
    )
    //        .frame(width: 120, height: 120)
}

