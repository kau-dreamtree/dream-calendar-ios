//
//  CalendarView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/03.
//

import SwiftUI

enum CalendarUIError: Error {
    case monthIndexError
    case weekIndexError
}

public struct CalendarView: View {
    private let monthInfo: Month?
    private let schedules: [Schedules]
    
    public init(date: Date, schedules: [Schedule]) {
        let year = date.year
        let month = date.month
        
        self.monthInfo = try? Month(year: year, month: month)
        
        if let month = self.monthInfo {
            self.schedules = Schedules.sortingSchedules(schedules, on: month)
        } else {
            self.schedules = []
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            WeekdayView()
            
            if let monthInfo = monthInfo {
                VStack(spacing: 0) {
                    ForEach(0..<monthInfo.count, id: \.hashValue) { weekIndex in
                        Divider()
                        if let week = monthInfo[weekIndex] {
                            WeekView(week: week, schedules: schedules[weekIndex])
                        } else {
                            Text("")
                        }
                        Spacer()
                    }
                }
            } else {
                Text("error occured")
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.shadowGray, radius: 15, x: 0.2, y: 0.2)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        try? CalendarView(date: Date(),
                          schedules: [Schedule(id: UUID(),
                                               serverId: 1234,
                                               title: "heelo",
                                               isAllDay: true,
                                               startTime: Date.now,
                                               endTime: Calendar.current.date(byAdding: .day, value: 1, to: Date.now) ?? Date.now,
                                               tag: .babyBlue,
                                               isValid: true)])
            .previewDevice("iPhone 11")
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
    }
}
