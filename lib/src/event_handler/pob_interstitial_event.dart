// coverage:ignore-file - Protocol event handler for interstitial ads

import '../pob_type_definition.dart';
import 'pob_base_event.dart';

/// The OpenWrap interstitial custom event class. Your interstitial custom event handler must
/// implement this class to communicate with ad server flutter plugin.
class POBInterstitialEvent extends POBBaseEvent {
  const POBInterstitialEvent({
    required POBEventRequestAd requestAd,
    required POBAdServerAdEvent destroy,
    required this.show,
    required this.setInterstitialEventListener,
  }) : super(requestAd: requestAd, destroy: destroy);

  /// OpenWrap SDK Flutter Plugin will call this method when publisher app calls
  /// show on POBInterstitial.
  /// Consumer of this method should call show() of primary ad server flutter plugin..
  final POBAdServerAdEvent show;

  /// OpenWrap SDK Flutter Plugin calls this method to sets the [POBInterstitialEventListener].
  /// This event listener passes the ad server SDK callbacks to OpenWrap SDK
  /// via OW SDK flutter plugin.
  final POBEventListener<POBInterstitialEventListener>
      setInterstitialEventListener;
}

/// OpenWrap interstitial custom event listener. It is used to inform ad server flutter plugin's
/// events back to the OpenWrap SDK Flutter Plugin
class POBInterstitialEventListener extends POBAdEventListener {
  const POBInterstitialEventListener({
    required POBAdServerAdEvent onAdClick,
    required POBAdServerAdEvent onAdClosed,
    required POBAdServerAdEvent onAdOpened,
    required POBAdServerAdEvent onAdLeftApplication,
    required POBEventOpenWrapPartnerWin onOpenWrapPartnerWin,
    required POBAdServerAdEvent onAdServerWin,
    required POBAdServerAdEvent onAdImpression,
    required this.onFailedToLoad,
    required this.onAdExpired,
    required this.onFailedToShow,
  }) : super(
            onAdClick: onAdClick,
            onAdClosed: onAdClosed,
            onAdLeftApplication: onAdLeftApplication,
            onAdOpened: onAdOpened,
            onOpenWrapPartnerWin: onOpenWrapPartnerWin,
            onAdServerWin: onAdServerWin,
            onAdImpression: onAdImpression);

  /// Handler should call this method to notify the OpenWrap SDK about any kind
  /// of load time error.
  final POBEventError onFailedToLoad;

  /// Handler should call this method to notify the OpenWrap SDK about any kind
  /// of show time error with with error details from ad server SDK.
  final POBEventError onFailedToShow;

  /// Handler should call this method to notify the OpenWrap SDK about ad expiry.
  final POBAdServerAdEvent onAdExpired;
}
