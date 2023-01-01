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
    @State private var scheduleAdditionViewIsPresented: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            MainTopView(topTitle: self.viewModel.currentTopTitle,
                        delegate: self)
            CalendarView(date: self.viewModel.selectedDate,
                         schedules: self.viewModel.schedules.map({$0.scheduleForUI}))
            .sheet(isPresented: $scheduleAdditionViewIsPresented,
                   content: presentScheduleAdditionModalView)
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
        self.scheduleAdditionViewIsPresented.toggle()
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
                                self.closeSchduleAdditionButtonDidTouched()
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
                self.scheduleAdditionViewIsPresented.toggle()
                self.viewModel.removeScheduleAdditionViewModel()
                self.viewModel.changeError()
            }
        } message : {
            Text((self.viewModel.error as? DCError)?.message ?? Alert.failMessage)
        }
    }
    
    private func closeSchduleAdditionButtonDidTouched() {
        if let schedule = self.viewModel.scheduleAdditionViewModel?.schedule {
            self.viewModel.cancelScheduleAddition(schedule)
        }
        self.scheduleAdditionViewIsPresented.toggle()
        self.viewModel.removeScheduleAdditionViewModel()
    }
    
    private func uploadScheduleButtionDidTouched() {
        guard let schedule = self.viewModel.scheduleAdditionViewModel?.schedule else {
            self.viewModel.changeError(DCError.unknown)
            return
        }
        self.scheduleAdditionViewIsPresented.toggle()
        self.viewModel.removeScheduleAdditionViewModel()
        self.viewModel.addSchedule(schedule)
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
