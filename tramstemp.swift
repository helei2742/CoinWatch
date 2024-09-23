import Foundation


class BinanceApi {
    @Binding var baseURL: BaseURL? = nil

    static var spotApi: SpotApi = SpotApi(baseURL)
    static var accountApi: AccountApi = AccountApi(baseURL)
    
    /**
    这是一个函数注释，用于说明函数的作用和参数含义
    - Parameters:
        - param1: 参数1的说明
        - param2: 参数2的说明
    - Returns: 返回值的说明
    */


    /**
        查看BaseURL对应的服务器能否使用，由于BaseURL里固定使用的是在Request

        - Returns: 返回值的说明
                { 
                    "status": 0,              // 0: 正常，1：系统维护
                    "msg": "normal"           // "normal", "system_maintenance"
                }
    */
    static func serverUsable() -> Bool {
        Bool res = true
        binanceApiRequestSync(url: baseURL + "/sapi/v1/system/status", 
                                ipWeight:1, 
                                success: data-> {
                                    res = data["status"] == 0
                                }, failure: error->{
                                    res = false
                                }
        )
        return res
    }

    

}

class AccountApi {
    @Binding var baseURL: BaseURL? = nil

    init (_ baseURL: BaseURL) {
        self.baseURL = baseURL
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
        successCall: JSON -> Void
    ) -> Void {

        BinanceApiRequest.binanceApiRequest(
            url: baseUrl + "/sapi/v1/accountSnapshot",
            ipWeight: 2400,
            parameters: [
                "type": type,
                "limit": limit,
                "sertTime": sertTime,
                "endTIme": endTIme
            ]
            success: successCall,

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
        successCall: JSON -> Void

     -> Void) {
        BinanceApiRequest.binanceApiRequest(
            method: .POST,
            url: baseUrl + "/sapi/v3/asset/getUserAsset",
            ipWeight: 5,
            body: [
                "asset": asset,
                "needBtcValuation": needBtcValuation
            ]
            success: successCall,

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
        successCall: JSON -> Void
    ) -> Void {
           BinanceApiRequest.binanceApiRequest(
            url: baseUrl + "/api/v3/account",
            ipWeight: 20,
            parameters: [
                "omitZeroBalances": omitZeroBalance
            ]
            success: successCall,

        )
    }
}

enum AssertType: String {
    case SPOT
    case MARGIN
    case FUTURES
}


class SpotApi {
    @Binding var baseURL: BaseURL? = nil

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
    func coinsNewPrice(symbols: [String], successCall: JSON -> Void) -> Void {
        if (baseArray.isEmpty) {
            return nil
        }
        
        binanceApiRequest(url: baseURL + "/api/v3/ticker/price", 
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
        type:APIResponseType? = .FULL, 
        successCall: JSON -> Void
        ) -> Void {
        
        let ipWeight = 80
        let count = symbols.count
        if count >= 1, count <= 20 {
            ipWeight = 2
        } else if count >=21, count <= 100 {
            ipWeight = 40
        } else {
            ipWeight = 80
        }
        
        binanceApiRequest(url: "/api/v3/ticker/24hr", 
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
        timeZone: String? = 0,
        type: APIResponseType? = .FULL,
        successCall: JSON -> Void
    ) -> Void {
        var ipWeight = symbols.count > 50 ? 200 : 4 * symbols.count


        binanceApiRequest(url: "/api/v3/ticker/tradingDay", 
                        ipWeight:ipWeight, 
                        parameters: [ 
                            "symbols": symbols, 
                            "timeZone": timeZone,
                            "type": type.rawValue
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
        successCall: JSON -> Void
    ) -> Void {
        let ipWeight = 250
      
        if limit >= 1, limit <= 100 {
            ipWeight = 5
        } else if limit >=101, limit <= 500 {
            ipWeight = 25
        } else if limit >=501, limit <= 1000 {
            ipWeight = 50
        } else if limit >=1001, limit <= 5000 {
            ipWeight = 250
        }

        binanceApiRequest(url: "/api/v3/depth", 
                        ipWeight:ipWeight, 
                        parameters: [
                            "symbol": symbol, 
                            "limit": limit
                        ],
                        success: data-> {
                            successCall(data)
                        }
                        )
    }


    func kLineData(
        symbol: String,
        interval: KLineInterval,
        startTime: Int?,
        endTime: Int?,
        timeZone: String? = "0(utc)",
        limit: Int? = 500
    ) -> Void {
        
        binanceApiRequest(url: "/api/v3/klines", 
                            ipWeight:2, 
                            parameters: [
                                "symbol": symbol, 
                                "interval": interval,
                                "startTime": startTime,
                                "endTime": endTime,
                                "timeZone": timeZone,
                                "limit": limit
                            ],
                            success: data-> {
                                successCall(data)
                            }
                        )
    }
}

enum KLineInterval:String {
    case s_1 = "1s"
    case m_1 = "1m"
    case m_3 = "3m"
    case m_5 = "5m"
    case m_15 = "15m"
    case h_1 = "1h"
    case h_2 = "2h"
    case h_4 = "4h"
    case h_6 = "6h"
    case h_8 = "8h"
    case h_12 = "12h"
    case d_1 = "1d"
    case w_1 = "1w"
    case M_1 = "1M"
}

enum APIResponseType:String {
    case FULL
    case MINI
}

import Foundation

class BinanceApiRequest {
    func binanceApiRequestSync(method: HTTPMethod = .get, 
                        path: String,
                        ipWeight: Int
                        body:Data? = nil, 
                        parameters: [:]? = nil, 
                        success : Data -> {}?=nil,
                        failure : BinanceAPIError -> {}?=nil) -> Void{
        // let semaphone = DispatchSemaphore(value: 0)
        await binanceApiRequest(
                method:method,
                path: path,
                ipWeight: ipWeight,
                body: body,
                parameters: parameters,
                success : (data) -> {
                if success != nil {
                    success(data)
                }
                    semaphone.signal()
                },
                failure: (error) -> {
                    failure(error)
                    semaphone.signal()
                }
        )
        // _ = semaphone.wait(timeout: .distantFuture)
    }

    func binanceApiRequest(method: HTTPMethod = .get, 
                        path: String,
                        ipWeight: Int
                        body:[:]? = nil, 
                        parameters: [:]? = [:], 
                        success : Data -> {}?=nil,
                        failure : BinanceAPIError -> {}?=nil) async -> Void{
        //TODO 计算更新ipWeight
        

        //必要参数
        parameters["timestamp"] = Date().milliStamp
        parameters["recvWindow"] = 0

        var queryString = ""
        //签名
        var sionedString = ""
        
        if (body != nil) { //body
            var str = ""
            for (key, value) in body {
                str = str + "&\(key)=\(value)"
            }
            if !str.isEmpty() {
                str.remove(at:0)
            }
            sionedString = sionedString + str
        }
        if (parameters != nil) { //query
            var str = ""
            for (key, value) in parameters {
                str = str + "&\(key)=\(value)"
            }
            if !str.isEmpty() {
                str.remove(at:0)
            }
            sionedString = sionedString + str
            queryString = str
        }
        
        var signature = getHMacSHA256(forMessage: sionedString, key:secretKey)
        
        request(
                method:method,
                path: path + "?" + queryString + "&signature=" + signature,
                body: body,
                success: success,
                failure: (error)->{ 
                    if failure == nil {
                        //TODO ui显示 error信息
                        print(error.rawValue)
                    } else {
                        failure(error)   
                    }
                }
            )
    }



    var apiKey:String = "" //放请求头
    var secretKey:String = "" //加密key

    func getHMacSHA256(forMessage message: String, key: String) -> String? {
        let hMacVal = HMAC(algorithm: HMAC.Algorithm.sha256, key: key).update(string: message)?.final()
        if let encryptedData = hMacVal {
            let decData = NSData(bytes: encryptedData, length: Int(encryptedData.count))
            let base64String = decData.base64EncodedString(options: .lineLength64Characters)
            print("base64String: \(base64String)")
            return base64String
        } else {
            return nil
        }
    }

    func HMAC_Sign(algorithm: CCHmacAlgorithm, keyString: String, dataString: String) -> String {
        if algorithm != kCCHmacAlgSHA1 && algorithm != kCCHmacAlgSHA256 {
            print("Unsupport algorithm.")
            return ""
        }
        
        let keyData = keyString.data(using: .utf8)! as NSData
        let strData = dataString.data(using: .utf8)! as NSData
        let len = algorithm == CCHmacAlgorithm(kCCHmacAlgSHA1) ? CC_SHA1_DIGEST_LENGTH : CC_SHA256_DIGEST_LENGTH
        var cHMAC = [UInt8](repeating: 0, count: Int(len))
        
        CCHmac(algorithm, keyData.bytes, keyData.count, strData.bytes, strData.count, &cHMAC)
        
        let data = Data(bytes: &cHMAC, count: Int(len))
        let base64String = base64Data.base64EncodedString()
        return base64String
    }

}
import Alamofire
/*
open func request(_ convertible: URLConvertible,
                      method: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      encoding: ParameterEncoding = URLEncoding.default,
                      headers: HTTPHeaders? = nil,
                      interceptor: RequestInterceptor? = nil,
                      requestModifier: RequestModifier? = nil)
 
open func request<Parameters: Encodable>(_ convertible: URLConvertible,
                                             method: HTTPMethod = .get,
                                             parameters: Parameters? = nil,
                                             encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                             headers: HTTPHeaders? = nil,
                                             interceptor: RequestInterceptor? = nil,
                                             requestModifier: RequestModifier? = nil)
 
open func request(_ convertible: URLRequestConvertible, interceptor: RequestInterceptor? = nil)


*/
//BASE_URL 全局变量
func request(method: HTTPMethod = .get, 
             path: String,
             body:Data? = nil,
             parameters: [:]? = nil
             success : JSON -> {}?=nil, 
             failure: BinanceAPIError -> {}?=nil, 
             isLoading:Bool? = nil
             ) {
    
    if isLoading == true {
        SVProgressHUD.showLoading()
    }
    

    
    let headers:HTTPHeaders =  [
        "Content-Type":"application/json;charset=UTF-8",
        "Accept":"application/json"
    ]

	Alamofire.request(path,
                      parameters:body, 
                      headersL headers,
                      encoding:JSONEncoding.default)
    .validate(contentType: K_APP_ACCEPTABLE_CONTENTTYPES)
    .responseJSON(completionHandler: {res in 
    	switch res.result.isSuccess {
                case true:
                	if success != nil {
                        success(JSON(res.data))
                    }
                case false:
                    let eCode = res.status 
            		let errorType = BinanceAPIError.ERROR_UNKNOW
        			if eCode == 403 {
                        errorType = .ERROR_WAF
                    } else if eCode == 409 {
                        errorType = .ERROR_CANCEL_REPLACE
                    } else if eCode == 429 {
                        errorType = .ERROR_REQUEST_LIMIT
                    } else if eCode/100 == 5 {
                        errorType = .ERROR_BINANCE_SERVER
                    } else if eCode/100 == 4 {
                        errorType = BinanceAPIError.ERROR_REQUEST
                    }
            		if (failure != nil) {
                        failure(errorType)
                    }
        }
     })    
}


enum BinanceAPIError: String {
    case ERROR_UNKNOW = "未知错误"
    case ERROR_REQUEST = "4xx 错误的请求内容、行为、格式"
    case ERROR_WAF = "403 违反WAF限制(Web应用程序防火墙)"
	case ERROR_CANCEL_REPLACE = "409 重新下单(cancelReplace)的请求部分成功。(比如取消订单失败，但是下单成功了)"   
    case ERROR_REQUEST_LIMIT = "429 警告访问频次超限，即将被封IP。"
    case ERROR_BINANCE_SERVER = "5XX Binance服务侧的问题。"
}


enum BaseURL: String {
	case PUBLIC_DATA_API = "https://data-api.binance.vision" //于仅发送公开市场数据的 API
    case NORMAL_API_1 = "https://api.binance.com"
    case NORMAL_API_2 = "https://api-gcp.binance.com"
    
    case PERFORMANCE_API_1 = "https://api1.binance.com"
	case PERFORMANCE_API_1 = "https://api2.binance.com"
	case PERFORMANCE_API_1 = "https://api3.binance.com"
    case PERFORMANCE_API_1 = "https://api4.binance.com"
}


import Foundation


/**
更新账户信息
*/
struct AccountInfoSyncTimer {

    @State private var accountSpotAssertSyncTimer =  Timer.scheduledTimer(
        timeInterval: 10, 
        target: self, 
        selector: AccountInfoSyncTimer.accountSpotAssertSync, 
        repeats: true
    ) 

    @State private var accountSpotDayHistorySyncTimer = Timer.scheduledTimer(
        timeInterval: 10, 
        target: self, 
        selector: AccountInfoSyncTimer.accountSpotAssertSync, 
        repeats: false
    )

    private var accountInfo:AccountGeneralModelData
    private var spotInfo:SpotInfo
    
    
    init (
        accountInfo: AccountGeneralModelData,
        spotInfo: SpotInfo
    ) {
        self.accountInfo = accountInfo
        self.spotInfo = spotInfo
    }


    /**
        同步账户的现货资产情况
    */
    func accountSpotAssertSync() {
        BinanceApi.accountApi.soptInfo (
            omitZeroBalances: true,
            successCall: setAccountSpotInfo
        )
    }

    func setAccountSpotInfo(data: JSON) {
        //更新 spotList
        let spotList = accountInfo.accountSpot        
        for item in data["balances"] {
            let existItem = spotList.first(shere: { (spotInfo) -> Bool in
                soptInfo.baseAsset == item["asset"]
            })
                
            if existItem != nil {//存在，更新
                existItem.count = item["free"]
            } else { //不存在，创建
                spotList.append(AccountSpotItem(
                    baseAssert: item["asset"],
                    count: item["free"]
                ))  
            }       
        }

        //更新spotTotalValue
        var totalValue = Double(0.0)
        for accountSpotItem in spotList {
            let symbol = accountSpotItem.baseAssert + accountSpotItem.spotUnit.rawValue
            if let spotInfoItem spotInfo.findSpotInfo(symbol: symbol) {
                totalValue += accountSpotItem.count * spotInfoItem.price
            }
        }

        accountInfo.spotTotalValue = totalValue

        //更新spotTotalCount
        accountInfo.spotTotalCount = spotList.count
    }


    /**
        同步账户现货历史资产
    */
    func accountSpotDayHistorySync() {
        let limit = 14
        let endTime = Date()
        let startTime = Date(timeInterval: -24*60*60*limit, since: endTime)

        BinanceApi.accountApi.assertSnapshoot (
            limit: limit,
            startTime: Int(startTime.timeIntervalSince1970),
            endTime: Int(endTime.timeIntervalSince1970)
            successCall: setAccountSpotDayHistory
        )
    }


    func setAccountSpotDayHistory(data: JSON) {
        let accountSpotDayHistory = [AccountSpotDayInfo]
        

        for daySnapshot in data["snapshotVos"] {
            let snapshotVos = daySnapshot["data"]["balances"]

            var item = AccountSpotDayInfo(
                date: Date(timeIntervalSince1970: updateTime),
                snapshotVos: snapshotVos
            )
            accountSpotDayHistory.append(item)

            //计算总价值
            var totalValue = 0.0

            let symbolMapCount = snapshotVos.reduce(into: [String: Double]()) {
                $0[$1["asset"] + accountInfo.spotUnit] = $1["price"] 
            }

            //等这个执行完
            BinanceApi.accountApi.tradingDayPrice (
                symbols: Array(symbolMapCount.keys),
                success: {data in
                    for item in data {
                        let symbol = item["symbol"]
                        let price = item["lastPrice"] 
                        let date = Date(timeIntervalSince1970: item["openTime"])

                        //记录或更新这条交易日信息
                        spotInfo.addCoinTradingDayInfo(date: date, symbol: symbol, value: item)                       

                        totalValue += symbolMapCount[symbol] * price
                    }      
                }
            ) 

            item["spotTotalValue"] = totalValue 
        }
    }


 }





import Foundation


/**
更新现货信息
**/
class SpotInfoSyncTimer {
    @State private var spotInfoSyncTimer =  Timer.scheduledTimer(
        timeInterval: 10, 
        target: self, 
        selector: SpotInfoSyncTimer.spotInfoSync, 
        repeats: true
    ) 


    private var spotInfo:SpotInfo
    private var accountInfo:AccountGeneralModelData



    init (spotInfo: SpotInfo, accountInfo: AccountGeneralModelData) {
        self.spotInfo = spotInfo
        self.accountInfo = accountInfo
    }

    func spotInfoSync() {
        // 先检查用户账户信息有没有同步到现货持仓数据
        let accountSpot = accountInfo.accountSpot

        if accountSpot.isEmpty {
            //没有数据，不进行同步
            print ("用户账户现货持仓数据暂未同步")
        } else {

            BinanceApi.spotApi.coinsNewPrice(
                symbols: accountSpot.map { old in
                    return CommonUtil.generalCoinPrintSymbol(base: old.baseAsset, quote: accountInfo.spotUnit.rawValue)
                },
                successCall: setSpotInfoFromResponse
            )
        }

    }

 
    func setSpotInfoFromResponse(data : JSON) {
        let spotInfoList = spotInfo.spotInfoList 
        
        for item in data {
            let symbol = item["symbol"]
            let quote = accountInfo.spotUnit.rawValue
            let base = symbol.substringToIndex(symbol.count - quote.count)

            let existItem = spotInfo.findSpotInfo(symbol)
            
            
            if existItem == nil {
                spotInfoList.append(SpotInfoItem(
                    base: base.
                    quote: quote.
                    price: item["price"]
                ))
            } else {

                existItem.price = item["price"]
            }
        }    
    }
}

//
//  DateUtil.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/9/21.
//

import Foundation
  

class DateUtil {
    
    static let inner: Inner = Inner(pattern: "yyyy-MM-dd HH:mm:ss")
    
    
    static func strToDate(str:String) -> Date? {
        return inner.strToDate(str: str)
    }

    static func dateToDay(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        return calendar.date(from: components)
    }
    
    static func areDatesOnSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
          
        // 通过比较两个日期的年、月、日组件来确定它们是否是同一天
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
          
        // 检查这些组件是否相同
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }
    
    static func toYearMonthDayStr(date: Date) -> String {
        return inner.dayFormatter.string(from: date)
    }
    
    class Inner {
        let dateFormatter:DateFormatter
        
        let dayFormatter: DateFormatter
        
        init(pattern: String) {
            self.dateFormatter = DateFormatter()
            self.dateFormatter.dateFormat = pattern
            
            self.dayFormatter = DateFormatter()
            self.dayFormatter.dateFormat = "yyyy-MM-dd"
        }

        func strToDate(str: String) -> Date? {
            // 设置日期格式以匹配你的字符串
            
            return dateFormatter.date(from: str)
        }
    }

}

//
//  SpotInfo.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/21.
//

import SwiftUI


class SpotInfo {
    @State var spotInfoList: [SpotInfoItem]

    var coinTradingDayInfo: CoinTradingDayInfo

    func findSpotInfo(base: String, quote: String) -> SpotInfoItem {
        return soptInfoList.first(shere: { (spotInfoItem) -> Bool in
                        spotInfoItem.base == base && spotInfoItem.quote == quote
                    })
    }
    
    func findSpotInfo(symbol: String) -> SpotInfoItem {
        return soptInfoList.first(shere: { (spotInfoItem) -> Bool in
                        symbol == spotInfoItem.base + spotInfoItem.quote
                    })
    }
}

class CoinTradingDayInfo {
    private var dayKeyCache: [Date, [String:[String:Any]]] = [:]

    func addCoinTradingDayInfo(date:Date, symbol: String, value: [String:Any]) {
        dayKeyCache[DateUtil.dateToDay(date)][symbol] = value
    }

    func getCoinTradingDayInfo(date: Date, symbol: String) -> [String:Any] {
        return dayKeyCache[DateUtil.dateToDay(date)][symbol]
    }
}

@Observable
class SpotInfoItem {
    var base: String
    var quote: String
    var price: Double
}


//
//  AccountGeneralModelData.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation


class AccountGeneralModelData: ObservableObject{
    static let sharedInstance = AccountGeneralModelData()
    
    
    @Published var spotTotalValue: Double//现货资产总价值
    @Published var spotTotalCount: Int = 0    //现货资产总数
    @Published var spotUnit: CoinUnit        //现货资产单位
    
    @Published var contractTotalValue: Double //合约资产总数
    @Published var contractTotalCount: Int = 0    //合约仓位个数
    @Published var contractUnit: CoinUnit       //合约资产单位
    
    var spotTotalValueDayHistory:[AccountSpotDayInfo] = [
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-22 11:11:11"), spotTotalValue: 18.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-21 11:11:11"), spotTotalValue: 12.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-20 11:11:11"), spotTotalValue: 10000.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-19 11:11:11"), spotTotalValue: 7002.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-18 11:11:11"), spotTotalValue: 1293.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-17 11:11:11"), spotTotalValue: 90.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-16 11:11:11"), spotTotalValue: 80.0),
        
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-15 11:11:11"), spotTotalValue: 80.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-14 11:11:11"), spotTotalValue: 8009.0),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-13 11:11:11"), spotTotalValue: 123),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-12 11:11:11"), spotTotalValue: 1242),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-11 11:11:11"), spotTotalValue: 3322),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-10 11:11:11"), spotTotalValue: 3213),
        AccountSpotDayInfo(date: DateUtil.strToDate(str: "2024-09-09 11:11:11"), spotTotalValue: 3000.0)
    ]


    @State var accountSpot:[String:AccountSpotItem]
    // var spotList: [SpotInfo] = [
    //     SpotInfo(baseAssert: "BTC"), SpotInfo(baseAssert: "ETH"),
    //     SpotInfo(baseAssert: "DOGE"), SpotInfo(baseAssert: "SOL")
    // ]
