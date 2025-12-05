package com.pubmatic.sdk.flutter_openwrap_sdk.rewarded

import android.content.Context
import com.pubmatic.sdk.common.POBError
import com.pubmatic.sdk.flutter_openwrap_sdk.POBAdClient
import com.pubmatic.sdk.flutter_openwrap_sdk.POBFlutterConstants
import com.pubmatic.sdk.flutter_openwrap_sdk.POBUtils
import com.pubmatic.sdk.openwrap.core.POBReward
import com.pubmatic.sdk.rewardedad.POBRewardedAd
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Wrapper around [POBRewardedAd] to transfer dart method calls to OpenWrap SDK.
 *
 * @property channel [MethodChannel] for native-dart communication
 * @constructor
 * Initializes the [POBRewardedAd] with necessary properties
 *
 * @param adId Unique Instance manager id
 * @param channel MethodChannel for triggering callback on dart side
 * @param context Application context
 * @param pubId Identifier of the publisher
 * @param profileId Profile ID of an ad tag
 * @param adUnitId Ad unit id used to identify unique placement on screen
 */
class POBRewardedClient(
  adId: Int,
  channel: MethodChannel,
  context: Context,
  pubId: String,
  profileId: Int,
  adUnitId: String
) : POBAdClient(adId, channel) {

  private val rewardedAd: POBRewardedAd? =
    POBRewardedAd.getRewardedAd(context, pubId, profileId, adUnitId)

  init {
    request = rewardedAd?.adRequest
    impression = rewardedAd?.impression
  }

  override fun methodCall(names: List<String>, call: MethodCall, result: MethodChannel.Result) {
    when (names[1]) {

      "setListener" -> {
        rewardedAd?.setListener(POBRewardedAdListenerImpl(channel, adId))
        result.success(null)
      }

      "setSkipAlertDialogInfo" -> setSkipAlertDialogInfoParams(call, result)

      "loadAd" -> {
        rewardedAd?.loadAd()
        result.success(null)
      }

      "show" -> {
        rewardedAd?.show()
        result.success(null)
      }

      "isReady" -> result.success(rewardedAd?.isReady)

      "getBid" -> result.success(convertBidToMap(rewardedAd?.bid))

      "destroy" -> {
        super.destroy()
        rewardedAd?.destroy()
        result.success(null)
      }

      else -> super.methodCall(names, call, result)
    }
  }

  private fun setSkipAlertDialogInfoParams(call: MethodCall, result: MethodChannel.Result) {
    call.argument<String>("title")?.let { title ->
      call.argument<String>("message")?.let { message ->
        call.argument<String>("resumeTitle")?.let { resumeTitle ->
          call.argument<String>("closeTitle")?.let { closeTitle ->
            rewardedAd?.setSkipAlertDialogInfo(title, message, resumeTitle, closeTitle)
            result.success(null)
            return
          }
        }
      }
    }
    result.error(
      POBFlutterConstants.OPENWRAP_PLATFORM_EXCEPTION,
      "Error while calling setSkipAlertDialogInfoParams on POBRewardedAd class.",
      "Cannot set skip alert dialog info params as one of the received values from " +
              "title, message, resumeTitle and closeTitle is null."
    )
  }

  /**
   * Listener for receiving callbacks of [POBRewardedAd] events from OpenWrapSDK.
   */
  private class POBRewardedAdListenerImpl(
    private val channel: MethodChannel,
    private val adId: Int
  ) : POBRewardedAd.POBRewardedAdListener() {

    override fun onAdReceived(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAdReceived", POBUtils.getArgumentMap(adId))
    }

    override fun onAdFailedToLoad(rewardedAd: POBRewardedAd, error: POBError) {
      channel.invokeMethod("onAdFailedToLoad", POBUtils.getArgumentMap(adId, error))
    }

    override fun onAdFailedToShow(rewardedAd: POBRewardedAd, error: POBError) {
      channel.invokeMethod("onAdFailedToShow", POBUtils.getArgumentMap(adId, error))
    }

    override fun onAppLeaving(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAppLeaving", POBUtils.getArgumentMap(adId))
    }

    override fun onAdOpened(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAdOpened", POBUtils.getArgumentMap(adId))
    }

    override fun onAdClosed(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAdClosed", POBUtils.getArgumentMap(adId))
    }

    override fun onAdClicked(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAdClicked", POBUtils.getArgumentMap(adId))
    }

    override fun onAdExpired(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAdExpired", POBUtils.getArgumentMap(adId))
    }

    override fun onReceiveReward(rewardedAd: POBRewardedAd, reward: POBReward) {
      val arguments: HashMap<String, Any> = POBUtils.getArgumentMap(adId) as HashMap<String, Any>
      arguments["currencyType"] = reward.currencyType
      arguments["amount"] = reward.amount
      channel.invokeMethod("onReceiveReward", arguments)
    }

    override fun onAdImpression(rewardedAd: POBRewardedAd) {
      channel.invokeMethod("onAdImpression", POBUtils.getArgumentMap(adId))
    }
  }
}