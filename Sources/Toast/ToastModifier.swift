//
//  ToastModifier.swift
//  Toast
//
//  Created by Aaron Sky on 7/17/21.
//

import SwiftUI

private let maxDragOffset: CGFloat = -100
private let minDragOffset: CGFloat = 50

private struct ToastModifier<V: View>: ViewModifier {
    @State private var timer: Timer?
    @GestureState private var dragOffset: CGFloat = 0

    @Binding var isPresented: Bool
    @Binding var edges: Edge.Set
    @Binding var shouldResetTimer: Bool
    var duration: TimeInterval
    var toast: () -> V

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .updating($dragOffset) { value, state, _ in
                state = max(maxDragOffset, value.translation.height)
                timer?.invalidate()
            }
            .onEnded { value in
                if value.translation.height > minDragOffset {
                    return dismiss()
                }

                resetTimer()
            }
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .zIndex(1)

            if isPresented {
                toast()
                    .pinned(to: edges)
                    .offset(y: dragOffset)
                    .animation(.interactiveSpring(), value: dragOffset)
                    .transition(.opacity.animation(.easeOut))
                    .onAppear(perform: onAppear)
                    .onDisappear(perform: onDisappear)
                    .onChange(of: shouldResetTimer, equaling: true, perform: resetTimer)
                    .onTapGesture(perform: dismiss)
                    .gesture(dragGesture)
                    .zIndex(2)
            }
        }
    }

    private func onAppear() {
        resetTimer()
    }

    private func onDisappear() {
        timer?.invalidate()
    }

    private func resetTimer(force: Bool = false) {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            dismiss()
        }

        shouldResetTimer = false
    }

    private func dismiss() {
        withAnimation(.easeOut) {
            isPresented = false
        }
    }
}

private struct ToastWithItemModifier<V: View, Item: Identifiable>: ViewModifier {
    @State private var shouldResetTimer = false

    @Binding var item: Item?
    @Binding var edges: Edge.Set
    var duration: TimeInterval
    var toast: (Item) -> V

    func body(content: Content) -> some View {
        let isPresented = Binding(get: {
            item != nil
        }, set: { newValue in
            if !newValue {
                item = nil
            }
        })

        return content
            .onChange(of: item?.id, perform: itemHasChanged)
            .modifier(
                ToastModifier(isPresented: isPresented,
                              edges: $edges,
                              shouldResetTimer: $shouldResetTimer,
                              duration: duration,
                              toast: toastWithItem)
            )
    }

    private func itemHasChanged(_ item: Item.ID?) {
        shouldResetTimer = true
    }

    private func toastWithItem() -> V {
        guard let item = item else {
            preconditionFailure("toastWithItem should not be called unless isPresented returns true, otherwise item will be nil")
        }

        return toast(item)
    }
}

public extension View {
    /// Presents an ephemeral toast to the user.
    ///
    /// - Parameter item: A binding to an optional source of truth for the toast. If the item is non-`nil`, the system passes the contents to the modifier's closure. You use this content to populate the fields of a toast you create that the system displays on top of the rest of the layout. If `item` changes, the expiry duration is reset and the toast is updated inline. Once the toast expires, this binding is set back to `nil`.
    /// - Parameter duration: The length of time in seconds that the toast should stay on screen.
    /// - Parameter edges: The edge of the screen that the toast should be pinned to. If multiple edges on an axis are passed, the set will be ignored and the toast will be centered in frame.
    /// - Parameter toast: A closure returning the view to present as a toast.
    func toast<Content: View, Item: Identifiable>(
        item: Binding<Item?>,
        duration: TimeInterval = 2.0,
        edges: Binding<Edge.Set> = .constant(.bottom),
        @ViewBuilder toast: @escaping (Item) -> Content
    ) -> some View {
        modifier(
            ToastWithItemModifier(item: item,
                                  edges: edges,
                                  duration: duration,
                                  toast: toast)
        )
    }

    /// Presents an ephemeral toast to the user.
    ///
    /// - Parameter isPresented: A binding to a Boolean value that determines whether to present the toast that you create in the modifier’s content closure. When the user taps or drags the toast off screen, or if the expiry duration is exceeded, `isPresented` is set back to `false` which dismisses the toast.
    /// - Parameter duration: The length of time in seconds that the toast should stay on screen.
    /// - Parameter edges: The edge of the screen that the toast should be pinned to. If multiple edges on an axis are passed, the set will be ignored and the toast will be centered in frame.
    /// - Parameter toast: A closure returning the view to present as a toast.
    func toast<Content: View>(
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0,
        edges: Binding<Edge.Set> = .constant(.bottom),
        @ViewBuilder toast: @escaping () -> Content
    ) -> some View {
        modifier(
            ToastModifier(isPresented: isPresented,
                          edges: edges,
                          shouldResetTimer: .constant(false),
                          duration: duration,
                          toast: toast)
        )
    }
}

private extension View {
    func onChange<Value: Equatable>(of value: Value, equaling expectedValue: Value, perform action: @escaping (Value) -> Void) -> some View {
        onChange(of: value) { newValue in
            guard newValue == expectedValue else {
                return
            }
            action(newValue)
        }
    }
}
