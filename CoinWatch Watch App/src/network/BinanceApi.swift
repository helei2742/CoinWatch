//
//  BinanceApi.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/23.
//
import Foundation
import SwiftUI
import SwiftyJSON

class BinanceApi {
    
    static var baseURL: BaseURL = BaseURL.PUBLIC_DATA_API
    
    static var spotApi: SpotApi = SpotApi(baseURL)
    
    static var accountApi: AccountApi = AccountApi(baseURL)
    
    
    /**
     查看BaseURL对应的服务器能否使用，由于BaseURL里固定使用的是在Request
     
     - Returns: 返回值的说明
     {
     "status": 0,              // 0: 正常，1：系统维护
     "msg": "normal"           // "normal", "system_maintenance"
     }
     */
    static func serverUsable() -> Bool {
        var res = true
        BinanceApiRequest.binanceApiRequest(
            url: baseURL.rawValue + "/sapi/v1/system/status",
            ipWeight:1,
            success: { data in
                res = data["status"] == 0
            }, failure: {error in
                res = false
            }
        )
        return res
    }
    
    
}

class AccountApi {
    var baseUrl: BaseURL
    
    
    init(_ baseUrl: BaseURL) {
        self.baseUrl = baseUrl
    }
    
    
    /**
     查询用户每日资产快照查询时间范围最大不得超过30天
     仅支持查询最近 1 个月数据
     若startTime和endTime没传，则默认返回最近7天数据
     - Parameters:
     - type: 资产类型
     - limit: limit时间
     - startTime: 开始时间
     - endTime: 结束时间
     - Returns:
     {
     "code":200, // 200表示返回正确，否则即为错误码
     "msg":"", // 与错误码对应的报错信息
     "snapshotVos":[
     {
     "data":{
     "balances":[
     {
     "asset":"BTC",
     "free":"0.09905021",
     "locked":"0.00000000"
     },
     {
     "asset":"USDT",
     "free":"1.89109409",
     "locked":"0.00000000"
     }
     ],
     "totalAssetOfBtc":"0.09942700"
     },
     "type":"spot",
     "updateTime":1576281599000
     }
     ]
     }
     */
    func assertSnapshoot (
        type: AssertType = .SPOT,
        limit: Int?,
        startTime: Int?,
        endTime: Int?,
        successCall: @escaping (JSON) -> Void
    ) -> Void {
        
        BinanceApiRequest.binanceApiRequest(
            url: self.baseUrl.rawValue + "/sapi/v1/accountSnapshot",
            ipWeight: 2400,
            parameters: [
                "type": type,
                "limit": limit,
                "sertTime": startTime,
                "endTime": endTime
            ],
            success: successCall
        )
    }
    
    /**
     获取用户持仓，仅返回>0的数据
     - Parameters:
     - asset: 名称，如BTC，如果资产为空，则查询用户所有的正资产
     - needBtcValuation: 是否需要返回兑换成BTC的估值
     - Returns:
     [
     {
     "asset": "AVAX",
     "free": "1",
     "locked": "0",
     "freeze": "0",
     "withdrawing": "0",
     "ipoable": "0",
     "btcValuation": "0"
     },
     {
     "asset": "BCH",
     "free": "0.9",
     "locked": "0",
     "freeze": "0",
     "withdrawing": "0",
     "ipoable": "0",
     "btcValuation": "0"
     }
     ]
     */
    
