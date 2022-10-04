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
                    .font(Font.AppleSD10)
                Spacer()
            }
        }
        .frame(height: 18, alignment: .bottom)
    }
}
