//
//  View+Extension.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ value: Bool) -> some View {
        switch value {
        case true :     self.hidden()
        case false :    self
        }
    }
}

