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
    private let topTitle: String
    private let delegate: MainTopMiddleViewDelegate
    
    init(topTitle: String, delegate: MainTopMiddleViewDelegate) {
        self.topTitle = topTitle
        self.delegate = delegate
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                delegate.previousButtonDidTouched()
            } label : {
                Image(systemName: "chevron.left")
                    .foregroundColor(.buttonLightGray)
            }
            Text(self.topTitle)
                .frame(width: 86, height: 27)
                .font(.AppleSDBold16)
                .padding(EdgeInsets(top: 0,
                                    leading: 16,
                                    bottom: 0,
                                    trailing: 16))
            Button {
                delegate.nextButtonDidTouched()
            } label : {
                Image(systemName: "chevron.right")
                    .foregroundColor(.buttonLightGray)
            }
        }
    }
}