    func walletAssert(
        asset: String?,
        needBtcValuation: Bool?,
        successCall: @escaping (JSON) -> Void
    ) -> Void {
        BinanceApiRequest.binanceApiRequest(
            //            method: .post,
            url: baseUrl.rawValue + "/sapi/v3/asset/getUserAsset",
            ipWeight: 5,
            body: [
                "asset": asset,
                "needBtcValuation": needBtcValuation
            ],
            success: successCall
        )
    }
    
    
    /**
     获取当前现货账户信息。
     - Parameters:
     - omitZeroBalances: 如果true，将隐藏所有零余额。默认值：false
     - param2: 参数2的说明
     - Returns:
     
     {
     "makerCommission": 15,
     "takerCommission": 15,
     "buyerCommission": 0,
     "sellerCommission": 0,
     "commissionRates": {
     "maker": "0.00150000",
     "taker": "0.00150000",
     "buyer": "0.00000000",
     "seller": "0.00000000"
     },
     "canTrade": true,
     "canWithdraw": true,
     "canDeposit": true,
     "brokered": false,
     "requireSelfTradePrevention": false,
     "preventSor": false,
     "updateTime": 123456789,
     "accountType": "SPOT",
     "balances": [
     {
     "asset": "BTC",
     "free": "4723846.89208129",
     "locked": "0.00000000"
     },
     {
     "asset": "LTC",
     "free": "4763368.68006011",
     "locked": "0.00000000"
     }
     ],
     "permissions": [
     "SPOT"
     ],
     "uid": 354937868
     }
     */
    func soptInfo (
        omitZeroBalances:Bool?,
        successCall: @escaping (JSON) -> Void
    ) -> Void {
        BinanceApiRequest.binanceApiRequest(
            url: baseUrl.rawValue + "/api/v3/account",
            ipWeight: 20,
            parameters: [
                "omitZeroBalances": omitZeroBalances
            ],
            success: successCall
        )
    }
}

enum AssertType: String {
    case SPOT
    case MARGIN
    case FUTURES
}


class SpotApi {
    var baseURL: BaseURL
    
    init (_ baseURL: BaseURL) {
        self.baseURL = baseURL
    }
    
    
    /**
     获取币种最新价格
     - Parameters:
     - symbols: [String], 字符串数组，内容为币的symbol(base + quote) 如 BTCUSDT
     - successCall: JSON -> Void 请求成功的回调，参数为返回的Json对象
     [
     {
     "symbol": "LTCBTC",
     "price": "4.00000200"
     },
     {
     "symbol": "ETHBTC",
     "price": "0.07946600"
     }
     ]
     - Returns: VOid
     */
    func coinsNewPrice(symbols: [String], successCall: @escaping (JSON) -> Void) -> Void {
        
        BinanceApiRequest.binanceApiRequest(url: baseURL.rawValue + "/api/v3/ticker/price",
                                            ipWeight:4,
                                            parameters:  ["symbols": symbols],
                                            success: successCall
        )
    }
    
    
    /**
     币种24小时价格变化情况
     - Parameters:
     - symbols: [String], 字符串数组，内容为币的symbol(base + quote) 如 BTCUSDT
     - successCall: JSON -> Void 请求成功的回调，参数为返回的Json对象
     {
     "symbol": "BNBBTC",
     "priceChange": "-94.99999800",
     "priceChangePercent": "-95.960",
     "weightedAvgPrice": "0.29628482",
     "prevClosePrice": "0.10002000",
     "lastPrice": "4.00000200",
     "lastQty": "200.00000000",
     "bidPrice": "4.00000000",
     "bidQty": "100.00000000",
     "askPrice": "4.00000200",
     "askQty": "100.00000000",
     "openPrice": "99.00000000",
     "highPrice": "100.00000000",
     "lowPrice": "0.10000000",
     "volume": "8913.30000000",
     "quoteVolume": "15.30000000",
     "openTime": 1499783499040,
     "closeTime": 1499869899040,
     "firstId": 28385,   // 首笔成交id
     "lastId": 28460,    // 末笔成交id
     "count": 76         // 成交笔数
     }
     - Returns: 返回值的说明
     */
    func coins24HourPriceStatus(
        symbols:[String],
        type:ApiResponseType = .FULL,
        successCall: @escaping (JSON) -> Void
    ) -> Void {
        
        var ipWeight = 80
        let count = symbols.count
        if count >= 1, count <= 20 {
            ipWeight = 2
        }
        if count >= 21, count <= 100 {
            ipWeight = 40
        }
        
        BinanceApiRequest.binanceApiRequest(url: baseURL.rawValue + "/api/v3/ticker/24hr",
                                            ipWeight:ipWeight,
                                            parameters: [
                                                "symbols": symbols,
                                                "type": type.rawValue
                                            ],
                                            success: successCall
        )
    }
    
