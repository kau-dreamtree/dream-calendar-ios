//
//  MainTopMiddleView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import SwiftUI

protocol MainTopMiddleViewDelegate {
    func previousButtonDidTouched()
    func nextButtonDidTouched()
}

struct MainMiddleView: View {
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        
        static let previousButtonName: String = "chevron.left"
        static let nextButtonName: String = "chevron.right"
        static let buttonForegroundColor: Color = .buttonLightGray
        
        static let titleWidth: CGFloat = 86
        static let titleHeight: CGFloat = 27
        static let titleLeadingTrailingPadding: CGFloat = 16
    }
    
    private let topTitle: String
    private let delegate: MainTopMiddleViewDelegate
    
    init(topTitle: String, delegate: MainTopMiddleViewDelegate) {
        self.topTitle = topTitle
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: Constraint.zeroPadding) {
            Button {
                delegate.previousButtonDidTouched()
            } label : {
                Image(systemName: Constraint.previousButtonName)
                    .foregroundColor(Constraint.buttonForegroundColor)
            }
            Text(self.topTitle)
                .frame(width: Constraint.titleWidth, height: Constraint.titleHeight)
                .font(.AppleSDBold16)
                .padding(EdgeInsets(top: Constraint.zeroPadding,
                                    leading: Constraint.titleLeadingTrailingPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.titleLeadingTrailingPadding))
            Button {
                delegate.nextButtonDidTouched()
            } label : {
                Image(systemName: Constraint.nextButtonName)
                    .foregroundColor(Constraint.buttonForegroundColor)
            }
        }
    }
}
