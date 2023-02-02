//
//  CalendarBackgroundView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/01.
//

import SwiftUI
import CalendarUI

protocol AdditionViewPresentDelegate {
    func closeAdditionSheet()
    func openAdditionSheet()
}

struct MainView: View, MainTopViewDelegate {
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
        self.viewModel.openAdditionSheet()
    }
    
    private func detailScheduleBottomView() -> some View {
        return HalfSheet(content: { detent in
            DayScheduleListView(delegate: self.viewModel,
                                viewModel: self._viewModel,
                                schedules: self.viewModel.schedulesForSelectedDate,
                                detent: detent)
        })
    }
    
    private func scheduleAdditionModalView() -> some View {
        VStack {
            if let scheduleAdditionViewModel = self.viewModel.getScheduleAdditionViewModel() {
                ScheduleAdditionView(viewModel: scheduleAdditionViewModel, delegate: self.viewModel)
            } else {
                Text("")
            }
        }
    }
}

enum DCError: Error {
    static let title: String = "오류"
    
    case unknown, coreData(Error), network(URLResponse), urlError, requestError(Error), decodingError(Error)
    
    var message: String {
        switch self {
        case .unknown : return "알 수 없는 오류로 실패했습니다.\n재시도 해주세요."
        case .coreData : return "코어 데이터 접근에 실패했습니다.\n재시도 해주세요."
        case .network : return "네트워크 요청에 실패했습니다.\n관리자에게 문의해주세요."
        case .urlError : return "잘못된 URL입니다.\n관리자에게 문의해주세요."
        case .requestError : return "잘못된 요청입니다. \n관리자에게 문의해주세요."
        case .decodingError: return "서버 오류입니다. \n관리자에게 문의해주세요."
        }
    }
}
