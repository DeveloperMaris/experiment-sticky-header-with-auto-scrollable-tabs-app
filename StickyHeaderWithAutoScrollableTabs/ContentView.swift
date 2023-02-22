//
//  ContentView.swift
//  StickyHeaderWithAutoScrollableTabs
//
//  Created by Maris Lagzdins on 22/02/2023.
//

// Resource: https://www.youtube.com/watch?v=XUeophZ1iTo

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
        }
        .preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

