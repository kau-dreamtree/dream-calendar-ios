//
//  Logo.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/03.
//

import SwiftUI

struct Logo: View {
    private struct Constraint {
        static let imageName: String = "Logo"
        static let imageTopPadding: CGFloat = 38
        static let imageHeight: CGFloat = 146
        static let imageWidth: CGFloat = 214
        static let zeroPadding: CGFloat = 0
    }
    
    var body: some View {
        Image(Constraint.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constraint.imageWidth,
                   height: Constraint.imageHeight,
                   alignment: .center)
            .padding(EdgeInsets(top: Constraint.imageTopPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.zeroPadding))
    }
}
