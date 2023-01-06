//
//  MainTopView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/07.
//

import SwiftUI

struct MainTopView: View {
    private let topTitle: String
    private let delegate: MainViewDelegate
    
    init(topTitle: String, delegate: MainViewDelegate) {
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
            MainTopRightView()
        }
        .frame(height: 27)
        .padding(EdgeInsets(top: 5, leading: 25, bottom: 20, trailing: 25))
    }
}

struct MainTopLeftView: View {
    private let delegate: MainViewDelegate
    
    init(delegate: MainViewDelegate) {
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

struct MainMiddleView: View {
    private let topTitle: String
    private let delegate: MainViewDelegate
    
    init(topTitle: String, delegate: MainViewDelegate) {
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

struct MainTopRightView: View {
    var body: some View {
        HStack(spacing: 15) {
            Button {
                //TODO: search action 지정 필요
                print("search button clicked")
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
            Button {
                //TODO: action 지정 필요
                print("write button clicked")
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.buttonGray)
            }
            .frame(height: 20)
        }
    }
}
