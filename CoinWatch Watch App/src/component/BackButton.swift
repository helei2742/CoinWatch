//
//  BackButton.swift
//  CoinWatch Watch App
//
//  Created by 何磊 on 2024/9/22.
//

import SwiftUI

struct BackButton: View {
    @State var width: CGFloat
    
    var body: some View {
        Button(action: {
            ViewRouter.backLastView()
        }) {
                Image(systemName: "arrowshape.turn.up.backward.fill") // set image here
                .resizable()
                .frame(width: width, height: width)
                .padding(2)
                .clipShape(Circle())
        }
        .buttonStyle(SelectButtonStyle())
        .frame(width: width, height: width)
        .clipShape(Circle())
    }
}

struct SelectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
           configuration.label
           .buttonStyle(PlainButtonStyle())
           .padding(0)
           .clipShape(
               RoundedRectangle(cornerRadius: 2)
           )
           .scaleEffect(configuration.isPressed ? 0.9 : 1)
       }
}
