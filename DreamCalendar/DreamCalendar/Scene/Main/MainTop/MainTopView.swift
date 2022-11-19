//
//  MainTopView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import SwiftUI

typealias MainTopViewDelegate = MainTopLeftViewDelegate & MainTopMiddleViewDelegate & MainTopRightViewDelegate

struct MainTopView: View {
    private let topTitle: String
    private let delegate: MainTopViewDelegate
    
    init(topTitle: String, delegate: MainTopViewDelegate) {
        self.topTitle = topTitle
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: 0) {
            MainTopLeftView(delegate: self.delegate)
            Spacer()
            MainMiddleView(topTitle: self.topTitle,
                           delegate: self.delegate)
            Spacer()
            MainTopRightView(delegate: self.delegate)
        }
        .frame(height: 27)
        .padding(EdgeInsets(top: 5, leading: 25, bottom: 20, trailing: 25))
    }
}
