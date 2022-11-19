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
}

struct MainTopLeftView: View {
    private let delegate: MainTopLeftViewDelegate
    
    init(delegate: MainTopLeftViewDelegate) {
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                //TODO: setting action 지정 필요
                print("settings button clicked")
            } label: {
                Image(systemName: "gearshape")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
            Button {
                delegate.todayButtonDidTouched()
            } label: {
                Image(systemName: "arrowshape.turn.up.backward")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
            .hidden(delegate.notNeedTodayButton)
        }
    }
}
