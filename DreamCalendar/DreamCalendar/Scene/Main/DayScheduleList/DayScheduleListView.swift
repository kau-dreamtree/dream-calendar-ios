//
//  DayScheduleListView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/25.
//

import SwiftUI

struct DayScheduleListView: View {
    // TODO: ObservedObject 외 다른 방법 찾기
    @ObservedObject var viewModel: MainViewModel
    
    @Binding private(set) var date: Date
    @Binding private(set) var schedules: [Schedule]
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let topPadding: CGFloat = 40
        
        static let blockLeadingTrailingPadding: CGFloat = 20
        static let blockTopBottomPadding: CGFloat = 5
    }
    
    init(viewModel: MainViewModel, date: Binding<Date>, schedules: Binding<[Schedule]>) {
        self.viewModel = viewModel
        self._date = date
        self._schedules = schedules
    }
    
    var body: some View {
        List {
            ForEach(self.schedules) { schedule in
                ScheduleDetailBlock(schedule: schedule)
                    .listRowInsets(EdgeInsets(top: Constraint.blockTopBottomPadding,
                                              leading: Constraint.blockLeadingTrailingPadding,
                                              bottom: Constraint.blockTopBottomPadding,
                                              trailing: Constraint.blockLeadingTrailingPadding))
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .padding(EdgeInsets(top: Constraint.topPadding,
                            leading: Constraint.zeroPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.zeroPadding))
    }
}


struct ScheduleDetailBlock: View {
    
    let schedule: Schedule
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let bottomPadding: CGFloat = 10
        
        static let leftBarWidth: CGFloat = 2
        static let leftBarHeight: CGFloat = 38
        static let leftBarTextInterval: CGFloat = 10
        
        static let timeInfoHeight: CGFloat = 18
        static let shortTimeInfoWidth: CGFloat = 60
        static let longTimeInfoWidth: CGFloat = 115
    }
    
    var body: some View {
        HStack(spacing: Constraint.zeroPadding) {
            self.leftBar
            self.title
            self.timeInfo
        }
    }
    
    private var leftBar: some View {
        Rectangle()
            .frame(width: Constraint.leftBarWidth, height: Constraint.leftBarHeight)
            .foregroundColor(self.schedule.tagType.color)
            .padding(EdgeInsets(top: Constraint.zeroPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.leftBarTextInterval))
    }
    
    private var title: some View {
        Text(self.schedule.title)
            .font(.AppleSDBold14)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeInfo: some View {
        VStack(alignment: .trailing, spacing: Constraint.zeroPadding) {
            Text(self.schedule.startTime.toString(with: self.schedule.endTime))
                .font(.AppleSDMedium12)
                .foregroundColor(.black)
                .frame(height: Constraint.timeInfoHeight)
            Text(self.schedule.endTime.toString(with: self.schedule.startTime))
                .font(.AppleSDMedium12)
                .foregroundColor(.black)
                .frame(height: Constraint.timeInfoHeight)
        }
        .frame(width: self.schedule.needToDisplayDate ? Constraint.longTimeInfoWidth : Constraint.shortTimeInfoWidth)
    }
}

fileprivate extension Schedule {
    var needToDisplayDate: Bool {
        return self.startTime.isSameDay(with: self.endTime) == false
    }
}
