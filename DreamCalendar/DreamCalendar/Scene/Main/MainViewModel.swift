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

@propertyWrapper
struct MonthValue {
    private var month: Int = Date().month
    var wrappedValue: Int {
        get { return month }
        set { self.month = max(1, min(newValue, 12)) }
    }
}

@propertyWrapper
struct DayValue {
    private var day: Int? = Date().day
    var wrappedValue: Int? {
        get { return day }
        set {
            if let newDay = newValue {
                self.day = max(1, min(newDay, 31))
            } else {
                self.day = nil
            }
        }
    }
}

struct MainViewModel: DateManipulationDelegate {
    private(set) var currentYear: Int = Date().year
    @MonthValue private(set) var currentMonth: Int
    @DayValue private(set) var currentDay: Int?
    
    init(currentYear: Int? = nil, currentMonth: Int? = nil, currentDay: Int? = 32) {
        if let currentYear = currentYear {
            self.currentYear = currentYear
        }
        
        if let currentMonth = currentMonth {
            self.currentMonth = currentMonth
        }
        
        if let currentDay = currentDay, (0...31) ~= currentDay {
            self.currentDay = currentDay
        } else if currentDay == nil {
            self.currentDay = nil
        }
    }
    
    var currentTopTitle: String {
        return "\(String(currentYear))년 \(currentMonth)월"
    }
    
    var isToday: Bool {
        let today = Date()
        return self.currentYear == today.year && self.currentMonth == today.month
    }
    
    mutating func goToToday() {
        self = MainViewModel()
    }
    
    mutating func goToPreviousMonth() {
        switch currentMonth {
        case 1 :
            self = MainViewModel(currentYear: self.currentYear - 1,
                                 currentMonth: 12,
                                 currentDay: nil)
        default :
            self = MainViewModel(currentYear: self.currentYear,
                                 currentMonth: self.currentMonth - 1,
                                 currentDay: nil)
        }
    }
    
    mutating func goToNextMonth() {
        switch currentMonth {
        case 12 :
            self = MainViewModel(currentYear: self.currentYear + 1,
                                 currentMonth: 1,
                                 currentDay: nil)
        default :
            self = MainViewModel(currentYear: self.currentYear,
                                 currentMonth: self.currentMonth + 1,
                                 currentDay: nil)
        }
    }
    
    mutating func chooseSpecificDay(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
        self = MainViewModel(currentYear: year ?? self.currentYear,
                             currentMonth: month ?? self.currentMonth,
                             currentDay: day ?? self.currentDay)
    }
}
