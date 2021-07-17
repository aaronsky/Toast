//
//  PinnedModifier.swift
//  Toast
//
//  Created by Aaron Sky on 7/17/21.
//

import SwiftUI

private struct PinnedModifier: ViewModifier {
    var edges: Edge.Set

    func body(content: Content) -> some View {
        if edges.isEmpty
            || (edges.contains(.trailing) && edges.contains(.leading))
            || (edges.contains(.top) && edges.contains(.bottom)) {
            content
        } else {
            VStack {
                if !edges.contains(.top) {
                    Spacer()
                }
                HStack {
                    if !edges.contains(.leading) {
                        Spacer()
                    }
                    content
                    if !edges.contains(.trailing) {
                        Spacer()
                    }
                }
                if !edges.contains(.bottom) {
                    Spacer()
                }
            }
        }
    }
}

extension View {
    func pinned(to edges: Edge.Set) -> some View {
        modifier(PinnedModifier(edges: edges))
    }
}
