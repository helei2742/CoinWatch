//
//  DownButton.swift
//  CoinWatch
//
//  Created by 何磊 on 2024/10/5.
//


import SwiftUI

struct DownButton: View {
    
    var whenClick: () -> Void
    
    var body: some View {
        Button{
            whenClick()
        }label: {
            Image("down")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(SelectButtonStyle())
        .foregroundStyle(.gray)
        .background(.clear)
        .frame(width: 20, height: 20)
    }
}
