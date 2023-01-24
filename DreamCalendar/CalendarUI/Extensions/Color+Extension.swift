//
//  Color+Extension.swift
//  CalendarUI
//
//  Created by 이지수 on 2022/10/04.
//

import SwiftUI

extension Color {
    static var dayGray = Color(red: 0, green: 0, blue: 0, opacity: 0.28)
    static var dayBlack = Color(red: 0, green: 0, blue: 0, opacity: 0.78)
    static var shadowGray = Color(red: 0, green: 0, blue: 0, opacity: 0.1)
    static var dayBackgroundGray = Color(red: 0.962, green: 0.962, blue: 0.962, opacity: 1)
    static var red = Color(red: 0.817, green: 0, blue: 0)
}

extension Date {
    var dayColor: Color {
        switch self.weekday {
        case .sun:      return .dayGray
        default :       return .dayBlack
        }
    }
}
