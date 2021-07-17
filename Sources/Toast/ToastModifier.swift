//
//  ToastModifier.swift
//  Toast
//
//  Created by Aaron Sky on 7/17/21.
//

import SwiftUI

private let maxDragOffset: CGFloat = -100
private let minDragOffset: CGFloat = 50

private struct ToastModifier<Toast: View>: ViewModifier {
    @State private var timer: Timer?
    @GestureState private var dragOffset: CGFloat = 0
    
    @Binding private var isPresented: Bool
    @Binding private var shouldResetTimer: Bool
    
    private var duration: TimeInterval
    private var toast: () -> Toast
    
    init(
        isPresented: Binding<Bool>,
        duration: TimeInterval,
        shouldResetTimer: Binding<Bool> = .constant(false),
        @ViewBuilder toast: @escaping () -> Toast
    ) {
        _isPresented = isPresented
        _shouldResetTimer = shouldResetTimer
        self.duration = duration
        self.toast = toast
    }
    
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
                    .pinned(to: .bottom)
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

private struct ToastWithItemModifier<Toast: View, Item: Identifiable>: ViewModifier {
    @State private var shouldResetTimer = false
    @Binding private var item: Item?
    
    private var duration: TimeInterval
    private var toast: (Item) -> Toast
    
    init(item: Binding<Item?>, duration: TimeInterval, toast: @escaping (Item) -> Toast) {
        _item = item
        self.duration = duration
        self.toast = toast
    }
    
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
            .modifier(ToastModifier(isPresented: isPresented, duration: duration, shouldResetTimer: $shouldResetTimer, toast: toastWithItem))
    }
    
    private func itemHasChanged(_ item: Item.ID?) {
        shouldResetTimer = true
    }
    
    private func toastWithItem() -> Toast {
        guard let item = item else {
            preconditionFailure("toastWithItem should not be called unless isPresented returns true, otherwise item will be nil")
        }
        
        return toast(item)
    }
}

extension View {
    /// Presents a toast-style view on top of the content.
    public func toast<Toast: View, Item: Identifiable>(item: Binding<Item?>, duration: TimeInterval = 2.0, @ViewBuilder toast: @escaping (Item) -> Toast) -> some View {
        modifier(ToastWithItemModifier(item: item, duration: duration, toast: toast))
    }
    
    /// Presents a toast-style view on top of the content.
    public func toast<Toast: View>(isPresented: Binding<Bool>, duration: TimeInterval = 2.0, @ViewBuilder toast: @escaping () -> Toast) -> some View {
        modifier(ToastModifier(isPresented: isPresented, duration: duration, toast: toast))
    }
    
    fileprivate func onChange<V: Equatable>(of value: V, equaling expectedValue: V, perform action: @escaping (V) -> Void) -> some View {
        onChange(of: value) { newValue in
            guard newValue == expectedValue else {
                return
            }
            action(newValue)
        }
    }
}
