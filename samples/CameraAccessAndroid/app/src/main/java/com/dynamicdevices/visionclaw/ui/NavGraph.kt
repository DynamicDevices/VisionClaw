package com.dynamicdevices.visionclaw.ui

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import com.dynamicdevices.visionclaw.ui.screens.HomeScreen
import com.dynamicdevices.visionclaw.ui.screens.SettingsScreen
import com.dynamicdevices.visionclaw.ui.screens.StreamScreen
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

object Routes {
    const val HOME = "home"
    const val SETTINGS = "settings"
    const val STREAM = "stream"
}

@Composable
fun NavGraph(navController: NavHostController = rememberNavController()) {
    NavHost(
        navController = navController,
        startDestination = Routes.HOME
    ) {
        composable(Routes.HOME) {
            HomeScreen(
                onOpenSettings = { navController.navigate(Routes.SETTINGS) },
                onStartStream = { navController.navigate(Routes.STREAM) }
            )
        }
        composable(Routes.SETTINGS) {
            SettingsScreen(onBack = { navController.popBackStack() })
        }
        composable(Routes.STREAM) {
            StreamScreen(onBack = { navController.popBackStack() })
        }
    }
}
