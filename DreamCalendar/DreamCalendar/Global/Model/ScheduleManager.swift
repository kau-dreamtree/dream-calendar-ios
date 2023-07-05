//
//  ScheduleManager.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/31.
//

import CoreData
import Combine

final class ScheduleManager {
    
    private let viewContext: NSManagedObjectContext
    private var scheduleAdditionViewModel: ScheduleAdditionViewModel?
    @Published private var localCommitLog: [ScheduleUpdateLog]
    private var cancellable: AnyCancellable?
    
    private var networkManager: NetworkManager?
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.scheduleAdditionViewModel = nil
        self.networkManager = nil
        self.localCommitLog = []
        
        self.cancellable = self.$localCommitLog
            .dropFirst(2)
            .sink(receiveValue: { [weak self] logs in
                guard logs.isEmpty == false ,
                      let accessToken = AccountManager.global.user.accessToken,
                      let self = self else { return }
                Task {
                    try await self.pushLocalCommitLog(logs, withAccessToken: accessToken)
                    self.refreshLocalCommitLogs()
                }
            })
        
        let request = ScheduleUpdateLog.fetchRequest()
        self.localCommitLog = ((try? self.viewContext.fetch(request)) ?? []).sorted(by: { $0.createdDate < $1.createdDate })
        
        self.networkManager = NetworkManager() { [weak self] path in
            guard path.status == .satisfied,
                  let accessToken = AccountManager.global.user.accessToken,
                  let self = self,
                  self.localCommitLog.isEmpty == false else { return }
            Task {
                try await self.pushLocalCommitLog(self.localCommitLog, withAccessToken: accessToken)
                self.refreshLocalCommitLogs()
            }
        }
        self.networkManager?.startMonitoring()
    }
    
    deinit {
        self.networkManager?.stopMonitoring()
        self.networkManager = nil
    }
    
    private func refreshLocalCommitLogs() {
        let request = ScheduleUpdateLog.fetchRequest()
        self.localCommitLog = ((try? self.viewContext.fetch(request)) ?? []).sorted(by: { $0.createdDate < $1.createdDate })
    }
    
    private func pushLocalCommitLog(_ localCommitLogs: [ScheduleUpdateLog], withAccessToken accessToken: String) async throws {
        for log in localCommitLogs {
            guard let logType = UpdateLogType(rawValue: Int(log.type)) else { continue }
            let apiInfo: DCAPI.Schedule
            switch logType {
            case .create :
                apiInfo = DCAPI.Schedule.add(accessToken: accessToken,
                                             title: log.schedule.title,
                                             tag: Int(log.schedule.tag.id),
                                             isAllDay: log.schedule.isAllDay,
                                             startDate: log.schedule.startTime,
                                             endDate: log.schedule.endTime)
            case .delete :
                apiInfo = DCAPI.Schedule.delete(accessToken: accessToken, serverId: log.schedule.serverId)
            case .update :
                apiInfo = DCAPI.Schedule.modify(accessToken: accessToken,
                                                serverId: log.schedule.serverId,
                                                title: log.schedule.title,tag: Int(log.schedule.tag.id),
                                                isAllDay: log.schedule.isAllDay,
                                                startDate: log.schedule.startTime,
                                                endDate: log.schedule.endTime)
            }
            do {
                try await self.requestBy(log: log, with: apiInfo)
            } catch {
                break
            }
        }
        try self.viewContext.save()
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
            let schedule = self.getNewSchedule(in: date)
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
    
    func addSchedule(_ schedule: Schedule) async throws {
        let log = schedule.createLog(self.viewContext, type: .create)
        try self.viewContext.save()
        self.localCommitLog.append(log)
    }
    
    func modifySchedule(_ schedule: Schedule) async throws {
        let log = schedule.createLog(self.viewContext, type: .update)
        try self.viewContext.save()
        self.localCommitLog.append(log)
    }
    
    func deleteSchedule(_ schedule: Schedule) async throws {
        schedule.isValid = false
        let log = schedule.createLog(self.viewContext, type: .delete)
        try self.viewContext.save()
        self.localCommitLog.append(log)
    }
    
    private func requestBy(log: ScheduleUpdateLog, with apiInfo: APIInfo) async throws {
        let (statusCode, data) = try await DCRequest().request(with: apiInfo)
        switch statusCode {
        case 200..<300 :
            if let response = try? apiInfo.response(data) as? DCAPI.ScheduleResponse,
               log.schedule.serverId == 0 {
                log.schedule.serverId = response.id
            }
            self.viewContext.delete(log)
        case 500..<600 :
            throw DCError.serverError
        default :
            throw DCError.unknown
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
        deleteRequest.resultType = .resultTypeObjectIDs
        
        let batchDelete = try self.viewContext.execute(deleteRequest) as? NSBatchDeleteResult
        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { throw DCError.batchError }
        let deletedObjects: [AnyHashable: Any] = [ NSDeletedObjectsKey: deleteResult ]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [self.viewContext])
        
        let logRequest: NSFetchRequest<NSFetchRequestResult> = ScheduleUpdateLog.fetchRequest()
        let logDeleteRequest = NSBatchDeleteRequest(fetchRequest: logRequest)
        logDeleteRequest.resultType = .resultTypeObjectIDs
        
        let logBatchDelete = try self.viewContext.execute(logDeleteRequest) as? NSBatchDeleteResult
        guard let logDeleteResult = logBatchDelete?.result as? [NSManagedObjectID] else { throw DCError.batchError }
        let logDeletedObjects: [AnyHashable: Any] = [ NSDeletedObjectsKey: logDeleteResult ]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: logDeletedObjects, into: [self.viewContext])
        
        self.localCommitLog = []
    }
    
    func fetchAll() async throws -> Bool {
        guard let accessToken = AccountManager.global.user.accessToken else { throw DCError.accountError }
        let apiInfo = DCAPI.Schedule.schedules(accessToken: accessToken)
        let (statusCode, data) = try await DCRequest().request(with: apiInfo)
        switch statusCode {
        case 200..<300 :
            guard let response = try apiInfo.response(data) as? [DCAPI.ScheduleResponse] else { throw DCError.decodingError(data) }
            try response.forEach() { schedule in
                guard let startDate = schedule.start_at?.serverDate,
                      let endDate = schedule.end_at?.serverDate else { throw DCError.decodingError(data) }
                let newSchedule = Schedule(context: self.viewContext)
                newSchedule.id = UUID()
                newSchedule.title = schedule.title
                newSchedule.isAllDay = schedule.is_all_day
                newSchedule.startTime = startDate
                newSchedule.endTime = endDate
                newSchedule.tagId = Int16(schedule.tag)
                newSchedule.isValid = true
                newSchedule.serverId = schedule.id
            }
            try self.viewContext.save()
            return true
        default :
            return false
        }
    }
}

fileprivate extension String {
    static let serverDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    var serverDate: Date? {
        return Self.serverDateFormatter.date(from: self)
    }
}


//MARK: NetworkManager
import Network

fileprivate final class NetworkManager {
    private let monitor: NWPathMonitor
    private(set) var isConnected: Bool = false
    
    init(_ handler: @escaping (NWPath) -> Void) {
        self.monitor = NWPathMonitor()
        self.monitor.pathUpdateHandler = handler
    }

    public func startMonitoring() {
        self.monitor.start(queue: DispatchQueue.global())
    }

    public func stopMonitoring() {
        self.monitor.cancel()
    }
}
