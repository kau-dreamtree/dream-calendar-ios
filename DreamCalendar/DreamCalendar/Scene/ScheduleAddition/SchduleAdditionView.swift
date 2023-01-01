//
//  SchduleAdditionView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import SwiftUI
import CalendarUI

struct ScheduleAdditionView: View {
    
    @ObservedObject private var viewModel: ScheduleAdditionViewModel
    @State private(set) var setting: SettingState = .none
    
    enum SettingState {
        case none, startDate, endDate, tag
    }
    
    private struct Constant {
        static let bottomInputViewPadding: CGFloat = 10
    }
    
    init(viewModel: ScheduleAdditionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.additionViewBackgroundGray
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ScheduleAdditionTitleInputView(schedule: self.$viewModel.schedule, additionState: self.$setting)
                Divider()
                ScheduleAdditionBottomInputView(viewModel: self.viewModel,
                                                schedule: self.$viewModel.schedule,
                                                additionState: self.$setting,
                                                defaultStartTime: self.viewModel.defaultStartTime,
                                                defaultEndTime: self.viewModel.defaultEndTime)
                Spacer()
            }
        }
    }
}

struct ScheduleAdditionTitleInputView: View {
    @Binding private(set) var schedule: Schedule
    @Binding private(set) var additionState: ScheduleAdditionView.SettingState
    
    private struct Constant {
        static let topPadding: CGFloat = 40
        static let leadingPadding: CGFloat = 30
        static let bottomPadding: CGFloat = 30
        static let trailingPadding: CGFloat = 30
    }
    
    var body: some View {
        TextField("제목", text: self.$schedule.title)
            .font(.AppleSDBold16)
            .padding(EdgeInsets(top: Constant.topPadding,
                                leading: Constant.leadingPadding,
                                bottom: Constant.bottomPadding,
                                trailing: Constant.trailingPadding))
    }
}

struct ScheduleAdditionBottomInputView: View {
    
    @Binding private(set) var schedule: Schedule
    @Binding private(set) var additionState: ScheduleAdditionView.SettingState
    @State private(set) var showStartDatePicker: Bool = false
    private let defaultStartTime: TimeInfo
    private let defaultEndTime: TimeInfo
    private let viewModel: ScheduleAdditionViewModel
    
    private struct Constant {
        static let cornerRadius: CGFloat = 30
        static let innerLeadingTrailingPadding: CGFloat = 20
        static let innerTopBottomPadding: CGFloat = 15
        static let outerPadding: CGFloat = 10
        static let height: CGFloat = 24
        static let blockTopBottomPadding: CGFloat = 15
        static let blockLeadingTrailingPadding: CGFloat = 0
    }
    
    enum BlockFieldType: String {
        case allDay, startTime, endTime, tag
        
        var title: String {
            switch self {
            case .allDay : return "종일"
            case .startTime : return "시작"
            case .endTime : return "종료"
            case .tag : return "태그"
            }
        }
    }
    
    init(viewModel: ScheduleAdditionViewModel, schedule: Binding<Schedule>, additionState: Binding<ScheduleAdditionView.SettingState>, defaultStartTime: TimeInfo, defaultEndTime: TimeInfo) {
        self.viewModel = viewModel
        self._schedule = schedule
        self._additionState = additionState
        self.defaultStartTime = defaultStartTime
        self.defaultEndTime = defaultEndTime
    }
    
    var body: some View {
        VStack {
            blockField(.allDay)
            blockField(.startTime)
            blockField(.endTime)
            blockField(.tag)
        }
        .padding(EdgeInsets(top: Constant.innerTopBottomPadding,
                            leading: Constant.innerLeadingTrailingPadding,
                            bottom: Constant.innerTopBottomPadding,
                            trailing: Constant.innerLeadingTrailingPadding))
        .background(.white)
        .cornerRadius(Constant.cornerRadius)
        .padding(EdgeInsets(top: Constant.outerPadding,
                            leading: Constant.outerPadding,
                            bottom: Constant.outerPadding,
                            trailing: Constant.outerPadding))
    }
    
    @ViewBuilder
    private func blockField(_ type: BlockFieldType) -> some View {
        HStack {
            switch type {
            case .allDay :      allDayField
            case .startTime :   startTimeField
            case .endTime :     endTimeField
            case .tag :         tagField
            }
        }
        .padding(EdgeInsets(top: Constant.blockTopBottomPadding,
                            leading: Constant.blockLeadingTrailingPadding,
                            bottom: Constant.blockTopBottomPadding,
                            trailing: Constant.blockLeadingTrailingPadding))
    }
    
    @ViewBuilder
    private var allDayField: some View {
        let type: BlockFieldType = .allDay
        
        HStack {
            Toggle(type.title, isOn: self.$schedule.isAllDay)
                .onChange(of: self.schedule.isAllDay) { _ in
                    self.additionState = .none
                }
                .foregroundColor(.black)
                .font(.AppleSDRegular14)
                .tint(self.schedule.tagType.color)
        }
        .frame(height: Constant.height)
        .padding(EdgeInsets(top: Constant.blockTopBottomPadding,
                            leading: Constant.blockLeadingTrailingPadding,
                            bottom: Constant.blockTopBottomPadding,
                            trailing: Constant.blockLeadingTrailingPadding))
    }
    
    @ViewBuilder
    private var startTimeField: some View {
        let type: BlockFieldType = .startTime
        
        DateStringView(type: .startDate,
                       title: type.title,
                       defaultTime: self.defaultStartTime,
                       date: self._schedule.startTime,
                       timeFieldIsNotPresented: self._schedule.isAllDay,
                       additionState: self._additionState,
                       tintColor: self.schedule.tagType.color)
            .foregroundColor(.black)
            .tint(self.schedule.tagType.color)
    }
    
    @ViewBuilder
    private var endTimeField: some View {
        let type: BlockFieldType = .endTime
        
        DateStringView(type: .endDate,
                        title: type.title,
                       defaultTime: self.defaultEndTime,
                       date: self._schedule.endTime,
                       timeFieldIsNotPresented: self._schedule.isAllDay,
                       additionState: self._additionState,
                       tintColor: self.schedule.tagType.color)
            .foregroundColor(.black)
            .tint(self.schedule.tagType.color)
    }
    
    @ViewBuilder
    private var tagField: some View {
        let type: BlockFieldType = .tag
        
        let circleWidthHeight: CGFloat = 14
        let textHeight: CGFloat = 17
        
        HStack {
            Text(type.title)
                .foregroundColor(.black)
                .font(.AppleSDRegular14)
            Spacer()
            Circle()
                .frame(width: circleWidthHeight, height: circleWidthHeight)
                .foregroundColor(self.schedule.tagType.color)
            Text(self.schedule.tag(context: self.viewModel.viewContext).title)
                .frame(height: textHeight)
                .foregroundColor(.tagTitleGray)
                .font(.AppleSDRegular14)
        }
        .onTapGesture {
            self.additionState = .tag
        }
    }
}
