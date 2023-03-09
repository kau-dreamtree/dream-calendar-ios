//
//  MainTopLeftView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/19.
//

import SwiftUI

protocol MainTopLeftViewDelegate {
    var notNeedTodayButton: Bool { get }
    func todayButtonDidTouched()
    func settingsButtonDidTouched()
}

struct MainTopLeftView: View {
    
    private struct Constraint {
        static let spacingInterval: CGFloat = 15
        static let settingsButtonImageTitle: String = "gearshape"
        static let todayButtonImageTitle: String = "arrowshape.turn.up.backward"
        static let buttonHeight: CGFloat = 20
    }
    
    private let delegate: MainTopLeftViewDelegate
    
    init(delegate: MainTopLeftViewDelegate) {
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: Constraint.spacingInterval) {
            Button {
                delegate.settingsButtonDidTouched()
            } label: {
                Image(systemName: Constraint.settingsButtonImageTitle)
                    .foregroundColor(.buttonGray)
            }
            .frame(height: Constraint.buttonHeight)
            Button {
                delegate.todayButtonDidTouched()
            } label: {
                Image(systemName: Constraint.todayButtonImageTitle)
                    .foregroundColor(.buttonGray)
            }
            .frame(height: Constraint.buttonHeight)
            .hidden(delegate.notNeedTodayButton)
        }
    }
}
