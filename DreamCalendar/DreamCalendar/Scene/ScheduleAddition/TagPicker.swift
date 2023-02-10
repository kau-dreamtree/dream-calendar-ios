//
//  TagPicker.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/02/05.
//

import SwiftUI

struct TagPicker: View {
    
    @Binding private var picking: Bool
    @Binding private var selectedTagId: Int16
    private var tags: [Tag]
    
    private struct Constraint {
        static let zeroPadding: CGFloat = 0
        static let topPadding: CGFloat = 20
    }
    
    private struct TagBlock: View {
        
        private struct Constraint {
            static let circleWidthHeight: CGFloat = 14
            static let textHeight: CGFloat = 17
            static let height: CGFloat = 30
            
            static let zeroPadding: CGFloat = 0
            static let leadingTrailingPadding: CGFloat = 15
        }
        
        let tag: Tag
        
        var body: some View {
            HStack {
                Circle()
                    .frame(width: Constraint.circleWidthHeight, height: Constraint.circleWidthHeight)
                    .foregroundColor(tag.type.color)
                Text(tag.title)
                    .foregroundColor(.black)
                    .font(.AppleSDRegular14)
                Spacer()
                Text(tag.type.defaultTitle)
                    .frame(height: Constraint.textHeight)
                    .foregroundColor(.tagTitleGray)
                    .font(.AppleSDRegular14)
            }
            .padding(EdgeInsets(top: Constraint.zeroPadding,
                                leading: Constraint.leadingTrailingPadding,
                                bottom: Constraint.zeroPadding,
                                trailing: Constraint.leadingTrailingPadding))
            .frame(maxHeight: .infinity)
        }
    }
    
    init(tags: [Tag], selectedTagId: Binding<Int16>, picking: Binding<Bool>) {
        self.tags = tags
        self._selectedTagId = selectedTagId
        self._picking = picking
    }
    
    var body: some View {
        List {
            ForEach(self.tags ) { tag in
                TagBlock(tag: tag)
                    .background(self.selectedTagId == tag.id ? Color.buttonLightGray : Color.white)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: Constraint.zeroPadding,
                                              leading: Constraint.zeroPadding,
                                              bottom: Constraint.zeroPadding,
                                              trailing: Constraint.zeroPadding))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedTagId = tag.id
                        self.picking = false
                    }
            }
        }
        .listStyle(PlainListStyle())
        .padding(EdgeInsets(top: Constraint.topPadding,
                            leading: Constraint.zeroPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.zeroPadding))
    }
}

