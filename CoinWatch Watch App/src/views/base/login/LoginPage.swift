//
//  LoginPage.swift
//  CoinIWatch Watch App
//
//  Created by 何磊 on 2024/9/19.
//

import SwiftUI

struct LoginPage:View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack{
                TextField("用户名/邮箱", text: $username)
                    .padding() // 添加一些内边距
                    .offset(x: 0, y: 20)
                
                Spacer(minLength: 20)
                
                TextField("密码", text: $password)
                    .padding() // 添加一些内边距
                
                
                VStack(spacing: 30) {
                    
                    Button(action: {
                        LoginUtil.login(username: username, password: password) {(res) in
                            switch res {
                            case true:
                                //跳转Home
                                ViewRouter.routeTo(newView: .HomePage)
                            case false:
                                //TODO弹出错误
                                print("登录失败")
                            }
                        }
                        
                    }) {
                        Text("登录").font(Font.system(size: 14)).padding(0)
                    }
                    .foregroundStyle(Color(.green))
                    
                    HStack {
                        Button("验证码登录") {
                            // 设置 showingAlert 为 true 来显示 Alert
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) { // 使用 alert 修饰符
                            Alert(
                                title: Text("警告"),
                                message: Text("验证码登录功能尚未开发"),
                                primaryButton: .default(Text("确定"), action: {
                                    // 点击确定按钮后的操作
                                    // 这里将 showingAlert 设置为 false 来关闭 Alert
                                    showingAlert = false
                                }),
                                secondaryButton: .cancel() // 可选：添加取消按钮
                            )
                        }
                        .background(Color(.red))
                        
                        
                        
                        NavigationLink{
                            RegisterPage()
                        } label: {
                            Text("注册").font(Font.system(size: 14)).padding(0)
                        }
                        .background(Color(.red))
                    }
                }
            }
            .frame(height: 250)
            // .background(Color(.blue))
        }
    }
}

#Preview {
    LoginPage()
}
