//
//  WeekdayView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import SwiftUI

struct WeekdayView: View {
    var body: some View {
        HStack {
            Spacer()
            ForEach(Days.allCases, id: \.hashValue) { day in
                Text(String(describing: day))
                    .foregroundColor(Color.dayGray)
                    .font(Font.AppleSDSemiBold12)
                    .frame(maxWidth: .infinity, minHeight: 13, maxHeight: 13, alignment: .center)
            }
            Spacer()
        }
        .frame(height: 13, alignment: .bottom)
        .padding(EdgeInsets(top: 7, leading: 0, bottom: 6, trailing: 0))
    }
}
