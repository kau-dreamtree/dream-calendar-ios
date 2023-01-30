//
//  HalfSheetController.swift
//  DreamCalendar
//
//  Created by 이지수 on 2023/01/25.
//

import SwiftUI
import CalendarUI

final class HalfSheetController<Content>: UIHostingController<Content>, UISheetPresentationControllerDelegate where Content : View {
    
    @Binding private(set) var detent: HalfSheet<Content>.Detent
    
    init(rootView: Content, detent: Binding<HalfSheet<Content>.Detent>) {
        self._detent = detent
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        self._detent = State(initialValue: HalfSheet<Content>.Detent.medium).projectedValue
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let presentation = sheetPresentationController {
            presentation.detents = [.dcMedium, .large()]
            presentation.prefersGrabberVisible = true
            presentation.largestUndimmedDetentIdentifier = .dcMedium
            presentation.delegate = self
        }
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if sheetPresentationController.selectedDetentIdentifier == .large {
            self.detent = .large
        } else {
            self.detent = .medium
        }
    }
}

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {

    private let content: (Detent) -> Content
    @State private var detent: Detent = .medium
    
    enum Detent {
        case large, medium
    }
    
    @inlinable init(@ViewBuilder content: @escaping (Detent) -> Content) {
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content(self.detent), detent: self.$detent)
    }
    
    func updateUIViewController(_ viewController: HalfSheetController<Content>, context: Context) {
        viewController.rootView = content(self.detent)
    }
}

extension UISheetPresentationController.Detent.Identifier {
    static let dcMedium = UISheetPresentationController.Detent.Identifier("dcMedium")
}

extension UISheetPresentationController.Detent {
    static let dcMedium = UISheetPresentationController.Detent.custom(identifier: .dcMedium) { context in
        return CalendarView.bottomViewHeight
    }
}
