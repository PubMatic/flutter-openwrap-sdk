import Flutter
import Foundation
import OpenWrapSDK

/// Contains generic utility functions
public class POBUtils {
    /**
     Creates and returns `Dictionary` using provided `NSError` and adId.
     
     - Parameters:
        - error: `NSError` received from Openwrap SDK
        - adID: Unique Id of an ad for which error has occurred
     
     - Returns: Dictionary<Sring, Any> containing fields from `NSError` and adId
     */
    static func convertErrorAndAdIdToMap(error: NSError, adId: Int) -> [String: Any] {
        let errorCode = error.code
        let message = error.localizedDescription
        return [
            Constants.kErrCodeKey: errorCode,
            Constants.kErrMsgKey: message,
            Constants.kAdIdKey: adId
        ]
    }

    /**
     Creates and returns `Dictionary` using provided `NSError`

     - Parameters:
        - error: `NSError` received from Openwrap SDK

     - Returns: Dictionary<Sring, Any> containing fields from `NSError`
     */
    static func convertErrorToMap(error: NSError) -> [String: Any] {
        let errorCode = error.code
        let message = error.localizedDescription
        return [
            Constants.kErrCodeKey: errorCode,
            Constants.kErrMsgKey: message
        ]
    }

    /**
     Creates and returns `NSError` from provided `Dictionary`
     
     - Parameters:
        - map: `Dictionary` containing error code & message
     
     - Returns: `Error` with POBErrorDomain & error details from the dictionary
     */
    static func error(from map: [String: Any]?) -> Error {
        let errCode = map?[Constants.kErrCodeKey] as? Int ?? Constants.kInternalErrorCode
        let errMsg = map?[Constants.kErrMsgKey] as? String ?? Constants.kInternalErrorMsg
        let uInfo = [NSLocalizedDescriptionKey: NSLocalizedString(errMsg, comment: "")]
        return NSError(domain: kPOBErrorDomain, code: errCode, userInfo: uInfo)
    }

    /**
     Creates and returns an array of `POBAdSize` using provided array of map of widht and height
     
     - Parameters:
        - maps: Array of map containing width and height
     
     - Returns: Array of `POBAdSize`
     */
    static func convertToPOBAdSizes(_ maps: [[String: Int]]) -> [POBAdSize] {
        var pobAdSizes = [POBAdSize]()
        for map in maps {
            if let width = map["w"],
               let height = map["h"] {
                pobAdSizes.append(POBAdSize(cgSize: CGSize(width: width, height: height)))
            }
        }
        return pobAdSizes
    }

    static func adIdArgs(adId: Int) -> [String: Int] {
        return [Constants.kAdIdKey: adId]
    }
    
    /**
     Creates and returns `Dictionary` of`POBAdSize`

     - Parameters:
     - adSize: `POBAdSize` received from Openwrap SDK

     - Returns: Dictionary<String, Any> containing fields from `POBAdSize`
     */
    static func convertPOBAdSizeToMap(adSize: POBAdSize?) -> [String: Any] {
        var adSizeMap = [String: Any]()
        guard let adSize = adSize else { return adSizeMap }
        adSizeMap["w"] = Int(adSize.width())
        adSizeMap["h"] = Int(adSize.height())

        return adSizeMap
    }

    /**
     Creates and returns `Dictionary` using provided `POBAdSize` and adId.
     
     - Parameters:
     - adSize: `POBAdSize` received from Openwrap SDK
     - adID: Unique Id of an ad for which error has occurred
     
     - Returns: Dictionary<Sring, Any> containing fields from `POBAdSize` and adId
     */
    static func convertPOBAdSizeAndAdIdToMap(adSize: POBAdSize, adId: Int) -> [String: Any] {
        var result = convertPOBAdSizeToMap(adSize: adSize)
        result[Constants.kAdIdKey] = adId
        return result
    }

    /**
     Creates and returns `Dictionary` of`Custom Targeting`  and `adId`

     - Parameters:
     - targeting: `Map` of targeting reveived from bids provider
     - adId: unique ad Id

     - Returns: Dictionary<Sring, Any> containing fields from `Custom Targeting`  and `adId`
     */
    static func convertCustomTargetingToMap (targeting: [AnyHashable: Any]?, adId: Int) -> [String: Any] {
        var targetingMap = [String: Any]()

        targeting?.forEach({ (key: AnyHashable, value: Any) in
            if let stringKey = key as? String {
                targetingMap[stringKey] = value
            }
        })

        // if no targeting is available, empty dictionary will be returned
        var customTargetingMap = [String: Any]()
        customTargetingMap[Constants.kAdIdKey] = adId
        customTargetingMap[Constants.kTargetingKey] = targetingMap

        return customTargetingMap
    }

    /**
     Creates and returns `Dictionary` using provided `POBExternalUserId`
     
     - Parameters:
     - externalUserId: `POBExternalUserId` object from OpenWrap SDK
     
     - Returns: Dictionary<String, Any> containing fields from `POBExternalUserId` including extension property
     */
    static func convertExternalUserIdToMap(externalUserId: POBExternalUserId) -> [String: Any] {
        var map: [String: Any] = [
            "source": externalUserId.source,
            "id": externalUserId.externalUserId,
            "atype": externalUserId.atype,
            "ext": externalUserId.extension
        ]
        return map
    }

}

class POBAdInstanceManager {
    static let shared = POBAdInstanceManager()
    private init() {}
    // Stores all the active ad instances
    private var ads = [Int: POBAdClient]()
    func registerAd(adClient: POBAdClient) {
        ads[adClient.adId] = adClient
    }
    
    func unregisterAd(adClient: POBAdClient) {
        ads.removeValue(forKey: adClient.adId)
    }

    func ad(adId: Int) -> POBAdClient? {
        return ads[adId]
    }
}

extension UIApplication {

    static func presentedViewController() -> UIViewController {
        var presentedVC = rootViewController()
        while presentedVC.presentedViewController != nil {
            presentedVC = presentedVC.presentedViewController!
        }
        return presentedVC
    }
    
    static func rootViewController() -> UIViewController {
        return keyWindow().rootViewController!
    }
    
    static func keyWindow() -> UIWindow {
        let app = UIApplication.shared

        if let window = app.delegate?.window {
            return window!
        }

        // filter visible windows
        // app.windows will be deprecated in iOS 15
        let windows = app.windows.filter({ (window) -> Bool in
            return window.isKeyWindow || window.isHidden == false
        })
        // find top window
        if let keyWindow = windows.max(by: { $0.windowLevel > $1.windowLevel}) {
            return keyWindow
        }
        // return root VC below iOS 13
        return app.keyWindow!
    }
}
