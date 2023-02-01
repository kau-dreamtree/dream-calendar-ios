//
//  UIScreen+Extension.swift
//  CalendarUI
//
//  Created by 이지수 on 2023/01/24.
//

import SwiftUI

extension UIScreen{
    static var screenHeight: CGFloat {
        let safeAreaInsets = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets
        return UIScreen.main.bounds.height - (safeAreaInsets?.bottom ?? 0) - (safeAreaInsets?.top ?? 0)
    }
}
