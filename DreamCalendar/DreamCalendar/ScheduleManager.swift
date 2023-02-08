//
//  ScheduleManager.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/31.
//

import CoreData

final class ScheduleManager {
    
    let viewContext: NSManagedObjectContext
    private var scheduleAdditionViewModel: ScheduleAdditionViewModel? = nil
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    private func monthRangePredicate(withDate date: Date) -> NSPredicate {
        let firstDay = Calendar.current.date(from: DateComponents(
            calendar: Calendar.current,
            year: date.year,
            month: date.month,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            nanosecond: 0
        )) ?? Date.now
        
        let nextMonthFirstDay = Calendar.current.date(byAdding: .month,
                                                      value: +1,
                                                      to: firstDay) ?? Date.now
        
        let lastDay = Calendar.current.date(byAdding: .nanosecond,
                                            value: -1,
                                            to: nextMonthFirstDay) ?? Date.now
        
        let firstDayCVar = firstDay as CVarArg
        let lastDayCVar = lastDay as CVarArg
        
        return NSPredicate(format: "(%@ <= startTime AND startTime <= %@) OR (%@ <= endTime AND endTime <= %@) OR (startTime < %@ AND endTime > %@)", firstDayCVar, lastDayCVar, firstDayCVar, lastDayCVar, firstDayCVar, lastDayCVar)
    }
    
    func getScheduleAdditionViewModel(withDate date: Date, schedule: Schedule? = nil, mode: ScheduleAdditionViewModel.Mode = .create, andDelegate delegate: AdditionViewPresentDelegate & RefreshMainViewDelegate) -> ScheduleAdditionViewModel {
        let viewModel: ScheduleAdditionViewModel
        if let scheduleViewModel = self.scheduleAdditionViewModel {
            viewModel = scheduleViewModel
        } else if let schedule = schedule {
            viewModel = ScheduleAdditionViewModel(self,
                                                  delegate: delegate,
                                                  schedule: schedule,
                                                  mode: mode,
                                                  date: date)
        } else {
            let schedule = getNewSchedule(in: date)
            viewModel = ScheduleAdditionViewModel(self,
                                                  delegate: delegate,
                                                  schedule: schedule,
                                                  mode: mode,
                                                  date: date)
        }
        self.scheduleAdditionViewModel = viewModel
        return viewModel
    }
    
    func removeScheduleAdditionViewModel() {
        self.scheduleAdditionViewModel = nil
    }
    
    func cancelScheduleAddition(_ schedule: Schedule) throws {
        self.viewContext.delete(schedule)
        try self.viewContext.save()
    }
    
    func addSchedule(_ schedule: Schedule) throws {
        schedule.createLog(self.viewContext, type: .create)
        try self.viewContext.save()
    }
    
    func modifySchedule(_ schedule: Schedule) throws {
        schedule.createLog(self.viewContext, type: .update)
        try self.viewContext.save()
    }
    
    func deleteSchedule(_ schedule: Schedule) throws {
        schedule.createLog(self.viewContext, type: .delete)
        schedule.isValid = false
        try self.viewContext.save()
    }
    
    func getSchedule(in date: Date) throws -> [Schedule] {
        return try self.fetchSchedule(withCurrentPage: date)
    }
    
    private func getNewSchedule(in date: Date) -> Schedule {
        let startTime = TimeInfo.defaultTime(.start, date: date).toDate()
        let endTime = TimeInfo.defaultTime(.end, date: date).toDate()
        
        let schedule = Schedule(context: self.viewContext)
        schedule.id = UUID()
        schedule.title = ""
        schedule.isAllDay = false
        schedule.startTime = startTime
        schedule.endTime = endTime
        schedule.tagId = Int16(TagType.babyBlue.rawValue)
        return schedule
    }
    
    private func fetchSchedule(withCurrentPage date: Date) throws -> [Schedule] {
        let request = Schedule.fetchRequest()
        request.predicate = self.monthRangePredicate(withDate: date)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true),
                                   NSSortDescriptor(key: "endTime", ascending: false)]
        return try self.viewContext.fetch(request).sorted()
    }
}

