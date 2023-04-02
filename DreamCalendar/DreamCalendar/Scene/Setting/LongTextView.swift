//
//  LongTextView.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/04/02.
//

import SwiftUI

struct LongTextView: View {
    
    private let title: String
    private let content: String
    
    init(title: String, fileName: String) {
        self.title = title
        
        let errorMessage = "\(title)을 불러오는 중 오류가 발생하였습니다."
        do {
            guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
                self.content = errorMessage
                return
            }
            self.content = try String(contentsOf: fileUrl)
        } catch {
            self.content = errorMessage
        }
    }
    
    var body: some View {
        ScrollView {
            Text(self.content)
                .padding()
        }
    }
}
