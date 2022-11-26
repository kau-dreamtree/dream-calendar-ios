//
//  Date+Extension.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import Foundation

extension Date {
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
}
