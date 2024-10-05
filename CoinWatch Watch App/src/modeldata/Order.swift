//
//  Order.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/5.
//
import Foundation

@Observable
class Order {
    
    /**
     base
     */
    var base: String
    
    /**
     quote
     */
    var quote: String
    
    /**
     symbol
     */
    var symbol: String {
        get{
            CommonUtil.generalCoinSymbol(base: base, quote: quote)
        }
    }
    
    /**
     订单类型
     */
    var orderType: OrderTypes = .LIMIT

    /**
    订单方向
     */
    var orderSide: OrderSide = .BUY
    
    /**
     价格
     */
    var price: Double = 0.0
    
    /**
     数量
     */
    var count: Double = 0.0
    
    /**
     成交金额
     */
    var totalValue: Double {
        get {
            price * count
        }
    }
    
    init(base: String, quote: String) {
        self.base = base
        self.quote = quote
    }
}
