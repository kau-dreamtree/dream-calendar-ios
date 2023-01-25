//
//  CalendarBackgroundView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2022/11/01.
//

import SwiftUI
import CalendarUI

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
                   content: self.presentDetailScheduleBottomView)
            .sheet(isPresented: self.$viewModel.isWritingMode,
                   content: presentScheduleAdditionModalView)
            Spacer()
        }
        .onAppear(perform: {
            if self.viewModel.mode == .detail {
                self.openDetailSheet()
            }
        })
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
        self.viewModel.changeMode(.addition)
        if self.viewModel.isDetailMode {
            self.closeAllSheet()
        } else {
            self.openAdditionSheet()
        }
    }
    
    private func presentDetailScheduleBottomView() -> some View {
        return HalfSheet(content: {
            DayScheduleListView(viewModel: self.viewModel,
                                date: self.$viewModel.selectedDate,
                                schedules: self.$viewModel.schedulesForSelectedDate)
        })
        .onAppear(perform: {
            self.viewModel.changeMode(.detail)
        })
        .onDisappear(perform: {
            if self.viewModel.mode == .addition {
                self.openAdditionSheet()
                self.viewModel.changeMode(.detail)
            }
        })
    }
    
    private func presentScheduleAdditionModalView() -> some View {
        
        let closeButtonTitle = "닫기"
        let completeButtonTitle = "완료"
        
        return NavigationView {
            if let viewModel = self.viewModel.getScheduleAdditionViewModel() {
                ScheduleAdditionView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(closeButtonTitle) {
                                self.closeScheduleAdditionButtonDidTouched()
                            }
                            .foregroundColor(TagType.babyBlue.color)
                            .font(.AppleSDSemiBold14)
                        }
                        ToolbarItem(placement: .destructiveAction) {
                            Button(completeButtonTitle) {
                                self.uploadScheduleButtionDidTouched()
                            }
                            .foregroundColor(TagType.babyBlue.color)
                            .font(.AppleSDSemiBold14)
                        }
                    }
            } else {
                Text("")
            }
        }
        .alert(DCError.title, isPresented: self.$viewModel.isShowAlert) {
            Button("확인") {
                self.viewModel.changeMode(.main)
                self.closeAllSheet()
                self.viewModel.removeScheduleAdditionViewModel()
                self.viewModel.changeError()
            }
        } message : {
            Text((self.viewModel.error as? DCError)?.message ?? Alert.failMessage)
        }
        .onDisappear(perform: {
            switch self.viewModel.mode {
            case .detail :  self.openDetailSheet()
            default :       self.viewModel.changeMode(.main)
            }
        })
    }
    
    private func closeScheduleAdditionButtonDidTouched() {
        guard let schedule = self.viewModel.scheduleAdditionViewModel?.schedule else {
            self.viewModel.changeMode(.main)
            self.closeAllSheet()
            return
        }
        self.viewModel.removeScheduleAdditionViewModel()
        self.viewModel.cancelScheduleAddition(schedule)
        self.closeAllSheet()
    }
    
    private func uploadScheduleButtionDidTouched() {
        guard let schedule = self.viewModel.scheduleAdditionViewModel?.schedule else {
            self.viewModel.changeError(DCError.unknown)
            return
        }
        self.viewModel.removeScheduleAdditionViewModel()
        self.viewModel.addSchedule(schedule)
        self.closeAllSheet()
    }
    
    private func closeAllSheet() {
        self.viewModel.isWritingMode = false
        self.viewModel.isDetailMode = false
    }
    
    private func openDetailSheet() {
        self.viewModel.isDetailMode = true
    }
    
    private func openAdditionSheet() {
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
