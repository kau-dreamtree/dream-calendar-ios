//
//  MainTopView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import SwiftUI

typealias MainTopViewDelegate = MainTopLeftViewDelegate & MainTopMiddleViewDelegate & MainTopRightViewDelegate

struct MainTopView: View {
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        
        static let height: CGFloat = 27
        static let leadingTrailingPadding: CGFloat = 25
        static let topPadding: CGFloat = 5
        static let bottomPadding: CGFloat = 20
    }
    
    private let topTitle: String
    private let delegate: MainTopViewDelegate
    
    init(topTitle: String, delegate: MainTopViewDelegate) {
        self.topTitle = topTitle
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: Constraint.zeroPadding) {
            MainTopLeftView(delegate: self.delegate)
            Spacer()
            MainMiddleView(topTitle: self.topTitle,
                           delegate: self.delegate)
            Spacer()
            MainTopRightView(delegate: self.delegate)
        }
        .frame(height: Constraint.height)
        .padding(EdgeInsets(top: Constraint.topPadding,
                            leading: Constraint.leadingTrailingPadding,
                            bottom: Constraint.bottomPadding,
                            trailing: Constraint.leadingTrailingPadding))
    }
}
