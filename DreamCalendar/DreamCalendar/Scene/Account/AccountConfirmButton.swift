//
//  AccountConfirmButton.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/06.
//

import SwiftUI

struct AccountConfirmButton: View {
    
    private struct Constraint {
        static let height: CGFloat = 33
        static let width: CGFloat = 264
        static let radius: CGFloat = 13.5
        
        static let shadowX: CGFloat = 0
        static let shadowY: CGFloat = 2
        static let shadowRGB: CGFloat = 0
        static let shadowOpacity: CGFloat = 0.25
        static let shadowBlur: CGFloat = 4
    }
    
    private let fieldName: String
    private let action: () -> Void
    
    init(fieldName: String, action: @escaping () -> Void) {
        self.fieldName = fieldName
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action) {
            Text(self.fieldName)
                .font(.AppleSDRegular12)
                .foregroundColor(.white)
        }
        .frame(width: Constraint.width, height: Constraint.height)
        .background(Color.black)
        .cornerRadius(Constraint.radius)
        .shadow(color: Color(red: Constraint.shadowRGB,
                             green: Constraint.shadowRGB,
                             blue: Constraint.shadowRGB,
                             opacity: Constraint.shadowOpacity),
                radius: Constraint.shadowBlur,
                x: Constraint.shadowX,
                y: Constraint.shadowY)
    }
}

