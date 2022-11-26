//
//  DateStringView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/26.
//

import SwiftUI

struct DateStringView: View {
    private(set) var defaultTime: TimeInfo
    
    struct Constant {
        static let cornerRadius: CGFloat = 3
        static let width: CGFloat = 80
        static let height: CGFloat = 25
        static let backgroundColor: Color = .dateStringViewBackgroundGrey
    }
    
    init(defaultTime: TimeInfo) {
        self.defaultTime = defaultTime
    }
    
    var body: some View {
        HStack {
            dateField
            timeField
        }
    }
    
    @ViewBuilder
    var dateField: some View {
        let date = "\(self.defaultTime.date.year).\(self.defaultTime.date.month).\(self.defaultTime.date.day)."
        
        ZStack {
            Color.dateButtonLightGray
                .ignoresSafeArea(.all)
            Text(date)
                .frame(alignment: .center)
                .font(.AppleSDRegular14)
        }
        .cornerRadius(Constant.cornerRadius)
        .frame(width: Constant.width, height: Constant.height)
    }
    
    @ViewBuilder
    var timeField: some View {
        let time = "\(self.defaultTime.type.title) \(self.defaultTime.hour):00"
        
        ZStack {
            Color.dateButtonLightGray
                .ignoresSafeArea(.all)
            Text(time)
                .frame(alignment: .center)
                .font(.AppleSDRegular14)
        }
        .cornerRadius(Constant.cornerRadius)
        .frame(width: Constant.width, height: Constant.height)
    }
}

fileprivate extension Color {
    static let dateStringViewBackgroundGrey = Color(red: 0.933, green: 0.933, blue: 0.937)
}
