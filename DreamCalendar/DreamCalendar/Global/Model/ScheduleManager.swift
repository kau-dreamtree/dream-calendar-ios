//
//  ScheduleManager.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/31.
//

import CoreData

final class ScheduleManager {
    
    private let viewContext: NSManagedObjectContext
    private var scheduleAdditionViewModel: ScheduleAdditionViewModel? = nil
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    private func monthRangePredicate(withDate date: Date) -> NSPredicate {
        let firstDay = date.firstDayOfMonth
        let lastDay = Calendar.current.date(byAdding: .second,
                                            value: -1,
                                            to: firstDay.nextMonth) ?? Date.now
        
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
        let log = schedule.createLog(self.viewContext, type: .create)
        try self.viewContext.save()
        
        guard let accessToken = AccountManager.global.user.accessToken else { return }
        let apiInfo = DCAPI.Schedule.add(accessToken: accessToken,
                                         title: schedule.title,
                                         tag: Int(schedule.tag.id),
                                         isAllDay: schedule.isAllDay,
                                         startDate: schedule.startTime,
                                         endDate: schedule.endTime)
        try self.request(apiInfo, updatedSchedule: schedule, withLog: log)
    }
    
    func modifySchedule(_ schedule: Schedule) throws {
        let log = schedule.createLog(self.viewContext, type: .update)
        try self.viewContext.save()
        
        guard let accessToken = AccountManager.global.user.accessToken else { return }
        let apiInfo = DCAPI.Schedule.modify(accessToken: accessToken,
                                            serverId: schedule.serverId,
                                            title: schedule.title,
                                            tag: Int(schedule.tag.id),
                                            isAllDay: schedule.isAllDay,
                                            startDate: schedule.startTime,
                                            endDate: schedule.endTime)
        try self.request(apiInfo, updatedSchedule: schedule, withLog: log)
    }
    
    func deleteSchedule(_ schedule: Schedule) throws {
        let log = schedule.createLog(self.viewContext, type: .delete)
        schedule.isValid = false
        try self.viewContext.save()
        
        guard schedule.serverId != 0,
              let accessToken = AccountManager.global.user.accessToken else { return }
        let apiInfo = DCAPI.Schedule.delete(accessToken: accessToken,
                                            serverId: schedule.serverId,
                                            title: schedule.title,
                                            tag: Int(schedule.tag.id),
                                            isAllDay: schedule.isAllDay,
                                            startDate: schedule.startTime,
                                            endDate: schedule.endTime)
        try self.request(apiInfo, updatedSchedule: schedule, withLog: log)
    }
    
    private func request(_ apiInfo: APIInfo, updatedSchedule schedule: Schedule, withLog log: ScheduleUpdateLog) throws {
        do {
            Task {
                let (statusCode, data) = try await DCRequest().request(with: apiInfo)
                switch statusCode {
                case 200..<300 :
                    guard let response = try apiInfo.response(data) as? DCAPI.ScheduleResponse else { return }
                    schedule.serverId = response.id
                    self.viewContext.delete(log)
                    try self.viewContext.save()
                default :
                    return
                }
            }
        }
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
        schedule.tagId = TagManager.global.tagCollection.first?.id ?? Int16(TagType.babyBlue.rawValue)
        
        return schedule
    }
    
    private func fetchSchedule(withCurrentPage date: Date) throws -> [Schedule] {
        let request = Schedule.fetchRequest()
        request.predicate = self.monthRangePredicate(withDate: date)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true),
                                   NSSortDescriptor(key: "endTime", ascending: false)]
        return try self.viewContext.fetch(request).sorted()
    }
    
    func deleteAll() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = Schedule.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try self.viewContext.execute(deleteRequest)
    }
}

