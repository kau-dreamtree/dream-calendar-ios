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
    let delegate: AdditionViewPresentDelegate
    
    enum SettingState {
        case none, startDate, endDate, tag
    }
    
    private struct Constraint {
        static let closeButtonTitle = "닫기"
        static let completeButtonTitle = "완료"
        
        static let okButtonTitle = "확인"
        
        static let bottomInputViewPadding: CGFloat = 10
    }
    
    init(viewModel: ScheduleAdditionViewModel, delegate: AdditionViewPresentDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.additionViewBackgroundGray
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    ScheduleAdditionTitleInputView(schedule: self.$viewModel.schedule)
                    Divider()
                    ScheduleAdditionBottomInputView(viewModel: self.viewModel,
                                                    schedule: self.$viewModel.schedule,
                                                    additionState: self.$setting,
                                                    defaultStartTime: self.viewModel.defaultStartTime,
                                                    defaultEndTime: self.viewModel.defaultEndTime)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Constraint.closeButtonTitle) {
                        self.viewModel.closeScheduleButtonDidTouched()
                    }
                    .foregroundColor(self.viewModel.schedule.tagType.color)
                    .font(.AppleSDSemiBold14)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(Constraint.completeButtonTitle) {
                        self.viewModel.uploadScheduleButtonDidTouched()
                    }
                    .foregroundColor(self.viewModel.schedule.tagType.color)
                    .font(.AppleSDSemiBold14)
                }
            }
        }
    }
}

struct ScheduleAdditionTitleInputView: View {
    @Binding private(set) var schedule: Schedule
    
    private struct Constraint {
        static let topPadding: CGFloat = 40
        static let leadingPadding: CGFloat = 30
        static let bottomPadding: CGFloat = 30
        static let trailingPadding: CGFloat = 30
    }
    
    var body: some View {
        TextField("제목", text: self.$schedule.title)
            .font(.AppleSDBold16)
            .padding(EdgeInsets(top: Constraint.topPadding,
                                leading: Constraint.leadingPadding,
                                bottom: Constraint.bottomPadding,
                                trailing: Constraint.trailingPadding))
    }
}

struct ScheduleAdditionBottomInputView: View {
    
    @Binding private(set) var schedule: Schedule
    @Binding private(set) var additionState: ScheduleAdditionView.SettingState
    @State private(set) var showTagPicker: Bool = false
    private let defaultStartTime: TimeInfo
    private let defaultEndTime: TimeInfo
    private let viewModel: ScheduleAdditionViewModel
    
    private struct Constraint {
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
        .padding(EdgeInsets(top: Constraint.innerTopBottomPadding,
                            leading: Constraint.innerLeadingTrailingPadding,
                            bottom: Constraint.innerTopBottomPadding,
                            trailing: Constraint.innerLeadingTrailingPadding))
        .background(.white)
        .cornerRadius(Constraint.cornerRadius)
        .padding(EdgeInsets(top: Constraint.outerPadding,
                            leading: Constraint.outerPadding,
                            bottom: Constraint.outerPadding,
                            trailing: Constraint.outerPadding))
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
        .padding(EdgeInsets(top: Constraint.blockTopBottomPadding,
                            leading: Constraint.blockLeadingTrailingPadding,
                            bottom: Constraint.blockTopBottomPadding,
                            trailing: Constraint.blockLeadingTrailingPadding))
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
        .frame(height: Constraint.height)
        .padding(EdgeInsets(top: Constraint.blockTopBottomPadding,
                            leading: Constraint.blockLeadingTrailingPadding,
                            bottom: Constraint.blockTopBottomPadding,
                            trailing: Constraint.blockLeadingTrailingPadding))
    }
    
    @ViewBuilder
    private var startTimeField: some View {
        let type: BlockFieldType = .startTime
        
        DateStringView(type: .startDate,
                       title: type.title,
                       defaultTime: self.defaultStartTime,
                       timeFieldIsNotPresented: self.schedule.isAllDay,
                       date: self._schedule.startTime,
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
                       timeFieldIsNotPresented: self.schedule.isAllDay,
                       date: self._schedule.endTime,
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
        
        VStack {
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
            .contentShape(Rectangle())
            .onTapGesture {
                self.additionState = .tag
                self.showTagPicker = true
            }
        }
        .sheet(isPresented: self.$showTagPicker) {
            TagPicker(tags: self.viewModel.tags,
                      selectedTagId: self.$schedule.tagId,
                      picking: self.$showTagPicker)
                .padding(.zero)
        }
    }
}
