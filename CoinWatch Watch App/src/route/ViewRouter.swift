//
//  File.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/19.
//

import Foundation
import SwiftUI


class ViewRouter: ObservableObject {
    private static let sharedInstance = ViewRouter()
    
    private static var payLoadPool:[ViewNames:[String:Any]] = [:]
    
    //当前界面发生变化的时候，将观察ViewRouter的视图，主界面要得到通知和更新————所以需要用@Published属性来wrap
    //@Published 属性包装器的工作原理与 @State 属性包装器非常相似。每次分配给包装的属性的值发生变化时，每个观察中视图都会重新渲染。
    @Published var currentView: ViewNames = .MainPage
    
    var lastView: ViewNames = .MainPage
    var lastPayload: [String: Any]? = [:]
    
    private init() {
        // 初始化代码
        registePayLoadKey(viewName: .CoinDetail, payload: [
            SystemConstant.COIN_BASE_KEY: SystemConstant.DEFAULT_BASE,
            SystemConstant.COIN_QUOTE_KEY: SystemConstant.DEFAULT_QUOTE
        ])
    }
    
    func registePayLoadKey(viewName: ViewNames, payload: [String:Any]?){
        
        ViewRouter.payLoadPool[viewName] = payload
    }
    
    static func routeTo(newView: ViewNames, payload: [String:Any]?=nil) {
        sharedInstance.registePayLoadKey(viewName: newView, payload:  payload)
        
        sharedInstance.lastView = ViewRouter.sharedInstance.currentView
        sharedInstance.currentView = newView
    }
    
    static func backLastView() {
        routeTo(newView: sharedInstance.lastView, payload: sharedInstance.lastPayload)
    }
    
    static func getPayLoad(viewName: ViewNames) -> [String:Any]? {
        return ViewRouter.payLoadPool[viewName]
    }
    
    static func getInstance() -> ViewRouter {
        return sharedInstance
    }
}
