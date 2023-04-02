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

struct TagBlock: View {
    
    enum BlockType {
        case normal, edit
    }
    
    private struct Constraint {
        static let circleWidthHeight: CGFloat = 14
        static let textHeight: CGFloat = 17
        static let height: CGFloat = 30
        
        static let zeroPadding: CGFloat = 0
        static let leadingTrailingPadding: CGFloat = 15
        
        static let orderEditImageName: String = "line.3.horizontal"
    }
    
    @State var tag: Tag
    let type: BlockType
    
    init(tag: Tag, type: BlockType = .normal) {
        self.tag = tag
        self.type = type
    }
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: Constraint.circleWidthHeight, height: Constraint.circleWidthHeight)
                .foregroundColor(tag.type.color)
            switch self.type {
            case .normal :
                Text(tag.title)
                    .foregroundColor(.black)
                    .font(.AppleSDRegular14)
            case .edit :
                TextField(tag.title, text: self.$tag.title)
                    .foregroundColor(.black)
                    .font(.AppleSDRegular14)
            }
            
            Spacer()
            switch self.type {
            case .normal :
                Text(tag.type.defaultTitle)
                    .frame(height: Constraint.textHeight)
                    .foregroundColor(.tagTitleGray)
                    .font(.AppleSDRegular14)
            case .edit :
                Image(systemName: Constraint.orderEditImageName)
                    .foregroundColor(.tagTitleGray)
                    .frame(height: Constraint.textHeight)
            }
            
        }
        .padding(EdgeInsets(top: Constraint.zeroPadding,
                            leading: Constraint.leadingTrailingPadding,
                            bottom: Constraint.zeroPadding,
                            trailing: Constraint.leadingTrailingPadding))
        .frame(maxHeight: .infinity)
    }
}
