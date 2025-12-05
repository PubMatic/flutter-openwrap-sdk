// coverage:ignore-file - Abstract base class with no concrete implementation to test

import 'package:flutter/widgets.dart';

import '../pob_type_definition.dart';

/// Abstract class definition to provide ad server implementation. This can be used
/// by ad format specific implementation by ad server.
abstract class POBBaseEvent {
  @protected
  const POBBaseEvent({
    required this.requestAd,
    required this.destroy,
  });

  /// OpenWrap SDK flutter plugin calls this method with winning bid OpenWrap
  /// targeting make a request to primary SDK. OpenWrap SDK passes the winning
  /// bid's targeting for the requested impression.
  final POBEventRequestAd requestAd;

  /// OpenWrap SDK flutter plugin calls this method to perform any final cleanup.
  final POBAdServerAdEvent destroy;
}

/// The base ad event listener. It is used to inform the ad server SDK events
/// back to OpenWrap SDK Flutter Plugin.
abstract class POBAdEventListener {
  @protected
  const POBAdEventListener(
      {required this.onAdClick,
      required this.onAdClosed,
      required this.onAdOpened,
      required this.onAdLeftApplication,
      required this.onAdServerWin,
      required this.onOpenWrapPartnerWin,
      required this.onAdImpression});

  /// Call this when the ad server SDK informs about click happened on Ad.
  final POBAdServerAdEvent onAdClick;

  /// Call this when the ad server SDK is about to close / collapse an Ad.
  final POBAdServerAdEvent onAdClosed;

  /// Call this when the ad server SDK is about to open / expand an Ad.
  final POBAdServerAdEvent onAdOpened;

  /// Notifies the listener whenever current app goes in the background due to
  /// user click.
  final POBAdServerAdEvent onAdLeftApplication;

  /// Handler should call this when the ad server SDK signals about partner bid
  /// win with bid id.
  final POBEventOpenWrapPartnerWin onOpenWrapPartnerWin;

  /// handler should call this method to notify the OpenWrap SDK about
  /// ad server SDK renders its own ad.
  final POBAdServerAdEvent onAdServerWin;

  /// Notifies OpenWrap SDK via OW SDK flutter plugin about ad server impression
  /// record.
  final POBAdServerAdEvent onAdImpression;
}
