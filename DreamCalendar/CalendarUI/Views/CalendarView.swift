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
    @Binding private(set) var selectedDate: Date
    
    public init(defaultDate date: Date, selectedDate: Binding<Date>, schedules: [Schedule]) {
        let year = date.year
        let month = date.month
        
        self.monthInfo = try? Month(year: year, month: month)
        
        if let month = self.monthInfo {
            self.schedules = Schedules.sortingSchedules(schedules, on: month)
        } else {
            self.schedules = []
        }
        
        self._selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            WeekdayView()
            
            if let monthInfo = monthInfo {
                VStack(spacing: 0) {
                    ForEach(0..<monthInfo.count, id: \.hashValue) { weekIndex in
                        Divider()
                        if let week = monthInfo[weekIndex] {
                            WeekView(selectedDate: self.$selectedDate, week: week, schedules: schedules[weekIndex])
                        } else {
                            Text("")
                        }
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
