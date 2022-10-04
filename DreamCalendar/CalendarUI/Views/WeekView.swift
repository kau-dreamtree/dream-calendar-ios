//
//  WeekView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import SwiftUI

struct WeekView: View {
    private let week: Week
    
    init(week: Week) {
        self.week = week
    }
    
    var body: some View {
        HStack {
            Spacer()
            ForEach(0..<7) { day in
                if let day = self.week[day]?.day {
                    Text("\(day)")
                        .font(.AppleSD10)
                        .foregroundColor(.dayBlack)
                        .frame(width: 12, height: 11, alignment: .center)
                        .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0))
                } else {
                    Text("0")
                        .foregroundColor(.clear)
                }
                Spacer()
            }
        }
    }
}
