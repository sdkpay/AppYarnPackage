package com.demoproject

import android.view.View
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext

import spay.sdk.view.SPayButton

class AppYarnPackageViewManager : SimpleViewManager<View>() {
  override fun getName() = "AppYarnPackageView"

  override fun createViewInstance(reactContext: ThemedReactContext): SPayButton {
    return SPayButton(reactContext, null)
  }
}
