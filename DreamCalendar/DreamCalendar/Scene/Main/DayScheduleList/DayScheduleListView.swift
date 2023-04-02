//
//  DayScheduleListView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/25.
//

import SwiftUI

struct DayScheduleListView: View, ScheduleDetailViewDelegate {
    
    // TODO: ObservedObject 외 다른 방법 찾기
    @ObservedObject private(set) var viewModel: MainViewModel
    private let delegate: AdditionViewPresentDelegate
    
    private(set) var date: Date
    private(set) var schedules: [Schedule]
    private let detent: HalfSheet<Self>.Detent
    
    @State private var selectedSchedule: Schedule? = nil
    
    private struct Constraint {
        static let titleTopPadding: CGFloat = 48
        static let writeButtonTopPadding: CGFloat = 50
        static let topMenuLeadingTrailingPadding: CGFloat = 30
        static let titleListInterval: CGFloat = 18
        
        static let zeroPadding: CGFloat = 0
        static let topPadding: CGFloat = 40
        
        static let blockLeadingTrailingPadding: CGFloat = 20
        static let blockTopBottomPadding: CGFloat = 5
    }
    
    init(delegate: AdditionViewPresentDelegate, viewModel: ObservedObject<MainViewModel>, schedules: [Schedule], detent: HalfSheet<Self>.Detent) {
        self.delegate = delegate
        self._viewModel = viewModel
        self.date = viewModel.wrappedValue.selectedDate
        self.schedules = schedules
        self.detent = detent
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if detent == .large {
                self.topMenu
            }
            self.scheduleList
        }
        .sheet(isPresented: self.$viewModel.isDetailWritingMode,
               content: self.scheduleAdditionModalView)
        .fullScreenCover(item: self.$selectedSchedule, content: self.detailView)
    }
    
    private var topMenu: some View {
        HStack(alignment: .center) {
            Text("\(self.date.toString()) \(self.date.weekday)요일")
                .font(.AppleSDBold20)
                .foregroundColor(.black)
                .padding(EdgeInsets(top: Constraint.titleTopPadding,
                                    leading: Constraint.topMenuLeadingTrailingPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.zeroPadding))
            Spacer()
            Button {
                self.writeButtonDidTouched()
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
            .padding(EdgeInsets(top: Constraint.writeButtonTopPadding,
                                leading: Constraint.zeroPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.topMenuLeadingTrailingPadding))
        }
    }
    
    private var scheduleList: some View {
        List {
            ForEach(self.schedules) { schedule in
                ScheduleDetailBlock(schedule: schedule)
                    .listRowInsets(EdgeInsets(top: Constraint.blockTopBottomPadding,
                                              leading: Constraint.blockLeadingTrailingPadding,
                                              bottom: Constraint.blockTopBottomPadding,
                                              trailing: Constraint.blockLeadingTrailingPadding))
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedSchedule = schedule
                    }
            }
        }
        .id(UUID()) // ForEach update를 위해 UUID 부여
        .listStyle(PlainListStyle())
        .padding(EdgeInsets(top: self.detent == .medium ? Constraint.topPadding : Constraint.titleListInterval,
                            leading: Constraint.zeroPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.zeroPadding))
    }
    
    private func scheduleAdditionModalView() -> some View {
        VStack {
            ScheduleAdditionView(viewModel: self.viewModel.getScheduleAdditionViewModel(),
                                 delegate: self.delegate)
        }
    }
    
    private func detailView(about schedule: Schedule) -> some View {
        return ScheduleDetailView(viewModel: self.viewModel.getDetailViewModel(about: schedule,
                                                                               with: self))
    }
    
    private func writeButtonDidTouched() {
        self.viewModel.isDetailWritingMode = true
    }
    
    func closeDetailView() {
        self.selectedSchedule = nil
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
        
        static let isAllDayTitle: String = "종일"
    }
    
    var body: some View {
        HStack(spacing: Constraint.zeroPadding) {
            self.leftBar
            self.title
            if self.schedule.isAllDay {
                self.allDayInfo
            } else {
                self.timeInfo
            }
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
    
    private var allDayInfo: some View {
        Text(Constraint.isAllDayTitle)
            .font(.AppleSDMedium12)
            .foregroundColor(.black)
            .frame(height: Constraint.timeInfoHeight, alignment: .trailing)
    }
    
    private var timeInfo: some View {
        VStack(spacing: Constraint.zeroPadding) {
            Text(self.schedule.startTime.toString(with: self.schedule.endTime))
                .font(.AppleSDMedium12)
                .foregroundColor(.black)
                .frame(height: Constraint.timeInfoHeight, alignment: .trailing)
            Text(self.schedule.endTime.toString(with: self.schedule.startTime))
                .font(.AppleSDMedium12)
                .foregroundColor(.timeGray)
                .frame(height: Constraint.timeInfoHeight, alignment: .trailing)
        }
        .frame(width: self.schedule.needToDisplayDate ? Constraint.longTimeInfoWidth : Constraint.shortTimeInfoWidth,
               alignment: .trailing)
    }
}

fileprivate extension Schedule {
    var needToDisplayDate: Bool {
        return self.startTime.isSameDay(with: self.endTime) == false
    }
}
