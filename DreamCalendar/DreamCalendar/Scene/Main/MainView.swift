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
    @State private var calendarViewIndex: CGFloat = 2
    @State private var isSettingMode: Bool = false
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let leadingTrailingPadding: CGFloat = 10
        static let bottomPadding: CGFloat = CalendarView.bottomViewHeight + 10
    }
    
    var body: some View {
        MainTopView(topTitle: self.viewModel.currentTopTitle,
                    delegate: self)
        .allowsHitTesting(self.viewModel.isDetailMode == false)
        .contentShape(Rectangle())
        .onTapGesture {
            self.didTopViewTouched()
        }
        self.pagableCalendarView
            .sheet(isPresented: self.$viewModel.isDetailMode,
                   content: self.detailScheduleBottomView)
            .sheet(isPresented: self.$viewModel.isWritingMode,
                   content: self.scheduleAdditionModalView)
            .fullScreenCover(isPresented: self.$isSettingMode) {
                SettingsView(isOpen: self.$isSettingMode,
                             scheduleManager: self.viewModel.scheduleManager)
            }
    }
    
    private var pagableCalendarView: some View {
        GeometryReader { proxy in
            LazyHStack(spacing: Constraint.zeroPadding) {
                ForEach(self.viewModel.scheduleCollection, id: \.date) { date, schedules in
                    self.calendarView(with: schedules, at: date)
                        .frame(width: proxy.size.width)
                }
            }
            .offset(x: -self.calendarViewIndex * proxy.size.width)
            .gesture(DragGesture(minimumDistance: Constraint.zeroPadding, coordinateSpace: .global)
                .onChanged { value in
                    self.calendarViewIndex = CGFloat(MainViewModel.centerIndex) - (value.translation.width / proxy.size.width)
                }
                .onEnded { value in
                    if abs(value.translation.width) >= proxy.size.width / 2 {
                        let addition = value.translation.width > 0 ? 0 : +1
                        self.calendarViewIndex = CGFloat((Int(self.calendarViewIndex) + addition))
                    } else {
                        self.calendarViewIndex = CGFloat(Int(self.calendarViewIndex))
                    }
                    self.viewModel.changeIndex(Int(self.calendarViewIndex))
                    self.calendarViewIndex = CGFloat(MainViewModel.centerIndex)
                })
        }
    }
    
    @ViewBuilder
    private func calendarView(with schedules: [Schedule], at date: Date) -> some View {
        VStack(spacing: Constraint.zeroPadding) {
            CalendarView(defaultDate: date,
                         selectedDate: self.$viewModel.selectedDate,
                         schedules: schedules.map({$0.scheduleForUI}),
                         isShortMode: self.viewModel.isDetailMode)
            Spacer()
        }
        .padding(EdgeInsets(top: Constraint.zeroPadding,
                            leading: Constraint.leadingTrailingPadding,
                            bottom: self.viewModel.isDetailMode ? Constraint.bottomPadding : Constraint.zeroPadding,
                            trailing: Constraint.leadingTrailingPadding))
    }
    
    var notNeedTodayButton: Bool {
        return self.viewModel.isToday
    }
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    func settingsButtonDidTouched() {
        self.isSettingMode = true
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
    
    func didTopViewTouched() {
        switch self.viewModel.isDetailMode {
        case true :
            self.viewModel.closeDetailSheet()
        case false :
            break
        }
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
            ScheduleAdditionView(viewModel: self.viewModel.getScheduleAdditionViewModel(), delegate: self.viewModel)
        }
    }
}

enum DCError: Error {
    static let title: String = "오류"
    
    case unknown, coreData(Error), network(URLResponse), urlError, requestError(Error), decodingError(Error), serverError, accountError
    
    var message: String {
        switch self {
        case .unknown : return "알 수 없는 오류로 실패했습니다.\n재시도 해주세요."
        case .coreData : return "코어 데이터 접근에 실패했습니다.\n재시도 해주세요."
        case .network : return "네트워크 요청에 실패했습니다.\n네트워크 환경을 확인해주세요."
        case .urlError : return "잘못된 URL입니다.\n관리자에게 문의해주세요."
        case .requestError : return "잘못된 요청입니다. \n관리자에게 문의해주세요."
        case .decodingError: return "서버 오류입니다. \n관리자에게 문의해주세요."
        case .serverError: return "서버 오류입니다. \n관리자에게 문의해주세요."
        case .accountError: return "계정 정보 오류입니다. \n재접속 해주세요."
        }
    }
}
