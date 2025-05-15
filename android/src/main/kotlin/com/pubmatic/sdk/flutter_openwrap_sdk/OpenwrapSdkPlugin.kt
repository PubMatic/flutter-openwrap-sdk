package com.pubmatic.sdk.flutter_openwrap_sdk

import android.content.Context
import com.pubmatic.sdk.common.log.POBLog
import com.pubmatic.sdk.flutter_openwrap_sdk.banner.POBBannerViewClient
import com.pubmatic.sdk.flutter_openwrap_sdk.banner.POBBannerViewFactory
import com.pubmatic.sdk.flutter_openwrap_sdk.interstitial.POBInterstitialClient
import com.pubmatic.sdk.flutter_openwrap_sdk.rewarded.POBRewardedClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterOpenwrapSdkPlugin */
class OpenwrapSdkPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_openwrap_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    if (!flutterPluginBinding.platformViewRegistry.registerViewFactory(
        "POBBannerView",
        POBBannerViewFactory()
      )
    ) {
      POBLog.warn(TAG, "Platform view is already registered.")
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val names = call.method.split('#')

    when (names[0]) {
      "OpenWrapSDK" -> OpenWrapSDKClient.methodCall(names[1], call, context, result)

      "initBannerAd" -> {
        val bannerViewClient = POBBannerViewClient(
          call.argument<Int>(POBFlutterConstants.KEY_AD_ID)!!,
          channel,
          context,
          call.argument<String>(POBFlutterConstants.KEY_PUB_ID)!!,
          call.argument<Int>(POBFlutterConstants.KEY_PROFILE_ID)!!,
          call.argument<String>(POBFlutterConstants.KEY_AD_UNIT_ID)!!,
          call.argument<List<HashMap<String, Int>>>("adSizes")!!,
          call.argument<Boolean>(POBFlutterConstants.KEY_HEADER_BIDDING)!!
        )
        POBAdInstanceManager.registerAd(bannerViewClient)
        result.success(null)
      }

      "POBBannerView" -> {
        val bannerViewClient =
          POBAdInstanceManager.getAd(call.argument<Int>(POBFlutterConstants.KEY_AD_ID)!!)
        bannerViewClient?.methodCall(names, call, result)
      }

      "initInterstitialAd" -> {
        val interstitialClient = POBInterstitialClient(
          call.argument<Int>(POBFlutterConstants.KEY_AD_ID)!!,
          channel,
          context,
          call.argument<String>(POBFlutterConstants.KEY_PUB_ID)!!,
          call.argument<Int>(POBFlutterConstants.KEY_PROFILE_ID)!!,
          call.argument<String>(POBFlutterConstants.KEY_AD_UNIT_ID)!!,
          call.argument<Boolean>(POBFlutterConstants.KEY_HEADER_BIDDING)!!
        )
        POBAdInstanceManager.registerAd(interstitialClient)
        result.success(null)
      }

      "POBInterstitial" -> {
        val interstitialClient =
          POBAdInstanceManager.getAd(call.argument<Int>(POBFlutterConstants.KEY_AD_ID)!!)
        interstitialClient?.methodCall(names, call, result)
      }

      "initRewardedAd" -> {
        val rewardedClient = POBRewardedClient(
          call.argument<Int>(POBFlutterConstants.KEY_AD_ID)!!,
          channel,
          context,
          call.argument<String>(POBFlutterConstants.KEY_PUB_ID)!!,
          call.argument<Int>(POBFlutterConstants.KEY_PROFILE_ID)!!,
          call.argument<String>(POBFlutterConstants.KEY_AD_UNIT_ID)!!
        )
        POBAdInstanceManager.registerAd(rewardedClient)
        result.success(null)
      }

      "POBRewardedAd" -> {
        val rewardedClient =
          POBAdInstanceManager.getAd(call.argument<Int>(POBFlutterConstants.KEY_AD_ID)!!)
        rewardedClient?.methodCall(names, call, result)
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  companion object {
    private const val TAG = "OpenwrapSdkPlugin"
  }
}