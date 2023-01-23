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
        static let leadingTrailingPadding: CGFloat = 10
        static let topPadding: CGFloat = 7
        static let bottomPadding: CGFloat = 6
        static let zeroPadding: CGFloat = 0
    }
    
    var body: some View {
        HStack {
            Spacer()
            ForEach(Days.allCases, id: \.hashValue) { day in
                Text(String(describing: day))
                    .foregroundColor(Color.dayGray)
                    .font(Font.AppleSDSemiBold12)
                    .frame(maxWidth: .infinity, minHeight: Constraint.height, maxHeight: Constraint.height, alignment: .center)
            }
            Spacer()
        }
        .frame(height: Constraint.height, alignment: .bottom)
        .padding(EdgeInsets(top: Constraint.topPadding,
                            leading: Constraint.leadingTrailingPadding,
                            bottom: Constraint.bottomPadding,
                            trailing: Constraint.leadingTrailingPadding))
    }
}
