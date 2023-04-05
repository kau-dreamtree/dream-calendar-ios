//
//  ScheduleDetailView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/30.
//

import SwiftUI

struct ScheduleDetailView: View {
    
    @ObservedObject private(set) var viewModel: ScheduleDetailViewModel
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let dividerTopPadding: CGFloat = 10
        static let dividerBottomPadding: CGFloat = 20
        
        static let leadingTrailingInterval: CGFloat = 20
        static let fieldInterval: CGFloat = 30
        static let fieldHeight: CGFloat = 17
        
        static let timeInfoInterval: CGFloat = 20
        static let circleTagTitleInterval: CGFloat = 5
        
        static let tagTitle: String = "태그"
        
        static let menuEditButtonTitle: String = "수정"
        static let menuDeleteButtonTitle: String = "삭제"
    }
    
    init(viewModel: ScheduleDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Divider()
                    .padding(EdgeInsets(top: Constraint.dividerTopPadding,
                                        leading: Constraint.zeroPadding,
                                        bottom: Constraint.dividerBottomPadding,
                                        trailing: Constraint.zeroPadding))
                VStack(spacing: Constraint.fieldInterval) {
                    self.timeInfo
                    self.tagInfo
                }
                .padding(EdgeInsets(top: Constraint.zeroPadding,
                                    leading: Constraint.leadingTrailingInterval,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.leadingTrailingInterval))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            self.viewModel.closeDetailView()
                        } label: {
                            Image(systemName: "arrow.backward")
                                .foregroundColor(.black)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        self.title
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Menu(content: {
                            Button(Constraint.menuEditButtonTitle) {
                                self.viewModel.openEditingView()
                            }
                            Button(Constraint.menuDeleteButtonTitle, role: .destructive) {
                                self.viewModel.deleteSchedule()
                            }
                        }, label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.black)
                        })
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: self.$viewModel.isEditingMode, content: self.scheduleAdditionModalView)
    }
    
    private var title: some View {
        HStack(alignment: .center, spacing: Constraint.zeroPadding) {
            Rectangle()
                .foregroundColor(self.viewModel.schedule.tagType.color)
                .frame(width: 2, height: 19)
                .padding(EdgeInsets(top: Constraint.zeroPadding,
                                    leading: Constraint.zeroPadding,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.circleTagTitleInterval))
            Text(self.viewModel.schedule.title)
                .font(.AppleSDBold16)
                .foregroundColor(.black)
                .padding(.zero)
                .frame(alignment: .center)
        }
    }
    
    private var timeInfo: some View {
        VStack(spacing: Constraint.timeInfoInterval) {
            HStack {
                Text(self.viewModel.startDateTitle)
                    .font(.AppleSDSemiBold14)
                    .foregroundColor(.black)
                    .frame(alignment: .leading)
                Spacer()
                Text(self.viewModel.startTimeTitle)
                    .font(.AppleSDSemiBold14)
                    .foregroundColor(.black)
                    .frame(alignment: .trailing)
            }
            HStack {
                Text(self.viewModel.endDateTitle)
                    .font(.AppleSDSemiBold14)
                    .foregroundColor(.timeGray)
                    .frame(alignment: .leading)
                Spacer()
                Text(self.viewModel.endTimeTitle)
                    .font(.AppleSDSemiBold14)
                    .foregroundColor(.timeGray)
                    .frame(alignment: .trailing)
            }
        }
    }
    
    private var tagInfo: some View {
        HStack {
            Text(Constraint.tagTitle)
                .font(.AppleSDRegular14)
                .foregroundColor(.black)
                .frame(alignment: .leading)
            Spacer()
            Circle()
                .foregroundColor(self.viewModel.schedule.tagType.color)
                .padding(.zero)
            Text(self.viewModel.schedule.tag.title)
                .font(.AppleSDRegular14)
                .foregroundColor(.tagTitleGray)
                .frame(alignment: .trailing)
                .padding(EdgeInsets(top: Constraint.zeroPadding,
                                    leading: Constraint.circleTagTitleInterval,
                                    bottom: Constraint.zeroPadding,
                                    trailing: Constraint.zeroPadding))
        }
        .frame(height: Constraint.fieldHeight)
    }
    
    private func scheduleAdditionModalView() -> some View {
        ScheduleAdditionView(viewModel: self.viewModel.getScheduleAdditionViewModel(),
                             delegate: self.viewModel.scheduleEditingDelegate)
    }
}