//
    private init() {
            // 初始化代码
        spotTotalValue = 11820.89
        spotUnit = .USDT
        
        contractTotalValue = 0.0
        contractUnit = .USDT
    }
    
    
}

class AccountSpotDayInfo: ObservableObject {
    var date: Date
    
    var snapshotVos: [String:Any]

    @Published var spotTotalValue: Double//现货资产总价值
    
    init(date: Date?, spotTotalValue: Double?) {
        self.date = date ?? Date()
        
        self.spotTotalValue = spotTotalValue ?? 0.0
    }
}

@Observable
class AccountSpotItem: Identifiable{
    static private var nextId = 0
    static private var lock = os_unfair_lock_s()
    
    var id: Int
    var baseAsset: String   // 现货名 如 BTC/USDT
   // var quoteAsset: String  // 计算单位 如 BTC/USDT
    
    var count: Double //个数
    var lastCount: Double //上一次的个数


    // var assetValue: Double //资产价值，相对于 计算单位
    // var lastAssetValue: Double //上一次的资产价值
    
    // var newPrise: Double   //最新价格，相对于 计算单位
    // var lastNewPrise: Double  //上一次的最新价格
    
    init(baseAsset:String?="BTC",
         count: Double? = 0.0
    ) {
        
        self.baseAsset = baseAssert ?? "BTC"
        self.count =  count ?? 0.0   
      
        os_unfair_lock_lock(&SpotInfo.lock)
        self.id = SpotInfo.nextId
        SpotInfo.nextId += 1
        os_unfair_lock_unlock(&SpotInfo.lock)
    }

    static func == (_ a: SpotInfoItem, _ b: SpotInfoItem) -> Bool {
        return a.baseAsset == b.baseAsset 
    }
}

