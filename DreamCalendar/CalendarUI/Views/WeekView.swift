//
//  WeekView.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import SwiftUI

struct WeekView: View {
    private let week: Week
    private let schedules: Schedules
    
    init(week: Week, schedules: Schedules) {
        self.week = week
        self.schedules = schedules
    }
    
    var body: some View {
        ZStack {
            VStack {
                weekView
                    .frame(height: 11, alignment: .top)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }
            
            weekBlockView
                .padding(EdgeInsets(top: 21, leading: 8, bottom: 1, trailing: 8))
        }
    }
    
    @ViewBuilder
    var weekBlockView: some View {
        HStack {
            ForEach(0..<7) { day in
                if let schedules = self.schedules[day] {
                    blockView(schedules: schedules)
                } else {
                    blockView(schedules: [])
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var weekView: some View {
        HStack{
            Spacer()
            ForEach(0..<7) { day in
                if let day = self.week[day] {
                    Text("\(day.day)")
                        .font(.AppleSDSemiBold12)
                        .foregroundColor(day.dayColor)
                        .frame(maxWidth: .infinity, minHeight: 13, maxHeight: 13, alignment: .center)
                } else {
                    Text("0")
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, minHeight: 13, maxHeight: 13, alignment: .center)
                }
            }
            Spacer()
        }
    }
    
    
    func blockView(schedules: [ScheduleBlock]) -> some View {
        return VStack {
            if schedules.count > 0 {
                ForEach(0..<schedules.count) { index in
                    ZStack {
                        BlockView(schedule: schedules[index])
                            .foregroundColor(schedules[index].backgroundColor)
                    }
                }
            } else {
                Text("none21")
                    .foregroundColor(.clear)
            }
            Spacer()
        }
    }
}


struct BlockView: View {
    private let schedule: ScheduleBlock
    
    private struct Constant {
        static let cornerRadius: CGFloat = 3
        static let height: CGFloat = 16
    }
    
    init(schedule: ScheduleBlock) {
        self.schedule = schedule
    }
    
    var body: some View {
        ZStack {
            Text(schedule.title)
                .font(.AppleSDBold12)
                .foregroundColor(schedule.fontColor)
                .frame(height: Constant.height, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: Constant.height)
        .background(schedule.backgroundColor)
        .cornerRadius(Constant.cornerRadius)
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
