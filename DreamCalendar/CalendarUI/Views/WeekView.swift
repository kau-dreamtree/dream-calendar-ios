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
                        .frame(width: 15, height: 13, alignment: .center)
                } else {
                    Text("0")
                        .foregroundColor(.clear)
                }
                Spacer()
            }
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

fileprivate extension Tag {
    var color: Color {
        switch self {
        case .babyBlue :
            return Color(red: 0.541, green: 0.667, blue: 0.898)
        case .green :
            return Color(red: 0.592, green: 0.737, blue: 0.384)
        case .yellow :
            return Color(red: 0.973, green: 0.824, blue: 0.157)
        case .orange :
            return Color(red: 1, green: 0.639, blue: 0.318)
        case .red :
            return Color(red: 0.817, green: 0, blue: 0)
        case .pink :
            return Color(red: 0.775, green: 0.333, blue: 0.704)
        case .purple :
            return Color(red: 0.453, green: 0.367, blue: 0.8)
        case .grey :
            return Color(red: 0.647, green: 0.612, blue: 0.58)
        case .navy :
            return Color(red: 0.163, green: 0.359, blue: 0.538)
        case .black :
            return Color(red: 0.213, green: 0.213, blue: 0.213)
        }
    }
    
    var lightColor: Color {
        switch self {
        case .babyBlue :
            return Color(red: 0.875, green: 0.906, blue: 0.965)
        case .green :
            return Color(red: 0.886, green: 0.922, blue: 0.835)
        case .yellow :
            return Color(red: 0.98, green: 0.945, blue: 0.776)
        case .orange :
            return Color(red: 0.988, green: 0.898, blue: 0.82)
        case .red :
            return Color(red: 0.973, green: 0.812, blue: 0.812)
        case .pink :
            return Color(red: 0.933, green: 0.82, blue: 0.914)
        case .purple :
            return Color(red: 0.8, green: 0.776, blue: 0.892)
        case .grey :
            return Color(red: 0.95, green: 0.928, blue: 0.906)
        case .navy :
            return Color(red: 0.737, green: 0.798, blue: 0.854)
        case .black :
            return Color(red: 0.833, green: 0.833, blue: 0.833)
        }
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
