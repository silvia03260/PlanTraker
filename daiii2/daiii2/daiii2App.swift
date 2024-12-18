//
//  daiii2App.swift
//  daiii2
//
//  Created by Silvia Lembo on 18/12/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            GardenView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Giardino")
                }
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendario")
                }
        }
        .accentColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro per l'accento
    }
}
