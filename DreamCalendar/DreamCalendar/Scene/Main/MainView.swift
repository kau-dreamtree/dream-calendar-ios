//
//  CalendarBackgroundView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/01.
//

import SwiftUI
import CalendarUI

struct MainView: View, MainTopViewDelegate {
    @State private var viewModel: MainViewModel = MainViewModel()
    @State private var isShowAlert: Bool = false
    @State private var error: Error? = nil
    @State private var scheduleAdditionViewIsPresented: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            MainTopView(topTitle: self.viewModel.currentTopTitle,
                        delegate: self)
            CalendarView(date: self.viewModel.selectedDate,
                         schedules: testSchedules)
            .sheet(isPresented: $scheduleAdditionViewIsPresented,
                   content: presentScheduleAdditionModalView)
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
    
    func searchButtonDidTouched() {
        print("search button clicked")
    }
    
    func writeButtonDidTouched() {
        self.scheduleAdditionViewIsPresented.toggle()
    }
    
    private func presentScheduleAdditionModalView() -> some View {
        
        let closeButtonTitle = "닫기"
        let completeButtonTitle = "완료"
        
        return NavigationView {
            ScheduleAdditionView(lastClickedDate: self.viewModel.selectedDate)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(closeButtonTitle) {
                            self.closeSchduleAdditionButtonDidTouched()
                        }
                        .foregroundColor(TagType.babyBlue.color)
                        .font(.AppleSDSemiBold14)
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button(completeButtonTitle) {
                            self.closeSchduleAdditionButtonDidTouched()
                        }
                        .foregroundColor(TagType.babyBlue.color)
                        .font(.AppleSDSemiBold14)
                    }
                }
        }
    }
    
    private func closeSchduleAdditionButtonDidTouched() {
        self.scheduleAdditionViewIsPresented.toggle()
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10))
    }
}
