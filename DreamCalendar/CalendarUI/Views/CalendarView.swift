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
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        
        static let radius: CGFloat = 15
        static let shadowColor: Color = Color.shadowGray
        static let shadowXY: CGFloat = 0.2
    }
    
    public static let bottomViewHeight: CGFloat = 323
    
    public enum Mode {
        case short(weekCount: Int), long(weekCount: Int)
        
        var maximumLineCount: Int {
            let weekBlockHeight: CGFloat = 16
            let topPadding: CGFloat = 2
            let heightPerBlock: CGFloat = weekBlockHeight + topPadding
            
            switch self {
            case .long(let weekCount) :
                let blockCollectionHeight = (self.maxTotalHeight / CGFloat(weekCount)) - self.blockCollectionTopPadding
                return Int(blockCollectionHeight / heightPerBlock)
            case .short :
                let blockCollectionHeight = self.weekHeight - self.blockCollectionTopPadding
                return Int(blockCollectionHeight / heightPerBlock)
            }
        }
        
        private var maxTotalHeight: CGFloat {
            let topPadding:CGFloat = 52
            let weekdayPadding: CGFloat = 26
            
            switch self {
            case .long :
                return UIScreen.screenHeight - topPadding - weekdayPadding
            case .short :
                return UIScreen.screenHeight - bottomViewHeight - topPadding - weekdayPadding
            }
        }
        
        var maxHeight: CGFloat {
            switch self {
            case .long :    return .infinity
            case .short :   return self.maxTotalHeight
            }
        }
        
        var weekHeight: CGFloat {
            let dividerHeight: CGFloat = 2
            switch self {
            case .long :
                return .infinity
            case .short(let weekCount) :
                return (self.maxTotalHeight / CGFloat(weekCount)) - dividerHeight
            }
        }
        
        var blockCollectionTopPadding: CGFloat {
            let longTopPadding: CGFloat = 20
            let shortTopPadding: CGFloat = 14
            
            switch self {
            case .long : return longTopPadding
            case .short : return shortTopPadding
            }
        }
        
        var dayTopPadding: CGFloat {
            let longTopPadding: CGFloat = 5
            let shortTopPadding: CGFloat = 3
            
            switch self {
            case .long : return longTopPadding
            case .short : return shortTopPadding
            }
        }
    }
    
    private let monthInfo: Month?
    private let schedules: [Schedules]
    @Binding private(set) var selectedDate: Date
    private let mode: Mode
    
    public init(defaultDate date: Date, selectedDate: Binding<Date>, schedules: [Schedule], isShortMode: Bool) {
        let year = date.year
        let month = date.month
        
        self.monthInfo = try? Month(year: year, month: month)
        
        if let month = self.monthInfo {
            let mode: CalendarView.Mode
            switch isShortMode {
            case true :     mode = Mode.short(weekCount: month.count)
            case false :    mode = Mode.long(weekCount: month.count)
            }
            self.schedules = Schedules.sortingSchedules(schedules, on: month, maximumLineCount: mode.maximumLineCount)
            self.mode = mode
        } else {
            let zero = 0
            self.schedules = []
            self.mode = Mode.long(weekCount: zero)
        }
        
        self._selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: Constraint.zeroPadding) {
            WeekdayView()
            
            if let monthInfo = monthInfo {
                VStack(spacing: Constraint.zeroPadding) {
                    let zero = 0
                    ForEach(zero..<monthInfo.count, id: \.hashValue) { weekIndex in
                        Divider()
                        if let week = monthInfo[weekIndex] {
                            WeekView(selectedDate: self.$selectedDate,
                                     week: week,
                                     schedules: schedules[weekIndex],
                                     mode: self.mode)
                        } else {
                            Text("")
                        }
                    }
                }
            } else {
                Text("error occured")
            }
        }
        .frame(maxHeight: self.mode.maxHeight)
        .background(Color.white)
        .cornerRadius(Constraint.radius)
        .shadow(color: Constraint.shadowColor,
                radius: Constraint.radius,
                x: Constraint.shadowXY,
                y: Constraint.shadowXY)
    }
}
