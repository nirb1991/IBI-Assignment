//
//  ContentView.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dependencies = AppDependencies()

    var body: some View {
        RootView(dependencies: dependencies)
    }
}

#Preview {
    ContentView()
}
