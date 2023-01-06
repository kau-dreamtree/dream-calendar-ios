//
//  Tag+Extension.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/26.
//

import SwiftUI
import CalendarUI

extension TagType {
    var color: Color {
        return TagUI(rawValue: self.rawValue).color
    }
    
    var lightColor: Color {
        return TagUI(rawValue: self.rawValue).lightColor
    }
}
