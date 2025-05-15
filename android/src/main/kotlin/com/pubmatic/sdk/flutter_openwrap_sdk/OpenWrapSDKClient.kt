package com.pubmatic.sdk.flutter_openwrap_sdk

import com.pubmatic.sdk.common.OpenWrapSDK
import com.pubmatic.sdk.common.models.POBApplicationInfo
import com.pubmatic.sdk.common.models.POBLocation
import com.pubmatic.sdk.common.models.POBUserInfo
import com.pubmatic.sdk.common.OpenWrapSDKConfig
import com.pubmatic.sdk.common.OpenWrapSDKInitializer
import com.pubmatic.sdk.common.POBError

import com.pubmatic.sdk.flutter_openwrap_sdk.POBUtils.findBy

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

import android.content.Context

import java.net.URL

/**
 * Wrapper around [OpenWrapSDK] to transfer the dart method calls to OpenWrap SDK.
 */
object OpenWrapSDKClient {

  /**
   * Calls the [OpenWrapSDK] respective method.
   *
   * @param methodName received via methodChannel
   * @param call to fetch the required arguments received from dart side
   * @param result to transfer the result for native side
   */
  @JvmStatic
  fun methodCall(methodName: String, call: MethodCall, context: Context, result: Result) {
    when (methodName) {
      "setLogLevel" -> {
        call.arguments?.let { argument ->
          val logLevel: OpenWrapSDK.LogLevel? = OpenWrapSDK.LogLevel::getLevel findBy argument
          logLevel?.let { level ->
            OpenWrapSDK.setLogLevel(level)
            result.success(null)
            return
          }
          result.error(
            POBFlutterConstants.OPENWRAP_PLATFORM_EXCEPTION,
            "Error while calling setLogLevel on OpenWrapSDK class.",
            "Cannot set log level as the received log level is null."
          )
        }
      }

      "getVersion" -> {
        result.success(OpenWrapSDK.getVersion())
      }

      "allowLocationAccess" -> {
        call.arguments?.let {
          OpenWrapSDK.allowLocationAccess(it as Boolean)
        }
        result.success(null)
      }

      "setUseInternalBrowser" -> {
        call.arguments?.let {
          OpenWrapSDK.setUseInternalBrowser(it as Boolean)
        }
        result.success(null)
      }

      "setLocation" -> {
        call.argument<Int>("source")?.let { argument ->
          val source = POBLocation.Source.values().getOrElse(argument) { POBLocation.Source.GPS }
          val latitude: Double? = call.argument("latitude")
          val longitude: Double? = call.argument("longitude")
          if (latitude != null && longitude != null) {
            OpenWrapSDK.setLocation(POBLocation(source, latitude, longitude))
            result.success(null)
            return
          }
          result.error(
            POBFlutterConstants.OPENWRAP_PLATFORM_EXCEPTION,
            "Error while calling setLocation on OpenWrapSDK class.",
            "Cannot set location as latitude or longitude is null."
          )
        }
      }

      "setCoppa" -> {
        call.arguments?.let {
          OpenWrapSDK.setCoppa(it as Boolean)
        }
        result.success(null)
      }

      "setSSLEnabled" -> {
        call.arguments?.let {
          OpenWrapSDK.setSSLEnabled(it as Boolean)
        }
        result.success(null)
      }

      "allowAdvertisingId" -> {
        call.arguments?.let {
          OpenWrapSDK.allowAdvertisingId(it as Boolean)
        }
        result.success(null)
      }

      "setApplicationInfo" -> {
        OpenWrapSDK.setApplicationInfo(convertMapToApplicationInfo(call))
        result.success(null)
      }

      "setUserInfo" -> {
        OpenWrapSDK.setUserInfo(convertMapToUserInfo(call))
        result.success(null)
      }

      "initialize" -> {
        call.arguments?.let { argument ->
          val publisherId: String? = call.arguments?("publisherId")
          val profileIds: List<String?> = call.arguments("profileIds")

          if (publisherId != null && profileIds != null) {
            val openWrapSDKConfigBuilder = OpenWrapSDKConfig.Builder(publisherId, profileIds)
            val openWrapSDKConfig = openWrapSDKConfigBuilder.build()
            
            OpenWrapSDK.initialize(context, openWrapSDKConfig, object: OpenWrapSDKInitializer.Listener {
                override fun onFailure(error: POBError) {
                    result.error(
                        POBFlutterConstants.OPENWRAP_PLATFORM_EXCEPTION,
                        "Error while calling initialize on OpenWrapSDK class.",
                        error
                    )
                }
                override fun onSuccess() {
                  result.success(null)
                }
            })
            return
          }

          result.error(
            POBFlutterConstants.OPENWRAP_PLATFORM_EXCEPTION,
            "Error while calling initialize on OpenWrapSDK class.",
            "Cannot initialize OpenWrapSDK as the provided publisherId or profileId is invalid."
          )
        }
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  @JvmStatic
  private fun convertMapToUserInfo(call: MethodCall): POBUserInfo {
    val userInfo = POBUserInfo()

    call.argument<Int>("birthYear")?.let {
      userInfo.birthYear = it
    }

    call.argument<Int>("gender")?.let { argument ->
      userInfo.setGender(
        POBUserInfo.Gender.values().getOrElse(argument) { POBUserInfo.Gender.MALE })
    }

    call.argument<String>("city")?.let {
      userInfo.setCity(it)
    }

    call.argument<String>("metro")?.let {
      userInfo.setMetro(it)
    }

    call.argument<String>("zip")?.let {
      userInfo.setZip(it)
    }

    call.argument<String>("region")?.let {
      userInfo.setRegion(it)
    }

    call.argument<String>("userKeywords")?.let {
      userInfo.keywords = it
    }

    return userInfo
  }

  @JvmStatic
  private fun convertMapToApplicationInfo(call: MethodCall): POBApplicationInfo {
    val applicationInfo = POBApplicationInfo()

    applicationInfo.domain = call.argument<String>("domain")
    call.argument<String>("storeURL")?.let {
      applicationInfo.storeURL = URL(it)
    }
    call.argument<Boolean>("paid")?.let {
      applicationInfo.setPaid(it)
    }
    applicationInfo.categories = call.argument<String>("categories")
    applicationInfo.keywords = call.argument<String>("appKeywords")

    return applicationInfo
  }
}