package com.dynamicdevices.visionclaw

import android.app.Application
import com.dynamicdevices.visionclaw.settings.SettingsProvider

class VisionClawApp : Application() {
    override fun onCreate() {
        super.onCreate()
        SettingsProvider.init(this)
    }
}
