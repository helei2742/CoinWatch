//
//  HomePage.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/20.
//

import Foundation
import WatchKit
import SwiftUI


struct HomePage: View {
    
    /**
     检查是否还在加载
     */
    @State private var loadingCheckTimer:Timer?
    
    /**
    定时刷新现货信息
     */
    @State private var spotInfoSyncTimer: SpotInfoSyncTimer =  SpotInfoSyncTimer()
    
    /**
    定时刷账户信息
     */
    @State private var accountInfoSyncTimer: AccountInfoSyncTimer = AccountInfoSyncTimer()
    
    @State private var showAlert = false
    
    @State private var selection = 0
    
    
    @State var accountGeneralPageLoadState:Int = 0
    
    
    var body: some View {
        // 定义一个 Button，点击时触发 Alert
        
        GeometryReader { geo in
            TabView(selection: $selection) {
                Tab("账户",  systemImage: "paperplane", value: 0) {
                    ZStack{
                        if isLoding() {
                            ProgressView()
                        }
                        // 第一个标签页
                        AccountGeneralPage(loadState: $accountGeneralPageLoadState)
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                
                Tab("行情",  systemImage: "paperplane", value: 1) {
                    ZStack{
                        MarketPage()
                    }
                }
            }
            .tabViewStyle(VerticalPageTabViewStyle())
            .accentColor(.blue) // 设置标签栏的强调色
            .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("网络连接错误"),
                        message: Text("无法连接到服务器，请检查您的网络连接或重试"),
                        primaryButton: .default(
                            Text("重试"),
                            action: { //
                                startSyncDataTask()
                                
                                detectLoding()
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("关闭"),
                            action: {
                                closeSyncDataTesk()
                                
                                detectLoding()
                            }
                        )
                    )
            }
            .onAppear{
                //1.监听加载情况
                detectLoding()
                
                //2.开始刷数据
                BinanceApi.serverUsable(pingComplate: { res in
                    print("ping result \(res)")
                })
                startSyncDataTask()
            }
            .onDisappear{ //关闭刷数据任务
                closeSyncDataTesk()
            }
        }
    }
    
    
    func isLoding() -> Bool {
        return accountGeneralPageLoadState < 2
    }
    
    /**
     检测加载情况
     */
    func detectLoding() {
        loadingCheckTimer?.invalidate()
        loadingCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            if isLoding() {
                showAlert = true
            }
        }
    }
    
    /**
    开始同步数据任务
     */
    func startSyncDataTask() {
        closeSyncDataTesk()
        
        //手动执行一次
        spotInfoSyncTimer.spotInfoSync()
        accountInfoSyncTimer.accountSpotAssertSync()
        accountInfoSyncTimer.accountSpotDayHistorySync()
        
        //开启定时
        spotInfoSyncTimer.startTimer()
        accountInfoSyncTimer.startAccountSpotAssertSyncTimer()
        accountInfoSyncTimer.startAccountSpotDayHistorySyncTimer()
    }
    
    /**
     关闭同步任务
     */
    func closeSyncDataTesk() {
        spotInfoSyncTimer.stopTimer()
        accountInfoSyncTimer.stopAccountSpotAssertSyncTimer()
        accountInfoSyncTimer.stopAccountSpotDayHistorySyncTimer()
    }
}



#Preview {
    HomePage()
}
