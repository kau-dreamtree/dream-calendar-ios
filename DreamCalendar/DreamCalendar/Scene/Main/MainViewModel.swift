//
//  MainViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import Foundation

protocol DateManipulationDelegate {
    mutating func goToToday()
    mutating func goToPreviousMonth()
    mutating func goToNextMonth()
}

struct MainViewModel: DateManipulationDelegate {
    private(set) var selectedDate: Date
    
    init(selectedYear: Int? = nil, month selectedMonth: Int? = nil, day selectedDay: Int? = 32) {
        let year: Int, month: Int, day: Int
        let date = Date()
        
        if let selectedYear = selectedYear {
            year = selectedYear
        } else {
            year = date.year
        }
        
        if let selectedMonth = selectedMonth, (1...12) ~= selectedMonth {
            month = selectedMonth
        } else {
            month = date.month
        }
        
        if let selectedDay = selectedDay, (1...31) ~= selectedDay {
            day = selectedDay
        } else {
            day = date.day
        }
        
        self.selectedDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: year,
            month: month,
            day: day)
        ) ?? Date()
    }
    
    var currentTopTitle: String {
        return "\(String(self.selectedDate.year))년 \(self.selectedDate.month)월"
    }
    
    var isToday: Bool {
        let today = Date()
        return self.selectedDate.year == today.year && self.selectedDate.month == today.month
    }
    
    mutating func goToToday() {
        self = MainViewModel()
    }
    
    mutating func goToPreviousMonth() {
        self.selectedDate = Calendar.current.date(byAdding: .month,
                                                  value: -1,
                                                  to: self.selectedDate) ?? Date.now
    }
    
    mutating func goToNextMonth() {
        self.selectedDate = Calendar.current.date(byAdding: .month,
                                                  value: +1,
                                                  to: self.selectedDate) ?? Date.now
    }
    
    mutating func chooseSpecificDay(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
        self.selectedDate = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: year ?? self.selectedDate.year,
            month: month ?? self.selectedDate.month,
            day: day ?? self.selectedDate.day)
        ) ?? Date()
    }
}
