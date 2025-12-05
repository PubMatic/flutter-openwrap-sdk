import UIKit
import OpenWrapSDK
import Flutter

/// Wrapper class around `POBBannerView` to transfer the API calls
class POBBannerClient: POBAdClient, POBBannerViewDelegate, FlutterPlatformView {
    private var banner: POBBannerView!
    private var methodChannel: FlutterMethodChannel?
    private var eventHandler: POBFLTBannerEvent?

    /// Initiates a new Banner client
    ///
    /// - Parameters:
    ///     - methodChannel: `MethodChannel` for native-dart communication
    ///     - pubId: Identifier of the publisher
    ///     - profileId: Profile ID of an ad tag
    ///     - adUnitId: Ad unit id used to identify unique placement on screen
    ///     - adSizes: List of HashMap containing ad sizes.
    init(adIndex: Int,
         publisherId: String,
         profileId: NSNumber,
         adUnitId: String,
         adSizes: [[String: Int]],
         isHeaderBidding: Bool,
         channel: FlutterMethodChannel) {
        super.init(adId: adIndex)
        if isHeaderBidding {
            let pobAdSizes = POBUtils.convertToPOBAdSizes(adSizes)
            eventHandler = POBBannerEventHandlerClient(adIndex: adIndex,
                                                       adSizes: pobAdSizes,
                                                       channel: channel)
            banner = POBBannerView(publisherId: publisherId,
                                   profileId: profileId,
                                   adUnitId: adUnitId,
                                   eventHandler: eventHandler!)
        } else {
            banner = POBBannerView(publisherId: publisherId,
                                   profileId: profileId,
                                   adUnitId: adUnitId,
                                   adSizes: POBUtils.convertToPOBAdSizes(adSizes))
        }
        banner?.delegate = self
        request = banner?.request
        methodChannel = channel
    }

    override func invokeMethod(names: [String], call: FlutterMethodCall, result: FlutterResult) {
        switch names[1] {
        case "loadAd":
            banner?.loadAd()
            result(nil)
        case "pauseAutoRefresh":
            banner?.pauseAutoRefresh()
            result(nil)
        case "resumeAutoRefresh":
            banner?.resumeAutoRefresh()
            result(nil)
        case "forceRefresh":
            result(banner?.forceRefresh())
        case "destroy":
            // ad is removed from super class switch case
            banner = nil
            result(nil)
        case "getBid":
            result(convertBidToMap(bid: banner?.bid()))
        case "getCreativeSize":
            result(POBUtils.convertPOBAdSizeToMap(adSize: banner?.creativeSize()))
        case "EventHandler":
            eventHandler?.invokeMethod(methodName: names[2], call: call, result: result)
        default:
            super.invokeMethod(names: names, call: call, result: result)
        }
    }

    func view() -> UIView {
        // In-case of gam ad win, empty POBBannerView is returned to support ad refresh
        if let adServerWin = eventHandler?.isAdServerWin(), adServerWin {
            for view in self.banner.subviews {
                view.removeFromSuperview()
            }
        }
        return self.banner
    }

    // MARK: BannerView delegate methods

    // Provides a view controller to use for presenting model views
    func bannerViewPresentationController() -> UIViewController {
        return UIApplication.presentedViewController()
    }

    // Notifies the delegate that an ad has been successfully loaded and rendered..
    func bannerViewDidReceiveAd(_ bannerView: POBBannerView) {
        methodChannel?.invokeMethod("onAdReceived", arguments: POBUtils.adIdArgs(adId: adId))
    }

    // Notifies the delegate of an error encountered while loading or rendering an ad.
    func bannerView(_ bannerView: POBBannerView, didFailToReceiveAdWithError error: Error) {
        let errMap = POBUtils.convertErrorAndAdIdToMap(error: error as NSError, adId: adId)
        methodChannel?.invokeMethod("onAdFailed", arguments: errMap)
    }

    // Notifies the delegate whenever current app goes in the background due to user click.
    func bannerViewWillLeaveApplication(_ bannerView: POBBannerView) {
        methodChannel?.invokeMethod("onAppLeaving", arguments: POBUtils.adIdArgs(adId: adId))
    }

    // Notifies delegate that the banner view will launch a modal on top of the current view controller,
    // as a result of user interaction.
    func bannerViewWillPresentModal(_ bannerView: POBBannerView) {
        methodChannel?.invokeMethod("onAdOpened", arguments: POBUtils.adIdArgs(adId: adId))
    }

    // Notifies delegate that the banner view has dismissed the modal on top of the current view controller.
    func bannerViewDidDismissModal(_ bannerView: POBBannerView) {
        methodChannel?.invokeMethod("onAdClosed", arguments: POBUtils.adIdArgs(adId: adId))
    }

    // Notifies the delegate of ad click
    func bannerViewDidClickAd(_ bannerView: POBBannerView) {
        methodChannel?.invokeMethod("onAdClicked", arguments: POBUtils.adIdArgs(adId: adId))
    }

    // Notifies the delegate of ad impression
    func bannerViewDidRecordImpression(_ bannerView: POBBannerView) {
        methodChannel?.invokeMethod("onAdImpression", arguments: POBUtils.adIdArgs(adId: adId))
    }

    // Notifies the delegate of ad size change
    func bannerView(_ bannerView: POBBannerView, willChangeAdSizeTo size: POBAdSize) {
        let adSizeMap = POBUtils.convertPOBAdSizeAndAdIdToMap(adSize: size, adId: adId)
        methodChannel?.invokeMethod("onAdSizeChanged", arguments: adSizeMap)
    }
}
