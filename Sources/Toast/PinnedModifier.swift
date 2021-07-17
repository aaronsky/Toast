//
//  PinnedModifier.swift
//  Toast
//
//  Created by Aaron Sky on 7/17/21.
//

import SwiftUI

struct PinnedModifier: ViewModifier {
    enum Edge: CaseIterable {
        case leadingTop
        case leading
        case leadingBottom
        case top
        case trailingTop
        case trailing
        case trailingBottom
        case bottom
    }
    
    private var edge: Edge

    fileprivate init(edge: PinnedModifier.Edge) {
        self.edge = edge
    }
    
    func body(content: Content) -> some View {
        VStack {
            if edge == .leading
                || edge == .trailing
                || edge == .leadingBottom
                || edge == .trailingBottom
                || edge == .bottom
            {
                Spacer()
            }
            HStack {
                if edge == .trailing
                    || edge == .trailingTop
                    || edge == .trailingBottom
                    || edge == .top
                    || edge == .bottom
                {
                    Spacer()
                }
                content
                if edge == .leading
                    || edge == .leadingTop
                    || edge == .leadingBottom
                    || edge == .top
                    || edge == .bottom
                {
                    Spacer()
                }
            }
            if edge == .leading
                || edge == .trailing
                || edge == .leadingTop
                || edge == .trailingTop
                || edge == .top
            {
                Spacer()
            }
        }
    }
}

extension View {
    func pinned(to edge: PinnedModifier.Edge) -> some View {
        modifier(PinnedModifier(edge: edge))
    }
}
