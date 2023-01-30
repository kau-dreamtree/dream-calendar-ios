//
//  CalendarBackgroundView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/01.
//

import SwiftUI
import CalendarUI

protocol MainViewDelegate {
    func closeAdditionSheet()
    func openAdditionSheet()
}

struct MainView: View, MainViewDelegate, MainTopViewDelegate {
    @ObservedObject private var viewModel: MainViewModel
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let leadingTrailingPadding: CGFloat = 10
        static let bottomPadding: CGFloat = CalendarView.bottomViewHeight + 10
    }
    
    var body: some View {
        VStack(spacing: 0) {
            MainTopView(topTitle: self.viewModel.currentTopTitle,
                        delegate: self)
            CalendarView(defaultDate: self.viewModel.date,
                         selectedDate: self.$viewModel.selectedDate,
                         schedules: self.viewModel.schedules.map({$0.scheduleForUI}),
                         isShortMode: self.viewModel.isDetailMode)
            .padding(EdgeInsets(top: Constraint.zeroPadding,
                                leading: Constraint.leadingTrailingPadding,
                                bottom: self.viewModel.isDetailMode ? Constraint.bottomPadding : Constraint.zeroPadding,
                                trailing: Constraint.leadingTrailingPadding))
            .sheet(isPresented: self.$viewModel.isDetailMode,
                   content: self.detailScheduleBottomView)
            .sheet(isPresented: self.$viewModel.isWritingMode,
                   content: self.scheduleAdditionModalView)
            Spacer()
        }
    }
    
    var notNeedTodayButton: Bool {
        return self.viewModel.isToday
    }
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
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
        if self.viewModel.isDetailMode {
            self.viewModel.isDetailWritingMode = true
        } else {
            self.viewModel.isWritingMode = true
        }
    }
    
    private func detailScheduleBottomView() -> some View {
        return HalfSheet(content: { detent in
            DayScheduleListView(delegate: self,
                                viewModel: self._viewModel,
                                schedules: self.viewModel.schedulesForSelectedDate,
                                detent: detent)
        })
    }
    
    private func scheduleAdditionModalView() -> some View {
        VStack {
            if let scheduleAdditionViewModel = self.viewModel.getScheduleAdditionViewModel() {
                ScheduleAdditionInterfaceView(mainViewDelegate: self,
                                                      mainViewModel: self.viewModel,
                                                      scheduleAdditionViewModel: scheduleAdditionViewModel)
            } else {
                Text("")
            }
        }
    }
    
    func closeDetailSheet() {
        self.viewModel.isDetailMode = false
    }
    
    func closeAdditionSheet() {
        if self.viewModel.isDetailMode {
            self.viewModel.isDetailWritingMode = false
        } else {
            self.viewModel.isWritingMode = false
        }
    }
    
    func openDetailSheet() {
        self.viewModel.isDetailMode = true
    }
    
    func openAdditionSheet() {
        self.viewModel.isWritingMode = true
    }
}

enum DCError: Error {
    static let title: String = "오류"
    
    case unknown, coreData
    
    var message: String {
        switch self {
        case .unknown : return "알 수 없는 오류로 실패했습니다.\n재시도 해주세요."
        case .coreData : return "코어 데이터 접근에 실패했습니다.\n재시도 해주세요."
        }
    }
}
