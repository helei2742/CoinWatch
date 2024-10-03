//
//  LoginView.swift
//  CoinIWatch
//
//  Created by 何磊 on 2024/9/19.
//

import SwiftUI

struct MainView: View {
    
    /**
    页面的一个悬浮框，能全局使用
     */
    @State var natificationBar: NatificationBar = NatificationBar.getInstance()
    
    /**
     当前是否在检查登录
     */
    @State var chackingLogin: Bool = true
       
    /**
     当前登录用户
     */
    @State var user:UserInfo = UserInfo.sharedInstance
    
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
            //尝试自动登录
            LoginUtil.autoLogin()
        }
        .onTapGesture {
            if natificationBar.isShowBar {
                natificationBar.close()
            }
        }
        .onChange(of: user.usable) { //监听登录，
            if user.usable {
                //登录了，1.跳转到主页
                ViewRouter.routeTo(newView: .HomePage)
                
               
            }
        }
       
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
