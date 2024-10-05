//
//  TradeView.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/5.
//
import Foundation
import SwiftUI



struct TradeView: View {
    
    @State var accountInfo: AccountGeneralModelData = AccountGeneralModelData.sharedInstance
    
    
    
    /**
     是否显示下单确认
     */
    @State var isShowConfirm: Bool = false
    
    /**
     是否选择订单类型选择器
     */
    @State var isShowOrderTypePicker: Bool = false
    
    /**
     订单数据
     */
    @State var order:Order
    
    /**
     base
     */
    @State var base:String
    
    /**
     quote
     */
    @State var quote:String
    
        
    /**
     成交金额
     */
    @State var totalValue: Double = 0
    
    
    /**
     可用金额
     */
    var usableMoney:Double {
        switch order.orderSide {
            
        case .BUY:
            max(accountInfo.coinCount(base: quote) - totalValue, 0)
        case .SALE:
            max(accountInfo.coinCount(base: base) - totalValue, 0)
        }
       
    }
    
    /**
     确认下单的回调
     */
    var tradeCoinConfirmed: ((Order) -> Void)? = nil
    
    
    init(
        base: String,
        quote: String,
        price: Double,
        tradeCoinConfirmed: ((Order) -> Void)? = nil
    ) {
        self.base = base
        self.quote = quote
        self.order = Order(base: base, quote: quote)
        self.order.price = price
        self.tradeCoinConfirmed = tradeCoinConfirmed
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 5) {
                    VStack{
                        orderTypePicker
                        
                        orderSideSelector
                    }
                    .offset(y:-10)
                    
                    Divider()
                    
                    inputLine
                    
                    Divider()
                    
                    infoLine
                    
                    Divider()
                    
                    
                }
                .font(.numberFont_2())
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    confirmTrade
                }
            }
            .onChange(of: order.price) { oldValue, newValue in
                totalValue = newValue * order.count
            }
            .onChange(of: order.count) { old, new in
                totalValue = new * order.price
            }
            
        }
    }
    
    @ViewBuilder
    var orderSideSelector: some View {
        GeometryReader {geo in
            HStack(spacing: 0){
                Button {
                    withAnimation {
                        order.orderSide = .BUY
                    }
                } label: {
                    Text("买入")
                        .foregroundStyle(.white)
                        .font(.defaultFont())
                        .fontWeight(.black)
                }
                .padding(0)
                .buttonStyle(SelectButtonStyle())
                .frame(width: geo.size.width / 2, height: 20)
                .background(order.orderSide == .BUY
                            ? .green : .gray)
                .clipShape(
                    RoundedRectangle(cornerRadius: 2)
                )
                
                Button {
                    withAnimation {
                        order.orderSide = .SALE
                    }
                } label: {
                    Text("卖出")
                        .foregroundStyle(.white)
                        .font(.defaultFont())
                        .fontWeight(.black)
                }
                .padding(0)
                .buttonStyle(SelectButtonStyle())
                .frame(width: geo.size.width / 2, height: 20)
                .background(order.orderSide == .SALE
                            ? .red : .gray)
                .clipShape(
                    RoundedRectangle(cornerRadius: 2)
                )
            }
        }
    }
    
    @ViewBuilder
    var orderTypePicker: some View {
        Button {
            withAnimation {
                isShowOrderTypePicker.toggle()
            }
        } label: {
            Text(order.orderType.name())
                .foregroundStyle(.white)
                .font(.defaultFont())
                .fontWeight(.black)
        }
        .padding(0)
        .buttonStyle(SelectButtonStyle())
        .frame(height: 20)
        .clipShape(
            RoundedRectangle(cornerRadius: 2)
        )
        .sheet(isPresented: $isShowOrderTypePicker) {
            Picker("订单类型", selection: $order.orderType) {
                ForEach(OrderTypes.allCases) { type in
                    Text(type.name()).tag(type.name())
                }
            }
            .font(.defaultFont())
        }
    }
    
    @ViewBuilder
    var inputLine: some View {
        Group{
            HStack{
                DownButton(whenClick: {
                    order.price = max(0.01, order.price - 0.01)
                })
                VStack{
                    HStack{
                        Text("价格")
                            .font(.littleFont())
                        Spacer()
                    }
                    .frame(height: 8)
                    TextField("价格", value: $order.price, format: .number.precision(.significantDigits(8)))
                        .textFieldStyle(.plain)
                        .padding(0) // 添加一些内边距
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: 18)
                        .cornerRadius(5) // 可选：添加圆角
                        .shadow(radius: 0)
                }
                
                PlusButton(whenClick: {
                    order.price += 0.01
                })
            }
            .frame(height: 30)
    
            
            HStack{
                DownButton(whenClick: {
                    order.count = max(0, order.count - 0.01)
                })
                VStack{
                    HStack{
                        Text("数量")
                            .font(.littleFont())
                        Spacer()
                    }
                    .frame(height: 8)
                    TextField("数量", value: $order.count, format: .number.precision(.significantDigits(8)))
                        .textFieldStyle(.plain)
                        .padding(0) // 添加一些内边距
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: 18)
                        .cornerRadius(5) // 可选：添加圆角
                        .shadow(radius: 0)
                }
                
                PlusButton(whenClick: {
                    order.count = (usableMoney >= 0.01*order.price) ? order.count + 0.01: order.count
                })
            }
            .frame(height: 30)
            
            HStack{
                DownButton(whenClick: {
                    order.count = max(0, order.count - (usableMoney*0.01/order.price))
                })
                VStack{
                    HStack{
                        Text("成交金额")
                            .font(.littleFont())
                        Spacer()
                    }
                    .frame(height: 8)
                    TextField("成交金额", value: $totalValue, format: .number.precision(.significantDigits(8)))
                        .textFieldStyle(.plain)
                        .padding(0) // 添加一些内边距
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: 18)
                        .cornerRadius(5) // 可选：添加圆角
                        .shadow(radius: 0)
                }
                
                PlusButton(whenClick: {
                    order.count = order.count + (usableMoney*0.01/order.price)
                })
            }
            .frame(height: 30)
        }
    }
    
    @ViewBuilder
    var infoLine: some View {
        Group{
            HStack{
               
                if order.orderSide == .BUY {
                    Text("可用")
                        .font(.littleFont())
                    Spacer()
                    Text("\(usableMoney) \(quote)")
                }
                if order.orderSide == .SALE {
                    Text("可用")
                        .font(.littleFont())
                    Spacer()
                    Text("\(usableMoney) \(base)")
                }
            }
            
            HStack{
                if order.orderSide == .BUY {
                    Text("可买")
                        .font(.littleFont())
                    Spacer()
                    Text("\(order.price / usableMoney) \(base)")
                }
                if order.orderSide == .SALE {
                    Text("可卖")
                        .font(.littleFont())
                    Spacer()
                    Text("\(order.price * usableMoney) \(quote)")
                }
                
            }
            
            HStack{
                Text("预估手续费")
                    .font(.littleFont())
                Spacer()
                Text("\(order.price / usableMoney) \(base)")
            }
        }
    }
    
    @ViewBuilder
    var confirmTrade: some View {
        Button {
            isShowConfirm.toggle()
        } label: {
            Image("confirm")
                .renderingMode(.original)
                .resizable()
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .scaledToFit()
        }
        .background(order.orderSide == .SALE ? .red : .green)
        .buttonStyle(SelectButtonStyle())
        .frame(width: 20, height: 20)
        .clipShape(
            Circle()
        )
        .alert(isPresented: $isShowConfirm) {
            Alert(
                title: Text("下单缺认"),
                message: Text("是否以\(order.price) \(quote), \(order.orderSide.rawValue) \(order.count)个\(base)"),
                primaryButton: .default(
                    Text("关闭"),
                    action: {
                    }
                ),
                secondaryButton: .destructive(
                    Text("确认"),
                    action: {
                        checkAndConfirmTrade()
                    }
                )
            )
        }
    }
    
    /**
     检查合法性并确认
     */
    func checkAndConfirmTrade() {
        
        tradeCoinConfirmed?(order)
    }
}

#Preview {
    TradeView(base: "BTC", quote: "USDT", price: 10)
}
