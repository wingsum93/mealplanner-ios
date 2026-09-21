//
//  ProfileScreen.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
//
import SwiftUI

struct ProfileScreen:View{
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    init(
        settingsViewModel: SettingsViewModel
    ) {
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View{
        SettingsScreen(
            settingsViewModel: settingsViewModel
        )
    }
}

#if DEBUG
#Preview {
    ProfileScreen(
        settingsViewModel: SettingsViewModel(localDataSource: MockRecipeLocalDataSource())
    )
}
#endif
