//
//  Extensions.swift
//  StickyHeaderWithAutoScrollableTabs
//
//  Created by Maris Lagzdins on 22/02/2023.
//

import SwiftUI

extension [Product] {
    // Return the array's first product type
    var type: ProductType {
        if let firstProduct = self.first {
            return firstProduct.type
        }

        return .iphone
    }
}

// Scroll content offset
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offset(_ coordinateSpace: AnyHashable, completion: @escaping (CGRect) -> Void) -> some View {
        self.overlay {
            GeometryReader { proxy in
                let rect = proxy.frame(in: .named(coordinateSpace))

                Color.clear
                    .preference(key: OffsetKey.self, value: rect)
                    .onPreferenceChange(OffsetKey.self, perform: completion)
            }
        }
    }
}

// Animation OnEnd callback

fileprivate struct AnimationEndCallback<Value: VectorArithmetic>: ViewModifier, Animatable {
    var animatableData: Value {
        didSet { checkIfFinished() }
    }

    var endValue: Value
    var onEnd: () -> Void

    init(for value: Value, onEnd: @escaping () -> Void) {
        self.animatableData = value
        self.endValue = value
        self.onEnd = onEnd
    }

    func body(content: Content) -> some View {
        content
    }

    private func checkIfFinished() {
        if endValue == animatableData {
            DispatchQueue.main.async {
                onEnd()
            }
        }
    }
}

extension View {
    @ViewBuilder
    func checkAnimationEnd<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> some View {
        self.modifier(AnimationEndCallback(for: value, onEnd: completion))
    }
}
