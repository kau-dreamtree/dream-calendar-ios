//
//  CalendarBackgroundView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/01.
//

import SwiftUI
import CalendarUI

protocol MainViewDelegate {
    
    // Main Top Left View
    var notNeedTodayButton: Bool { get }
    func todayButtonDidTouched()
    
    // Main Top Middle View
    func previousButtonDidTouched()
    func nextButtonDidTouched()
    
    // Main Top Right View
}

struct MainView: View, MainViewDelegate {
    @State private var viewModel: MainViewModel = MainViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            MainTopView(topTitle: self.viewModel.currentTopTitle,
                        delegate: self)
            CalendarView(year: self.viewModel.currentYear,
                         month: self.viewModel.currentMonth)
        }
    }
    
    var notNeedTodayButton: Bool {
        return self.viewModel.isToday
    }
    
    func todayButtonDidTouched() {
        self.viewModel.goToToday()
    }
    
    func previousButtonDidTouched() {
        self.viewModel.goToPreviousMonth()
    }
    
    func nextButtonDidTouched() {
        self.viewModel.goToNextMonth()
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
    }
}
