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
            if let values = call.arguments as? Dictionary<String, Any>,
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
            if let appInfo = call.arguments as? Dictionary<String, Any> {
                setApplicationInfo(applicationInfo: appInfo)
            }
            result(nil)
        case "setUserInfo":
            if let userInfo = call.arguments as? Dictionary<String, Any> {
                setUserInfo(userInfo: userInfo)
            }
            result(nil)
        case "initialize":
            guard let arguments = call.arguments as? Dictionary<String, Any>,
                let publisherId = arguments["publisherId"] as? String,
                let profileIds = arguments["profileIds"] as? [Int] else {
                result(
                        FlutterError(
                            code: Constants.kOpenWrapPlatformException,
                            message: "Error while calling initialize on OpenWrapSDK class.",
                            details: "Cannot initialize OpenWrapSDK as the provided publisherId or profileId is invalid."
                        )
                    )
                return
                }
            let config = OpenWrapSDKConfig(publisherId: publisherId, andProfileIds: profileIds.map { NSNumber(value: $0) })
            OpenWrapSDK.initialize(with: config) { (success, error) in
                if success {
                    result(nil)
                } else if let error = error {
                    FlutterError(
                        code: Constants.kOpenWrapPlatformException,
                        message: "Error while calling initialize on OpenWrapSDK class.",
                        details: error.localizedDescription
                    )
                }
            }
        default:
            /// Unsupported method call; error out
            result(FlutterMethodNotImplemented)
        }
    }
        
    static func setLocation(source: Int, latitude: Double, longitude:Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let src = POBLocSource(rawValue: source + 1) ?? .userProvided
        OpenWrapSDK.setLocation(location, source: src)
    }

    static func setApplicationInfo(applicationInfo: Dictionary<String, Any>) {
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

    static func setUserInfo(userInfo:Dictionary<String, Any>) {
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
}
