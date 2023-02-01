//
//  ScheduleDetailViewModel.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/01.
//

import Foundation

protocol ScheduleDetailViewDelegate {
    func closeDetailView()
}

final class ScheduleDetailViewModel: ObservableObject {
    @Published private(set) var schedule: Schedule
    private let scheduleManager: ScheduleManager
    private let date: Date
    private let delegate: ScheduleDetailViewDelegate
    let scheduleEditingDelegate: AdditionViewPresentDelegate & RefreshMainViewDelegate
    
    @Published var isEditingMode: Bool = false
    @Published private(set) var error: Error? = nil
    
    var startDateTitle: String {
        "\(self.schedule.startTime.year)년 \(self.schedule.startTime.toString()) (\(self.schedule.startTime.weekday))"
    }
    
    var endDateTitle: String {
        "\(self.schedule.endTime.year)년 \(self.schedule.endTime.toString()) (\(self.schedule.endTime.weekday))"
    }
    
    var startTimeTitle: String {
        guard self.schedule.isAllDay == false else {
            let allDayTitle: String = "종일"
            return allDayTitle
        }
        return self.schedule.startTime.timeToString()
    }
    
    var endTimeTitle: String {
        guard self.schedule.isAllDay == false else {
            let allDayTitle: String = "종일"
            return allDayTitle
        }
        return self.schedule.endTime.timeToString()
    }
    
    init(schedule: Schedule, scheduleManager: ScheduleManager, date: Date, delegate: ScheduleDetailViewDelegate, scheduleEditingDelegate: AdditionViewPresentDelegate & RefreshMainViewDelegate) {
        self.schedule = schedule
        self.scheduleManager = scheduleManager
        self.date = date
        self.delegate = delegate
        self.scheduleEditingDelegate = scheduleEditingDelegate
    }
    
    func closeDetailView() {
        self.delegate.closeDetailView()
    }
    
    func openEditingView() {
        self.isEditingMode = true
    }
    
    func deleteSchedule() {
        do {
            try self.scheduleManager.deleteSchedule(self.schedule)
            self.scheduleEditingDelegate.refreshMainViewSchedule()
            self.delegate.closeDetailView()
        } catch {
            self.error = error
        }
    }
    
    func getScheduleAdditionViewModel() -> ScheduleAdditionViewModel {
        return self.scheduleManager.getScheduleAdditionViewModel(withDate: self.date,
                                                                  schedule: self.schedule,
                                                                  mode: .modify,
                                                                  andDelegate: self.scheduleEditingDelegate)
    }
}

