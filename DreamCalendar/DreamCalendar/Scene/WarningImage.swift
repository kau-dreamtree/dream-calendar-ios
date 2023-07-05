//
//  WarningImage.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/07/05.
//

import SwiftUI

struct WarningImage: View {
    private struct Constraint {
        static let imageName: String = "exclamationmark.triangle"
        static let imageHeight: CGFloat = 10
        static let imageWidth: CGFloat = 10
        static let zeroPadding: CGFloat = 0
        static let trailingInterval: CGFloat = 2
    }
    
    let color: Color
    
    var body: some View {
        Image(systemName: Constraint.imageName)
            .resizable()
            .foregroundColor(self.color)
            .frame(width: Constraint.imageWidth, height: Constraint.imageHeight, alignment: .center)
            .padding(EdgeInsets(top: Constraint.zeroPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.trailingInterval))
    }
}
