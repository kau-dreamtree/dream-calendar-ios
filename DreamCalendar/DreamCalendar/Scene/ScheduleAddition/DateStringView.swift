//
//  DateStringView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/26.
//

import SwiftUI

struct DateStringView: View {
    
    private let setType: ScheduleAdditionView.SettingState
    private let title: String
    private(set) var time: TimeInfo
    private(set) var timeFieldIsNotPresented: Bool
    @Binding private(set) var actualDate: Date
    @Binding private(set) var additionState: ScheduleAdditionView.SettingState
    @State private var setting: SettingState = .none
    
    private let tintColor: Color
    
    private enum SettingState {
        case none, date, time
    }
    
    private struct Constraint {
        static let cornerRadius: CGFloat = 3
        static let width: CGFloat = 80
        static let height: CGFloat = 25
        static let backgroundColor: Color = .dateStringViewBackgroundGrey
    }
    
    init(type: ScheduleAdditionView.SettingState, title: String, defaultTime: TimeInfo, timeFieldIsNotPresented: Bool, date: Binding<Date>, additionState: Binding<ScheduleAdditionView.SettingState>, tintColor: Color) {
        self.setType = type
        self.title = title
        self.time = defaultTime
        self._actualDate = date
        self.timeFieldIsNotPresented = timeFieldIsNotPresented
        self._additionState = additionState
        self.tintColor = tintColor
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(self.title)
                    .foregroundColor(.black)
                    .font(.AppleSDRegular14)
                Spacer()
                VStack {
                    HStack {
                        dateField
                        if self.timeFieldIsNotPresented == false {
                            timeField
                        }
                    }
                }
            }
            switch (self.additionState == self.setType, self.setting) {
            case (true, .date) :    datePickerField
            case (true, .time) :    timePickerField
            default :               Text("").hidden()
            }
        }
    }
    
    @ViewBuilder
    private var dateField: some View {
        let date = "\(self.time.date.year).\(self.time.date.month).\(self.time.date.day)."
        
        ZStack {
            Color.dateButtonLightGray
                .ignoresSafeArea(.all)
            Text(date)
                .frame(alignment: .center)
                .font(.AppleSDRegular14)
                .foregroundColor(self.setting == .date && self.additionState == self.setType ? tintColor : .black)
        }
        .cornerRadius(Constraint.cornerRadius)
        .frame(width: Constraint.width, height: Constraint.height)
        .onTapGesture {
            self.additionState = self.setType
            switch self.setting {
            case .date :    self.setting = .none
            default :       self.setting = .date
            }
        }
    }
    
    @ViewBuilder
    private var timeField: some View {
        let time = String(format: "\(self.time.type.title) %d:%02d", self.time.hour, self.time.minute)
        
        ZStack {
            Color.dateButtonLightGray
                .ignoresSafeArea(.all)
            Text(time)
                .frame(alignment: .center)
                .font(.AppleSDRegular14)
                .foregroundColor(self.setting == .time && self.additionState == self.setType ? tintColor : .black)
        }
        .cornerRadius(Constraint.cornerRadius)
        .frame(width: Constraint.width, height: Constraint.height)
        .onTapGesture {
            self.additionState = self.setType
            switch self.setting {
            case .time :    self.setting = .none
            default :       self.setting = .time
            }
        }
    }
    
    @ViewBuilder
    private var datePickerField: some View {
        if #available(iOS 16.1, *) {
            DatePicker(
                "",
                selection: self.$actualDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(tintColor)
        } else {
            DatePicker(
                "",
                selection: self.$actualDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(tintColor)
        }
    }
    
    @ViewBuilder
    private var timePickerField: some View {
        DatePicker(
            "",
            selection: self.$actualDate,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.wheel)
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
    }
}

fileprivate extension Color {
    static let dateStringViewBackgroundGrey = Color(red: 0.933, green: 0.933, blue: 0.937)
}
