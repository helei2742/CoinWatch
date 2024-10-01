//
//  LoginView.swift
//  CoinIWatch
//
//  Created by 何磊 on 2024/9/19.
//

import SwiftUI

struct MainView: View {
    
    /**
    定时刷新现货信息
     */
    @State private var spotInfoSyncTimer: SpotInfoSyncTimer =  SpotInfoSyncTimer()
    
    /**
    定时刷账户信息
     */
    @State private var accountInfoSyncTimer: AccountInfoSyncTimer = AccountInfoSyncTimer()
    
    /**
    页面的一个悬浮框，能全局使用
     */
    @State var natificationBar: NatificationBar = NatificationBar.getInstance()

    /**
    当前是否登录
     */
    @State var isLogin: Bool = false
        
    var body: some View {
        ZStack{        
            switch ViewRouter.currentView() {
            case .MainPage:
                Image(systemName: "bitcoinsign.gauge.chart.lefthalf.righthalf")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                    .onTapGesture {
                        ViewRouter.routeTo(newView: .LoginAndRegisterPage)
                    }
            case .LoginAndRegisterPage:
                LoginOrRegisterPage()
            case .HomePage:
                HomePage()
            case .CoinDetail:
                let payLoad = ViewRouter.getPayLoad(viewName: .CoinDetail)
                CoinDetailPage(
                    base: payLoad?["baseAssert"] as! String,
                    quote: payLoad?["quoteAssert"] as! String
                )
            }
            // 通知栏
            natificationBar
                .content()
        }
        .onAppear() {
            if LoginUtil.isLogin() {
                print("当前账户已登录")
                isLogin = true
            }
        }
        .onTapGesture {
            if natificationBar.isShowBar {
                natificationBar.close()
            }
        }
        .onChange(of: isLogin) { //监听登录，登录了开始刷数据
            if isLogin {
                BinanceApi.serverUsable(pingComplate: { res in
                    print("ping result \(res)")
                })
                startSyncDataTask()
            }
        }
        .onDisappear{ //关闭刷数据任务
            closeSyncDataTesk()
        }
    }
    
    /**
    开始同步数据任务
     */
    func startSyncDataTask() {
//        spotInfoSyncTimer.spotInfoSync()
        
        
        spotInfoSyncTimer.startTimer()
        accountInfoSyncTimer.startAccountSpotAssertSyncTimer()
//        accountInfoSyncTimer.startAccountSpotDayHistorySyncTimer()
    }
    
    /**
     关闭同步任务
     */
    func closeSyncDataTesk() {
        spotInfoSyncTimer.stopTimer()
        accountInfoSyncTimer.stopAccountSpotAssertSyncTimer()
//        accountInfoSyncTimer.stopAccountSpotDayHistorySyncTimer()
    }
}

struct LoginOrRegisterPage: View {
    var body: some View {
        NavigationView{
            VStack(spacing: 10){
                NavigationLink(destination: LoginPage()) {
                    Text("登录").bold().padding().font(Font.system(size: 19))
                }
                .background(Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
                .frame(height: 40)
                .clipShape(RoundedRectangle(cornerRadius:30))
                
                
                NavigationLink(destination: RegisterPage()) {
                    Text("注册").bold().padding().font(Font.system(size: 19))
                }
                .frame(height: 40)
                .clipShape(RoundedRectangle(cornerRadius:30))
            }
        }
    }
}

#Preview {
    MainView()
}
