//
//  SchduleAdditionView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import SwiftUI
import CalendarUI



struct ScheduleAdditionView: View {
    
    private let tag: TagInfo = (TagType.babyBlue, TagType.babyBlue.defaultTitle)
    
    @State private var title = ""
    @State private var isAllDay = false
    @State private var startDate: Date = TimeInfo.defaultTime(.start, date: Date()).toDate()
    @State private var endDate: Date = TimeInfo.defaultTime(.end, date: Date()).toDate()
    @State private var setting: SettingState = .none
    
    enum SettingState {
        case none, startDate, endDate, tag
    }
    
    private struct Constant {
        static let bottomInputViewPadding: CGFloat = 10
    }
    
    init(lastClickedDate date: Date) {
        self.startDate = TimeInfo.defaultTime(.start, date: date).toDate()
        self.endDate = TimeInfo.defaultTime(.end, date: date).toDate()
    }
    
    var body: some View {
        ZStack {
            Color.additionViewBackgroundGray
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ScheduleAdditionTitleInputView(title: self.$title, additionState: self.$setting)
                Divider()
                ScheduleAdditionBottomInputView(isAllDay: self.$isAllDay,
                                                startDate: self.$startDate,
                                                endDate: self.$endDate,
                                                additionState: self.$setting,
                                                defaultStartTime: self.startDate.toTimeInfo(),
                                                endTime: self.endDate.toTimeInfo(),
                                                tag: self.tag)
                Spacer()
            }
        }
    }
}

struct ScheduleAdditionTitleInputView: View {
    @Binding private(set) var title: String
    @Binding private(set) var additionState: ScheduleAdditionView.SettingState
    
    private struct Constant {
        static let topPadding: CGFloat = 40
        static let leadingPadding: CGFloat = 30
        static let bottomPadding: CGFloat = 30
        static let trailingPadding: CGFloat = 30
    }
    
    var body: some View {
        TextField("제목", text: self.$title)
            .font(.AppleSDBold16)
            .padding(EdgeInsets(top: Constant.topPadding,
                                leading: Constant.leadingPadding,
                                bottom: Constant.bottomPadding,
                                trailing: Constant.trailingPadding))
    }
}

struct ScheduleAdditionBottomInputView: View {
    
    @Binding private(set) var isAllDay: Bool
    @Binding private(set) var startDate: Date
    @Binding private(set) var endDate: Date
    @Binding private(set) var additionState: ScheduleAdditionView.SettingState
    @State private(set) var showStartDatePicker: Bool = false
    private let defaultStartTime: TimeInfo
    private let defaultEndTime: TimeInfo
    private let tag: TagInfo
    
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
    
    init(isAllDay: Binding<Bool>, startDate: Binding<Date>, endDate: Binding<Date>, additionState: Binding<ScheduleAdditionView.SettingState>, defaultStartTime startTime: TimeInfo, endTime: TimeInfo, tag: TagInfo) {
        self._isAllDay = isAllDay
        self._startDate = startDate
        self._endDate = endDate
        self._additionState = additionState
        
        self.defaultStartTime = startTime
        self.defaultEndTime = endTime
        self.tag = tag
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
            Toggle(type.title, isOn: $isAllDay)
                .onChange(of: isAllDay.self) { _ in
                    self.additionState = .none
                }
                .foregroundColor(.black)
                .font(.AppleSDRegular14)
                .tint(tag.type.color)
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
                       date: self._startDate,
                       additionState: self._additionState,
                       tintColor: tag.type.color)
            .foregroundColor(.black)
            .tint(tag.type.color)
    }
    
    @ViewBuilder
    private var endTimeField: some View {
        let type: BlockFieldType = .endTime
        
        DateStringView(type: .endDate,
                        title: type.title,
                       defaultTime: self.defaultEndTime,
                       date: self._endDate,
                       additionState: self._additionState,
                       tintColor: tag.type.color)
            .foregroundColor(.black)
            .tint(tag.type.color)
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
                .foregroundColor(self.tag.type.color)
            Text(self.tag.title)
                .frame(height: textHeight)
                .foregroundColor(.tagTitleGray)
                .font(.AppleSDRegular14)
        }
        .onTapGesture {
            self.additionState = .tag
        }
    }
}
