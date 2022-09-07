//
//  CustomButtonStyle.swift
//  BILIBILI UP Helper
//
//  Created by KISEKI on 2022/9/8.
//

import Foundation
import SwiftUI

struct ButtonPressableStyle: ButtonStyle{
    
    let textColor: Color
    let strokeColor: [Color]
    let backgroundColor: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial
                        ,in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.angularGradient(colors: strokeColor, center: .center, startAngle: .degrees(90), endAngle: .degrees(-270)), lineWidth: configuration.isPressed ? 4 : 8)
                   .blur(radius: configuration.isPressed ? 3 : 5)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .background(
                Capsule()
                    .foregroundStyle(.angularGradient(colors: backgroundColor, center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)))
                    .opacity(configuration.isPressed ? 0.8 : 0.5)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            )
            
    }
}

extension View{
    func withPressableStyle(textColor: Color = .white, strokeColor: [Color], backgroundColor: [Color]) -> some View{
        buttonStyle(ButtonPressableStyle(textColor: textColor, strokeColor: strokeColor, backgroundColor: backgroundColor))
    }
}
