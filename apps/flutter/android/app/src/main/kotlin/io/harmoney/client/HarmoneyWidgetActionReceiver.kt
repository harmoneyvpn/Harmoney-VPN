package io.harmoney.client

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class HarmoneyWidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == HarmoneyWidgetProvider.ACTION_TOGGLE) {
            HarmoneyWidgetProvider.toggle(context)
        }
    }
}
