import UIKit
import Flutter
import OpenWrapSDK

class OpenWrapSDKClient: NSObject {

/// Method to route all the OpenWrapSDK global API calls
/// - Parameters:
///     - name: method to invoke
///     - call: FlutterMethodCall for argument & other details
///     - result: result block to invoke
    static func invokeMethod(name:String, call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch name {
        case "initialize":
               if let values = call.arguments as? [String: Any],
               let pubId = values["publisherId"] as? String,
               let profildIds = values["profileIds"] as? [NSNumber] {
                initialize(publisherId: pubId, profileIds: profildIds, result: result)
            } else {
                result(["error": [Constants.kErrCodeKey: Constants.kInitErrorCode,
                                  Constants.kErrMsgKey: Constants.kInitErrorMessage]])
            }
        case "setLogLevel":
            if let logLevel = call.arguments as? Int {
                OpenWrapSDK.setLogLevel(POBSDKLogLevel(rawValue: UInt(logLevel)) ?? .warning)
            }
            result(nil)
        case "getVersion":
            result(OpenWrapSDK.version())
        case "allowLocationAccess":
            if let allow = call.arguments as? Bool {
                OpenWrapSDK.allowLocationAccess(allow)
            }
            result(nil)
        case "setUseInternalBrowser":
            if let use = call.arguments as? Bool {
                OpenWrapSDK.useInternalBrowser(use)
            }
            result(nil)
        case "setLocation":
               if let values = call.arguments as? [String: Any],
               let src = values["source"] as? Int,
               let lat = values["latitude"] as? Double,
               let lon = values["longitude"] as? Double {
                setLocation(source: src, latitude: lat, longitude: lon)
                result(nil)
            } else {
              result(
                FlutterError(
                  code: Constants.kOpenWrapPlatformException,
                  message: "Error while calling setLocation on OpenWrapSDK class.",
                  details: "Cannot set location as the provided location data is invalid."
                )
              )
            }
            
        case "setCoppa":
            if let enabled = call.arguments as? Bool {
                OpenWrapSDK.setCoppaEnabled(enabled)
            }
            result(nil)
        // This API is deprecated in v4.8.0 OWSDK and will be removed in future SDK version.
        case "setSSLEnabled":
            if let enabled = call.arguments as? Bool {
                OpenWrapSDK.setSSLEnabled(enabled)
            }
            result(nil)
        case "allowAdvertisingId":
            if let allow = call.arguments as? Bool {
                OpenWrapSDK.allowAdvertisingId(allow)
            }
            result(nil)
        case "setApplicationInfo":
            if let appInfo = call.arguments as? [String: Any] {
                setApplicationInfo(applicationInfo: appInfo)
            }
            result(nil)
        case "setUserInfo":
            if let userInfo = call.arguments as? [String: Any] {
                setUserInfo(userInfo: userInfo)
            }
            result(nil)
        case "setDSAComplianceStatus":
            if let status = call.arguments as? POBDSAComplianceStatus {
                OpenWrapSDK.setDSAComplianceStatus(status)
            }
            result(nil)
        case "getDSAComplianceStatus":
            result(OpenWrapSDK.dsaComplianceStatus)
        case "addExternalUserId":
            if let externalUserId = call.arguments as? [String: Any] {
                setExternalUserId(extUserId: externalUserId)
            }
            result(nil)
        case "getExternalUserIds":
            let externalUserIds: [POBExternalUserId] = OpenWrapSDK.externalUserIds()
            let userIdDicts: [[String: Any]] = externalUserIds.map { userId in
                POBUtils.convertExternalUserIdToMap(externalUserId: userId)
            }
            result(userIdDicts)
        case "removeExternalUserIds":
            if let source = call.arguments as? String {
                OpenWrapSDK.removeExternalUserIds(withSource: source)
            }
            result(nil)
        case "removeAllExternalUserIds":
            OpenWrapSDK.removeAllExternalUserIds()
            result(nil)
        default:
            /// Unsupported method call; error out
            result(FlutterMethodNotImplemented)
        }
    }

    static func initialize(publisherId: String, profileIds: [NSNumber], result: @escaping FlutterResult) {
        let sdkConfig = OpenWrapSDKConfig(publisherId: publisherId, andProfileIds: profileIds)
        OpenWrapSDK.initialize(with: sdkConfig) { success, error in
               if success {
                   result(["success": success])
               } else {
                   if let err = error as NSError? {
                       result(["error": POBUtils.convertErrorToMap(error: err)])
                   }
               }
           }
    }

    static func setLocation(source: Int, latitude: Double, longitude:Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let src = POBLocSource(rawValue: source + 1) ?? .userProvided
        OpenWrapSDK.setLocation(location, source: src)
    }

    static func setApplicationInfo(applicationInfo: [String: Any]) {
        let app = POBApplicationInfo()
        if let url = applicationInfo["storeURL"] as? String {
            app.storeURL = URL(string: url) ?? app.storeURL
        }
        if let domain = applicationInfo["domain"] as? String {
            app.domain = domain
        }
        if let paid = applicationInfo["paid"] as? Bool {
            app.paid = paid ? POBBOOLYes : POBBOOLNo
        }
        if let cat = applicationInfo["categories"] as? String {
            app.categories = cat
        }
        if let keywords = applicationInfo["appKeywords"] as? String {
            app.keywords = keywords
        }
        OpenWrapSDK.setApplicationInfo(app)
    }

    static func setUserInfo(userInfo:[String: Any]) {
        let uInfo = POBUserInfo()
        if let genderValue = userInfo["gender"] as? Int {
          switch genderValue {
            case 0:
              uInfo.gender = .male

            case 1:
              uInfo.gender = .female

            case 2:
              uInfo.gender = .other

            default:
              uInfo.gender = .other
          }
        }
        if let yob = userInfo["birthYear"] as? NSNumber {
            uInfo.birthYear = yob
        }
        if let metro = userInfo["metro"] as? String {
            uInfo.metro = metro
        }
        if let city = userInfo["city"] as? String {
            uInfo.city = city
        }
        if let region = userInfo["region"] as? String {
            uInfo.region = region
        }
        if let zip = userInfo["zip"] as? String {
            uInfo.zip = zip
        }
        if let keywords = userInfo["userKeywords"] as? String {
            uInfo.keywords = keywords
        }
        OpenWrapSDK.setUserInfo(uInfo)
    }
    
    static func setExternalUserId(extUserId: [String: Any]) {
        guard let source = extUserId["source"] as? String,
              let id = extUserId["id"] as? String else {
            return
        }

        let externalUserId = POBExternalUserId(source: source, andId: id)
        
        if let type = extUserId["atype"] as? Int {
            externalUserId.atype = Int32(type)
        }
        if let ext = extUserId["ext"] as? [String: NSObject] {
            externalUserId.extension = ext
        }

        OpenWrapSDK.addExternalUserId(externalUserId)
    }
}
