import Flutter
import OpenWrapSDK
import UIKit

class POBAdClient: NSObject {
    private(set) var adId: Int
    var request: POBRequest?
    init(adId: Int) {
        self.adId = adId
    }

    /**
     Creates and returns `Dictionary` of`POBBid`
    
     - Parameters:
     - bid: `POBBid` received from Openwrap SDK
    
     - Returns: Dictionary<String, Any> containing fields from `POBBid`
     */
    func convertBidToMap(bid: POBBid?) -> [String: Any] {
        var bidMap = [String: Any]()
        guard let bid else { return bidMap }

        bidMap["bidId"] = bid.bidId
        bidMap["impressionId"] = bid.impressionId
        bidMap["bundle"] = bid.bundle
        bidMap["price"] = bid.price.doubleValue
        bidMap["height"] = Int(bid.size.height)
        bidMap["width"] = Int(bid.size.width)
        bidMap["status"] = bid.status.intValue
        bidMap["creativeId"] = bid.creativeId
        bidMap["nurl"] = bid.nurl
        bidMap["lurl"] = bid.lurl
        bidMap["creative"] = bid.creativeTag
        bidMap["creativeType"] = bid.creativeType
        bidMap["partnerName"] = bid.partner
        bidMap["dealId"] = bid.dealId
        bidMap["refreshInterval"] = Int(bid.refreshInterval)
        bidMap["targetingInfo"] = bid.targetingInfo()
        bidMap["rewardAmount"] = bid.reward()?.amount.intValue
        bidMap["rewardCurrencyType"] = bid.reward()?.currencyType
        return bidMap
    }

    private func setRequestProperties(call: FlutterMethodCall, request: POBRequest?) {
        guard let values = call.arguments as? [String: Any] else { return }
        // `values` dictionary has dynamic types. Hence explicit type casting is required to set properties of `POBRequest`
        // which have default value. From flutter plugin, it is ensured that these properties will always receive some value, either custom or default one.
        // Also, to follow coding guidelines, `if let` is preferred over forced type casting.
        if let debug = values["debug"] as? Bool {
            request?.debug = debug
        }
        if let networkTimeout = values["networkTimeout"] as? Int {
            request?.networkTimeout = TimeInterval(networkTimeout)
        }
        if let enableReturnAllBidStatus = values["enableReturnAllBidStatus"] as? Bool {
            request?.enableReturnAllBidStatus = enableReturnAllBidStatus
        }
        if let testModeEnabled = values["testMode"] as? Bool {
            request?.testModeEnabled = testModeEnabled
        }

        // These properties can have eitxwher custom value or default value as `null`
        request?.versionId = values["versionId"] as? NSNumber
        request?.adServerURL = values["adServerUrl"] as? String
    }

    private func setImpressionProperties(call: FlutterMethodCall, impression: POBImpression?) {
        guard let values = call.arguments as? [String: Any] else { return }
        // `values` dictionary has dynamic types. Hence explicit type casting is required to set properties of `POBImpression`
        // which have default value. From flutter plugin, it is ensured that these properties will always receive some value, either custom or default one.
        // Also, to follow coding guidelines, `if let` is preferred over forced type casting.
        if let adPositionValue = values["adPosition"] as? Int {
            if adPositionValue < 2 {
                impression?.adPosition = POBAdPosition(rawValue: adPositionValue) ?? .unKnown
            } else {
                impression?.adPosition = POBAdPosition(rawValue: adPositionValue + 1) ?? .unKnown
            }
        }
        // These properties can have either custom value or default value as `null`
        impression?.testCreativeId = values["testCreativeId"] as? String
        impression?.customParams = values["customParams"] as? [String: Any]
    }

    func invokeMethod(names: [String], call: FlutterMethodCall, result: FlutterResult) {
        switch names[1] {
        case "setRequest":
            setRequestProperties(call: call, request: request)
            result(nil)
        case "setImpression":
            setImpressionProperties(call: call, impression: request?.impressions.first)
            result(nil)
        case "destroy":
            POBAdInstanceManager.shared.unregisterAd(adClient: self)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
