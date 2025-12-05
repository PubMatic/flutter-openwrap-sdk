package com.pubmatic.sdk.flutter_openwrap_sdk

import android.content.Context
import com.pubmatic.sdk.common.OpenWrapSDK
import com.pubmatic.sdk.common.OpenWrapSDKConfig
import com.pubmatic.sdk.common.OpenWrapSDKInitializer
import com.pubmatic.sdk.common.POBCommonConstants
import com.pubmatic.sdk.common.POBError
import com.pubmatic.sdk.common.models.POBApplicationInfo
import com.pubmatic.sdk.common.models.POBDSAComplianceStatus
import com.pubmatic.sdk.common.models.POBExternalUserId
import com.pubmatic.sdk.common.models.POBLocation
import com.pubmatic.sdk.common.models.POBUserInfo
import com.pubmatic.sdk.flutter_openwrap_sdk.POBUtils.findBy
import com.pubmatic.sdk.flutter_openwrap_sdk.POBUtils.toMap
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.net.URL

/**
 * Wrapper around [OpenWrapSDK] to transfer the dart method calls to OpenWrap SDK.
 */
object OpenWrapSDKClient {

  /**
   * Calls the [OpenWrapSDK] respective method.
   *
   * @param context Instance of Context
   * @param methodName received via methodChannel
   * @param call to fetch the required arguments received from dart side
   * @param result to transfer the result for native side
   */
  @JvmStatic
  fun methodCall(context: Context, methodName: String, call: MethodCall, result: Result) {
    when (methodName) {

      "initialize" -> {
        val pubId = call.argument<String>("publisherId")
        val profileIds = call.argument<List<Int>>("profileIds")

        if (pubId != null && profileIds != null) {
          OpenWrapSDK.initialize(
            context, OpenWrapSDKConfig.Builder(pubId, profileIds).build(),
            object : OpenWrapSDKInitializer.Listener {

              override fun onFailure(error: POBError) {
                val arguments: HashMap<String, Any> = HashMap()
                arguments["error"] = POBUtils.getErrorArgumentMap(error)
                result.success(arguments)
              }

              override fun onSuccess() {
                val arguments: HashMap<String, Any?> = HashMap()
                arguments["success"] = null
                result.success(arguments)
              }
            })
        } else {
          val arguments: HashMap<String, Any> = HashMap()
          arguments["error"] = POBUtils.getErrorArgumentMap(
            POBError(
              POBError.INVALID_CONFIG,
              POBCommonConstants.INVALID_CONFIG_MESSAGE
            )
          )
          result.success(arguments)
        }
      }

      "setLogLevel" -> {
        call.arguments?.let { argument ->
          val logLevel: OpenWrapSDK.LogLevel? =
            OpenWrapSDK.LogLevel::getLevel findBy argument
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
          val source =
            POBLocation.Source.values().getOrElse(argument) { POBLocation.Source.GPS }
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

      // This API is deprecated in v4.8.0 android OW_SDK and will be removed from future SDK version.
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

      "setDSAComplianceStatus" -> {
        call.arguments?.let {
          OpenWrapSDK.setDSAComplianceStatus(
            POBDSAComplianceStatus.values().getOrElse(it as Int)
            { POBDSAComplianceStatus.NOT_REQUIRED })
        }
        result.success(null)
      }

      "getDSAComplianceStatus" -> {
        result.success(OpenWrapSDK.getDSAComplianceStatus().value)
      }

      "addExternalUserId" -> {
        OpenWrapSDK.addExternalUserId(convertMapToExternalUserId(call))
        result.success(null)
      }

      "getExternalUserIds" ->
        result.success(OpenWrapSDK.getExternalUserIds().map { convertExternalUserIdToMap(it) })

      "removeExternalUserIds" -> {
        call.arguments?.let {
          OpenWrapSDK.removeExternalUserIds(it as String)
        }
        result.success(null)
      }

      "removeAllExternalUserIds" -> {
        OpenWrapSDK.removeAllExternalUserIds()
        result.success(null)
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

  @JvmStatic
  private fun convertMapToExternalUserId(call: MethodCall): POBExternalUserId {
    val source = call.argument<String>("source") ?: ""
    val id = call.argument<String>("id") ?: ""
    val externalUserId = POBExternalUserId(source, id)

    call.argument<Int>("atype")?.let {
      externalUserId.atype = it
    }

    call.argument<Map<String, Any?>>("ext")?.let { extMap ->
      val jsonObject = JSONObject(extMap)
      externalUserId.extension = jsonObject
    }

    return externalUserId
  }

  @JvmStatic
  private fun convertExternalUserIdToMap(externalUserId: POBExternalUserId): Map<String, Any?> {
    val map = mutableMapOf<String, Any?>(
      "source" to externalUserId.source,
      "id" to externalUserId.id,
      "atype" to externalUserId.atype
    )

    externalUserId.extension?.let { jsonObject ->
      map["ext"] = jsonObject.toMap()
    }

    return map
  }
}