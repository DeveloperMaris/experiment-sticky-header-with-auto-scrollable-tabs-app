//
//  Home.swift
//  StickyHeaderWithAutoScrollableTabs
//
//  Created by Maris Lagzdins on 22/02/2023.
//

import SwiftUI

struct Home: View {
    @Namespace private var animation
    @State private var activeTab: ProductType = .iphone
    @State private var productsBasedOnType: [[Product]] = []
    @State private var animationProgress: CGFloat = 0

    @State private var scrollableTabOffset: CGFloat = 0
    @State private var initialTabOffset: CGFloat = 0


    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                // 1. With LazyVStack

//                LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
//                    Section {
//                        ForEach(productsBasedOnType, id: \.self) { products in
//                            productSectionView(products)
//                        }
//                    } header: {
//                        scrollableTabs(proxy)
//                    }
//                }

                // 2. With VStack

                VStack(spacing: 15) {
                    ForEach(productsBasedOnType, id: \.self) { products in
                        productSectionView(products)
                    }
                }
                .offset("CONTENTVIEW") { rect in
                    scrollableTabOffset = rect.minY - initialTabOffset
                }
            }
            .offset("CONTENTVIEW") { rect in
                initialTabOffset = rect.minY
            }
            .safeAreaInset(edge: .top) {
                scrollableTabs(proxy)
                    .offset(y: scrollableTabOffset > 0 ? scrollableTabOffset : 0)
            }
        }
        .navigationTitle("Apple Store")
        // For Scroll content offset detection
        .coordinateSpace(name: "CONTENTVIEW")
        // Navigation bar color (iOS 16)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.purple, for: .navigationBar)
        // Navigation bar color scheme (iOS 16)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background {
            Rectangle()
                .fill(Color(.systemGroupedBackground))
                .ignoresSafeArea()
        }
        .onAppear {
            // Filter products based on type
            guard productsBasedOnType.isEmpty else { return }

            for type in ProductType.allCases {
                let filteredProducts = products.filter { $0.type == type }
                productsBasedOnType.append(filteredProducts)
            }
        }
    }

    // Scrollable Tabs
    @ViewBuilder
    func scrollableTabs(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ProductType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        // Active tab indicator
                        .background(alignment: .bottom) {
                            if activeTab == type {
                                Capsule()
                                    .fill(.white)
                                    .frame(height: 5)
                                    .padding(.horizontal, -5)
                                    .offset(y: 15)
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }
                        }
                        .padding(.horizontal, 15)
                        .contentShape(Rectangle())
                        // Scrolling tab's whenever the Active tab is updated
                        .id(type.tabID)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeTab = type
                                animationProgress = 1.0
                                // Scrolling to the selected content
                                proxy.scrollTo(type, anchor: .topLeading)
                            }
                        }
                }
            }
            .padding(.vertical, 15)
            .onChange(of: activeTab) { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newValue.tabID, anchor: .center)
                }
            }
            .checkAnimationEnd(for: animationProgress) {
                // Reset to default, when the animation was finished
                animationProgress = 0.0
            }
        }
        .background {
            Rectangle()
                .fill(Color.purple)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 5)
        }
    }

    // Products Sectioned View
    @ViewBuilder
    func productSectionView(_ products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            if let firstProduct = products.first {
                Text(firstProduct.type.rawValue)
                    .font(.title)
                    .fontWeight(.semibold)
            }

            ForEach(products) { product in
                productRowView(product)
            }
        }
        .padding(15)
        // For auto scrolling
        .id(products.type)
        .offset("CONTENTVIEW") { rect in
            let minY = rect.minY
            // When the content reaches it's top then update the current active tab.
            if (minY < 30 && -minY < (rect.midY / 2) && activeTab != products.type) && animationProgress == 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Safety check
                    activeTab = (minY < 30 && -minY < (rect.midY / 2) && activeTab != products.type) ? products.type : activeTab
                }
            }
        }
    }

    // Product Row View
    @ViewBuilder
    func productRowView(_ product: Product) -> some View {
        HStack(spacing: 15) {
            Image(systemName: "phone.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.white)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.title3)

                Text(product.subtitle)
                    .font(.callout)
                    .foregroundColor(.secondary)

                Text(product.price)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Home()
        }
    }
}
