package com.pubmatic.sdk.flutter_openwrap_sdk

import com.pubmatic.sdk.openwrap.core.POBBid
import com.pubmatic.sdk.openwrap.core.POBImpression
import com.pubmatic.sdk.openwrap.core.POBRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Base class for all ad formats.
 */
abstract class POBAdClient(val adId: Int, protected val channel: MethodChannel) {

  protected var request: POBRequest? = null
  protected var impression: POBImpression? = null

  /**
   * Calls the respective OpenWrap SDK's API.
   *
   * @param names received via methodChannel
   * @param call to fetch the required arguments received from dart side
   * @param result to transfer the result for native side
   */
  open fun methodCall(names: List<String>, call: MethodCall, result: Result) {
    when (names[1]) {
      "setRequest" -> {
        setRequestProperties(call, request)
        result.success(null)
      }

      "setImpression" -> {
        setImpressionProperties(call, impression)
        result.success(null)
      }

      else -> result.notImplemented()
    }
  }

  /**
   * Sets the properties received from map to [POBRequest] of respective ad format.
   *
   * @param call [MethodCall] helps to fetch the argument came in method channel.
   * @param request [POBRequest] allocated to ads
   */
  private fun setRequestProperties(call: MethodCall, request: POBRequest?) {
    call.argument<Boolean>("debug")?.let {
      request?.enableDebugState(it)
    }

    call.argument<Int>("networkTimeout")?.let {
      request?.networkTimeout = it
    }

    call.argument<Boolean>("enableReturnAllBidStatus")?.let {
      request?.enableReturnAllBidStatus(it)
    }

    request?.versionId = call.argument<Int>("versionId")

    call.argument<Boolean>("testMode")?.let {
      request?.enableTestMode(it)
    }

    request?.adServerUrl = call.argument<String>("adServerUrl")
  }

  /**
   * Sets the properties received from map to [POBImpression] of respective ad format.
   *
   * @param call [MethodCall] helps to fetch the argument came in method channel.
   * @param impression [POBImpression] allocated to ads
   */
  private fun setImpressionProperties(call: MethodCall, impression: POBImpression?) {
    call.argument<Int>("adPosition")?.let {
      impression?.adPosition =
        POBRequest.AdPosition.values().getOrElse(it) { POBRequest.AdPosition.UNKNOWN }
    }

    impression?.testCreativeId = call.argument<String>("testCreativeId")

    impression?.setCustomParam(call.argument<Map<String, List<String>>>("customParams"))
  }

  /**
   * Convert the instance of [POBBid] to [HashMap]
   *
   * @param bid instance of [POBBid]
   * @return map with bid properties
   */
  protected fun convertBidToMap(bid: POBBid?): Map<String, Any?> {
    val bidMap = HashMap<String, Any?>()

    bidMap["bidId"] = bid?.id
    bidMap["impressionId"] = bid?.impressionId
    bidMap["bundle"] = bid?.bundle
    bidMap["price"] = bid?.price
    bidMap["height"] = bid?.height
    bidMap["width"] = bid?.width
    bidMap["status"] = bid?.status
    bidMap["creativeId"] = bid?.creativeId
    bidMap["nurl"] = bid?.getnURL()
    bidMap["lurl"] = bid?.getlURL()
    bidMap["creative"] = bid?.creative
    bidMap["creativeType"] = bid?.creativeType
    bidMap["partnerName"] = bid?.partnerName
    bidMap["dealId"] = bid?.dealId
    bidMap["refreshInterval"] = bid?.refreshInterval
    bidMap["targetingInfo"] = bid?.targetingInfo
    bidMap["rewardAmount"] = bid?.firstReward?.amount
    bidMap["rewardCurrencyType"] = bid?.firstReward?.currencyType

    return bidMap
  }

  /**
   * Removes the instance entry form [POBAdInstanceManager]'s map.
   */
  protected fun destroy() {
    POBAdInstanceManager.unRegisterAd(this)
  }
}