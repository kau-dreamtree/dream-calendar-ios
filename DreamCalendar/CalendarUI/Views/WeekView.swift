//
//  WeekView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import SwiftUI

struct WeekView: View {
    static let maximumLineCount = 7
    
    private let week: Week
    private let schedules: Schedules
    
    private struct Constraint {
        
        static let weekHeight: CGFloat = 11
        static let weekBlockWidth: CGFloat = 46
        static let weekBlockHeight: CGFloat = 13
        static let weekTopPadding: CGFloat = 5
        
        static let zeroPadding: CGFloat = 0
        static let blockHorizontalInterval: CGFloat = 2
        static let blockVerticalInterval: CGFloat = 1
        static let leadingTrailingPadding: CGFloat = 10
        static let weekBlockTopPadding: CGFloat = 21
    }
    
    init(week: Week, schedules: Schedules) {
        self.week = week
        self.schedules = schedules
    }
    
    var body: some View {
        ZStack {
            self.hiddenTouchButtonView
                .padding(EdgeInsets(top: Constraint.zeroPadding,
                                    leading: Constraint.leadingTrailingPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.leadingTrailingPadding))
            
            self.weekView
                .frame(minHeight: Constraint.weekHeight,
                       maxHeight: .infinity,
                       alignment: .top)
                .padding(EdgeInsets(top: Constraint.weekTopPadding,
                                    leading: Constraint.zeroPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.zeroPadding))
            
            self.weekBlockView
                .padding(EdgeInsets(top: Constraint.weekBlockTopPadding,
                                    leading: Constraint.leadingTrailingPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.leadingTrailingPadding))
        }
    }
    
    @ViewBuilder
    var weekView: some View {
        HStack(spacing: Constraint.blockHorizontalInterval){
            ForEach(0..<7) { day in
                if let day = self.week[day] {
                    Text("\(day.day)")
                        .font(.AppleSDSemiBold12)
                        .foregroundColor(day.dayColor)
                        .frame(width: Constraint.weekBlockWidth,
                               height: Constraint.weekBlockHeight,
                               alignment: .center)
                } else {
                    Text("0")
                        .font(.AppleSDSemiBold12)
                        .foregroundColor(.clear)
                        .frame(width: Constraint.weekBlockWidth,
                               height: Constraint.weekBlockHeight,
                               alignment: .center)
                }
            }
        }
    }
    
    @ViewBuilder
    var weekBlockView: some View {
        VStack(spacing: Constraint.blockVerticalInterval) {
            ForEach(0..<Self.maximumLineCount, id: \.hashValue) { day in
                if let schedules = self.schedules[day] {
                    blockView(schedules: schedules)
                } else {
                    blockView(schedules: [])
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var hiddenTouchButtonView: some View {
        HStack(spacing: Constraint.blockHorizontalInterval) {
            ForEach(0..<7) { day in
                Rectangle()
                    .frame(maxWidth: Constraint.weekBlockWidth, maxHeight: .infinity)
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print(day, "clicked")
                    }
            }
        }
    }
    
    func blockView(schedules: [ScheduleBlock?]) -> some View {
        return HStack(spacing: Constraint.blockHorizontalInterval) {
            ForEach(0..<schedules.count, id: \.hashValue) { index in
                BlockView(schedule: schedules[index], in: self.week)
                    .foregroundColor(schedules[index]?.backgroundColor ?? .clear)
            }
        }
    }
}


struct BlockView: View {
    private let schedule: ScheduleBlock?
    private let week : Week
    
    private struct Constraint {
        static let cornerRadius: CGFloat = 3
        static let height: CGFloat = 16
        static let width: CGFloat = 46
        static let zeroPadding: CGFloat = 0
        static let blockHorizontalInterval: CGFloat = 2
    }
    
    init(schedule: ScheduleBlock?, in week: Week) {
        self.schedule = schedule
        self.week = week
    }
    
    private var width: CGFloat {
        let dayCount: CGFloat = CGFloat(self.schedule?.length ?? 1)
        return dayCount * Constraint.width + (dayCount - 1) * (Constraint.blockHorizontalInterval)
    }
    
    var body: some View {
        ZStack {
            Text(schedule?.title ?? "공백")
                .font(.AppleSDBold12)
                .foregroundColor(schedule?.fontColor ?? .clear)
                .frame(height: Constraint.height, alignment: .center)
        }
        .frame(width: self.width, height: Constraint.height)
        .background(schedule?.backgroundColor ?? .clear)
        .cornerRadius(Constraint.cornerRadius)
    }
}

fileprivate extension ScheduleBlock {
    var backgroundColor: Color {
        return self.schedule.tag.lightColor
    }
    
    var fontColor: Color {
        return self.schedule.tag.color
    }
}
