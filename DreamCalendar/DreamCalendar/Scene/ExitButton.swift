//
//  ExitButton.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/03.
//

import SwiftUI

struct ExitButton: View {
    @Binding private var isShow: Bool
    
    private struct Constraint {
        static let name: String = "xmark"
        static let heightWidth: CGFloat = 20
    }
    
    init(isShow: Binding<Bool>) {
        self._isShow = isShow
    }
    
    var body: some View {
        Button(action: {
            self.isShow = false
        }, label: {
            Image(systemName: Constraint.name)
                .resizable()
                .frame(width: Constraint.heightWidth, height: Constraint.heightWidth)
                .foregroundColor(.buttonLightGray)
                .scaledToFill()
        })
    }
}
