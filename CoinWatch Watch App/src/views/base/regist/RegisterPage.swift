//
//  RegisterPage.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/19.
//

import SwiftUI
import KeychainSwift

struct RegisterPage:View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                TextField("用户名/邮箱", text: $username)
                                .padding() // 添加一些内边距
                               
                TextField("密码", text: $password)
                                .padding() // 添加一些内边距
                
                
                Button(action: {
                    
                }){
                    Text("注册").font(Font.system(size: 14)).padding(0)
                }.foregroundStyle(Color(.yellow))
          
            }
        }
       
    }
}

#Preview {
    RegisterPage()
}
