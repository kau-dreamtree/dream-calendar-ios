//
//  SchduleAdditionView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import SwiftUI
import CalendarUI



struct ScheduleAdditionView: View {
    private var viewModel: ScheduleAdditionViewModel
    private let startTime: TimeInfo
    private let endTime: TimeInfo
    private let tag: TagInfo
    
    private struct Constant {
        static let bottomInputViewPadding: CGFloat = 10
    }
    
    init(lastClickedDate date: Date) {
        self.viewModel = ScheduleAdditionViewModel(date: date)
        self.startTime = self.viewModel.startTime
        self.endTime = self.viewModel.endTime
        self.tag = self.viewModel.tag
    }
    
    var body: some View {
        ZStack {
            Color.additionViewBackgroundGray
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ScheduleAdditionTitleInputView()
                Divider()
                ScheduleAdditionBottomInputView(defaultStartTime: self.startTime, endTime: self.endTime, tag: self.tag)
                Spacer()
            }
        }
    }
}

struct ScheduleAdditionTitleInputView: View {
    @State private(set) var title: String = ""
    
    private struct Constant {
        static let topPadding: CGFloat = 40
        static let leadingPadding: CGFloat = 30
        static let bottomPadding: CGFloat = 30
        static let trailingPadding: CGFloat = 30
    }
    
    var body: some View {
        TextField("제목", text: $title)
            .font(.AppleSDBold16)
            .padding(EdgeInsets(top: Constant.topPadding,
                                leading: Constant.leadingPadding,
                                bottom: Constant.bottomPadding,
                                trailing: Constant.trailingPadding))
    }
}

struct ScheduleAdditionBottomInputView: View {
    
    @State private(set) var isAllDay: Bool = false
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
    
    init(defaultStartTime startTime: TimeInfo, endTime: TimeInfo, tag: TagInfo) {
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
            case .allDay : allDayField
            case .startTime : startTimeField
            case .endTime : endTimeField
            case .tag : tagField
            }
        }.frame(height: Constant.height)
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
                .foregroundColor(.black)
                .font(.AppleSDRegular14)
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
        
        HStack {
            Text(type.title)
                .foregroundColor(.black)
                .font(.AppleSDRegular14)
            Spacer()
            DateStringView(defaultTime: self.defaultStartTime)
                .foregroundColor(.black)
        }
    }
    
    @ViewBuilder
    private var endTimeField: some View {
        let type: BlockFieldType = .endTime
        
        HStack {
            Text(type.title)
                .foregroundColor(.black)
                .font(.AppleSDRegular14)
            Spacer()
            DateStringView(defaultTime: self.defaultEndTime)
                .foregroundColor(.black)
        }
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
    }
}