    /**
     币种交易日行情
     - Parameters:
     - symbols: [String], 字符串数组，内容为币的symbol(base + quote) 如 BTCUSDT
     - successCall: JSON -> Void 请求成功的回调，参数为返回的Json对象
     
     [
     {
     "symbol": "BTCUSDT",
     "priceChange": "-83.13000000",
     "priceChangePercent": "-0.317",
     "weightedAvgPrice": "26234.58803036",
     "openPrice": "26304.80000000",
     "highPrice": "26397.46000000",
     "lowPrice": "26088.34000000",
     "lastPrice": "26221.67000000",
     "volume": "18495.35066000",
     "quoteVolume": "485217905.04210480",
     "openTime": 1695686400000,
     "closeTime": 1695772799999,
     "firstId": 3220151555,
     "lastId": 3220849281,
     "count": 697727
     },
     {
     "symbol": "BNBUSDT",
     "priceChange": "2.60000000",
     "priceChangePercent": "1.238",
     "weightedAvgPrice": "211.92276958",
     "openPrice": "210.00000000",
     "highPrice": "213.70000000",
     "lowPrice": "209.70000000",
     "lastPrice": "212.60000000",
     "volume": "280709.58900000",
     "quoteVolume": "59488753.54750000",
     "openTime": 1695686400000,
     "closeTime": 1695772799999,
     "firstId": 672397461,
     "lastId": 672496158,
     "count": 98698
     }
     ]
     */
    func tradingDayPrice (
        symbols: [String],
        timeZone: String? = "0(UDC)",
        type: ApiResponseType? = .FULL,
        successCall: @escaping (JSON) -> Void
    ) -> Void {
        var ipWeight = symbols.count > 50 ? 200 : 4 * symbols.count
        
        
        BinanceApiRequest.binanceApiRequest(
            url: baseURL.rawValue + "/api/v3/ticker/tradingDay",
            ipWeight:ipWeight,
            parameters: [
                "symbols": symbols,
                "timeZone": timeZone!,
                "type": type!.rawValue
            ],
            success: successCall
        )
    }
    
    /**
     深度信息
     - Parameters:
     - symbol: String, 字符，内容为币的symbol(base + quote) 如 BTCUSDT
     - limit: 默认 100; 最大 5000. 可选值:[5, 10, 20, 50, 100, 500, 1000, 5000]
     
     如果 limit > 5000, 最多返回5000条数据.
     */
    func deepInfo (
        symbol: String,
        limit: Int? = 10,
        successCall: @escaping (JSON) -> Void
    ) -> Void {
        var ipWeight = 250
        if let limit = limit {
            if limit >= 1, limit <= 100 {
                ipWeight = 5
            }
            if limit >= 101, limit <= 500 {
                ipWeight = 25
            }
            if limit >= 501, limit <= 1000 {
                ipWeight = 50
            }
            if limit >= 1001, limit <= 5000 {
                ipWeight = 250
            }
        }
        
        
        BinanceApiRequest.binanceApiRequest(
            url: baseURL.rawValue + "/api/v3/depth",
            ipWeight:ipWeight,
            parameters: [
                "symbol": symbol,
                "limit": limit
            ],
            success: successCall
        )
    }
    
    
    func kLineData(
        symbol: String,
        interval: KLineInterval,
        startTime: Date? = nil,
        endTime: Date? = nil,
        timeZone: TimeZone? = .current,
        limit: Int? = 500,
        
        successCall: @escaping (JSON) -> Void,
        failureCall: @escaping (BinanceAPIError) -> Void
    ) -> Void {
        
        BinanceApiRequest.binanceApiRequest(
            url: baseURL.rawValue + "/api/v3/klines",
            ipWeight:2,
            parameters: [
                "symbol": symbol,
                "interval": interval.rawValue.toString(),
                "startTime": DateUtil.dateToTimestarp(date: startTime),
                "endTime": DateUtil.dateToTimestarp(date: endTime),
                "timeZone": (timeZone?.secondsFromGMT())! / 3600,
                "limit": limit
            ],
            success: successCall,
            failure: failureCall
        )
    }
    
}
