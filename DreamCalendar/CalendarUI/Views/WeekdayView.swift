//
//  WeekdayView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import SwiftUI

struct WeekdayView: View {
    
    private struct Constraint {
        static let height: CGFloat = 13
        static let width: CGFloat = 46
        static let leadingTrailingPadding: CGFloat = 10
        static let topPadding: CGFloat = 7
        static let bottomPadding: CGFloat = 6
        static let zeroPadding: CGFloat = 0
        static let blockInterval: CGFloat = 2
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: Constraint.blockInterval) {
            ForEach(Days.allCases, id: \.hashValue) { day in
                Text(String(describing: day))
                    .foregroundColor(Color.dayGray)
                    .font(Font.AppleSDSemiBold12)
                    .frame(width: Constraint.width,
                           height: Constraint.height,
                           alignment: .center)
            }
        }
        .frame(height: Constraint.height, alignment: .bottom)
        .padding(EdgeInsets(top: Constraint.topPadding,
                            leading: Constraint.leadingTrailingPadding,
                            bottom: Constraint.bottomPadding,
                            trailing: Constraint.leadingTrailingPadding))
    }
}
