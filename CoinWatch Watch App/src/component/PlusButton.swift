//
//  PlusButton.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/10/5.
//

import SwiftUI

struct PlusButton: View {
    
    var whenClick: () -> Void
    
    var body: some View {
        Button{
            whenClick()
        }label: {
            Image("plus")
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
