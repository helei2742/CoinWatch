//
//  OrderConstants.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/5.
//

import Foundation


/**
 订单类型
 */
enum OrderTypes: String, CaseIterable, Identifiable {
    var id:  Self { self }
    /**
     限价单
     */
    case LIMIT
    /**
     市价单
     */
    case Market
    /**
     止损单
     */
    case STOP_LOSS
    /**
     限价止损单
     */
    case STOP_LOSS_LIMIT
    /**
     止盈单
     */
    case TAKE_PROFIT
    /**
     限价止盈单
     */
    case TAKE_PROFIT_LIMIT
    /**
     限价只挂单
     */
    case LIMIT_MAKER
    
    /**
     获取中文名
     */
    func name() -> String {
        switch self{
        case .LIMIT:
            return "限价单"
        case .Market:
            return "市价单"
        case .STOP_LOSS:
            return "止损单"
        case .STOP_LOSS_LIMIT:
            return "STOP_LOSS_LIMIT"
        case .TAKE_PROFIT:
            return "TAKE_PROFIT"
        case .TAKE_PROFIT_LIMIT:
            return "限价止盈单"
        case .LIMIT_MAKER:
            return "限价只挂单"
            
        }
    }
    
    func next() -> OrderTypes {
        let allCases = OrderTypes.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        let nextIndex = allCases.index(after: currentIndex)
        return nextIndex < allCases.endIndex ? allCases[nextIndex] : allCases.first!
    }
}

/**
 订单方向
 */
enum OrderSide:String, CaseIterable, Identifiable {
    var id:  Self { self }

    case BUY
    case SALE
}
