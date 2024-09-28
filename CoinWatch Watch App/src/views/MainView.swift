//
//  LoginView.swift
//  CoinIWatch
//
//  Created by 何磊 on 2024/9/19.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @StateObject var natificationBar: NatificationBar = NatificationBar(
        isShowBar: false, dynamicContent: AnyView(EmptyView())
    )

        
    var body: some View {
        ZStack{
            //let component = viewRouter.routeConfig.pathDict[viewRouter.routeConfig.currentPath]?.component as View
            
            switch viewRouter.currentView {
            case .MainPage:
                Image(systemName: "bitcoinsign.gauge.chart.lefthalf.righthalf")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)))
                    .onTapGesture {
                        viewRouter.currentView = .LoginAndRegisterPage
                    }
            case .LoginAndRegisterPage:
                LoginOrRegisterPage()
            case .HomePage:
                HomePage()
            case .CoinDetail:
                CoinDetailPage().environmentObject(natificationBar)
            }
            
            // 通知栏
            natificationBar.content()
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
    MainView().environmentObject(ViewRouter.getInstance())
}
