// coverage:ignore-file - Protocol for banner event handler

import '../pob_type_definition.dart';
import 'pob_base_event.dart';

/// The banner custom event abstract class. Your banner custom event handler must
/// implement this class to communicate with ad server SDK.
class POBBannerEvent extends POBBaseEvent {
  const POBBannerEvent(
      {required POBEventRequestAd requestAd,
      required POBAdServerAdEvent destroy,
      required this.setEventListener,
      required this.getAdSize,
      required this.requestedAdSizes,
      required this.getAdServerWidget})
      : super(requestAd: requestAd, destroy: destroy);

  /// OpenWrap SDK flutter plugin calls this method to set [POBBannerEventListener],
  /// so OpenWrap custom event handler can inform the OpenWrap SDK via OW SDK
  /// flutter plugin about the events related to the ad server communication.
  ///
  /// Save the `listener` to use it in later phases of ad server events execution.
  final POBEventListener<POBBannerEventListener> setEventListener;

  /// OpenWrap SDK flutter plugin calls this method to get the size of the ad
  /// rendered by the ad server SDK.
  final POBEventGetAdSize getAdSize;

  /// OpenWrap SDK flutter plugin calls this method to get the size for which
  /// ad request should be made.
  final POBEventGetAdSizes requestedAdSizes;

  /// To retrieve ad server ad widget.
  final POBEventAdServerWidget getAdServerWidget;
}

/// The banner custom event listener. It is used to inform the ad server SDK
/// events back to OpenWrap SDK.
class POBBannerEventListener extends POBAdEventListener {
  const POBBannerEventListener(
      {required POBAdServerAdEvent onAdClick,
      required POBAdServerAdEvent onAdClosed,
      required POBAdServerAdEvent onAdOpened,
      required POBAdServerAdEvent onAdLeftApplication,
      required POBEventOpenWrapPartnerWin openWrapPartnerWin,
      required POBAdServerAdEvent onAdServerWin,
      required POBAdServerAdEvent onAdImpression,
      required this.onFailed})
      : super(
            onAdClick: onAdClick,
            onAdClosed: onAdClosed,
            onAdLeftApplication: onAdLeftApplication,
            onAdOpened: onAdOpened,
            onOpenWrapPartnerWin: openWrapPartnerWin,
            onAdServerWin: onAdServerWin,
            onAdImpression: onAdImpression);

  /// Handler should call this method to notify the OpenWrap SDK about any kind
  /// of loading error.
  final POBEventError onFailed;
}
