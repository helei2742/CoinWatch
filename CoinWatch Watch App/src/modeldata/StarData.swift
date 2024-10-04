//
//  StarData.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/4.
//

import Foundation
import SwiftyJSON

@Observable
class StarData {
    static let userDefaultsKey = "userstars"
    
    static let sharedInstance: StarData = StarData()
    
    /**
    收藏字典
     */
    var starDict:[String:StarDataItem] = [:]
    
    /**
     收藏列表
     */
    var starList:[StarDataItem] {
        get{
            starDict.map { (key: String, value: StarDataItem) in
                value
            }
        }
    }
    
    private init() {
        loadLocal()
    }
    
    /**
     收藏币种，已收藏则取消，未收藏则收藏
     */
    func starCoin(
        base:String,
        quote:String,
        symbolType: SymbolType)
    {
        let key = buildKey(base: base, quote: quote,symbolType: symbolType)
        if isStarCoin(key: key) { //存在，则取消收藏
            print("取消收藏 \(key)")
            starDict.removeValue(forKey: key)
        } else {
            print("收藏 \(key)")
            starDict[key] = StarDataItem(base: base, quote: quote, starDate: DateUtil.dateToTimestamp(date: Date())!, symbolType: symbolType)
        }
        saveLocal()
    }
    
    /**
     是否收藏
     */
    func isStarCoin(
        base:String,
        quote:String,
        symbolType: SymbolType) -> Bool
    {
        return isStarCoin(key: buildKey(base: base, quote: quote,symbolType: symbolType))
    }
    
    /**
     是否收藏
     */
    func isStarCoin(
        key:String
    ) -> Bool {
        return starDict[key] != nil
    }
    
    /**
     保存到userdefaults
     */
    func saveLocal() {
        UserDefaults.standard.set(JsonUtil.objToJSONStr(obj: starDict),forKey: StarData.userDefaultsKey)
    }
    
    /**
    加载本地的
     */
    func loadLocal() {
        let ditStr = UserDefaults.standard.string(forKey: StarData.userDefaultsKey)
        starDict.removeAll()
        if let jsonStr = ditStr {
            let jsonObj = JSON(parseJSON: jsonStr)
            
            jsonObj.dictionary?.forEach({ (key: String, value: JSON) in
                starDict[key] = StarDataItem(
                    base: value["base"].stringValue,
                    quote: value["quote"].stringValue,
                    starDate: value["starDate"].intValue,
                    symbolType: SymbolType.generateStr(str: value["symbolType"].stringValue)!
                )
            })
        }
        
    }
    
    /**
     构建key
     */
    func buildKey(base:String,
                  quote:String,
                  symbolType: SymbolType) -> String
    {
        return CommonUtil.generalCoinSymbol(base: base, quote: quote)+"/"+symbolType.rawValue
    }
}

/**
 收藏实体对象
 */
struct StarDataItem: Codable, Identifiable {
    var id = UUID()
    
    var base: String
    
    var quote: String
    
    var starDate: Int
    
    var symbolType:SymbolType
}
