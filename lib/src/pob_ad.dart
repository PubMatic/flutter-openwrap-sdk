import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'event_handler/pob_base_event.dart';
import 'helpers/pob_utils.dart';
import 'openwrap_sdk_method_channel.dart';
import 'pob_constants.dart';
import 'pob_data_types.dart';
import 'pob_type_definition.dart';

/// The base class for all OpenWrap ad formats.
abstract class POBAd {
  /// Publisher id
  final String pubId;

  /// OpenWrap Ad unit id
  final String adUnitId;

  /// OpenWrap profile id
  final int profileId;

  /// Helps to append the class name as prefix in MethodChannel methodName and
  /// to easily locate logs.
  final String tag;

  /// Unique ad identifier
  @protected
  late final int adId;

  /// Unique instance id Map
  late final Map<String, int?> adIdMap;

  /// Sets the request properties on native OpenWrap SDK. If you already have
  /// set some request properties, on the second call of this method, only the
  ///  properties explicitly set to [POBRequest] will get set on the native
  /// OpenWrap SDK; other properties will be set to default or null.
  set request(POBRequest request) {
    final Map<String, dynamic> requestMap =
        POBUtils.convertRequestToMap(request);
    openWrapMethodChannel.callPlatformMethodWithTag<void>(
        tag: tag,
        methodName: 'setRequest',
        argument: {...adIdMap, ...requestMap});
  }

  //  Sets the impression properties on native OpenWrap SDK. If you already have
  /// set some impression properties, on the second call of this method, only the
  ///  properties explicitly set to [POBImpression] will get set on the native
  /// OpenWrap SDK; other properties will be set to default or null.
  set impression(POBImpression impression) {
    final Map<String, dynamic> impressionMap =
        POBUtils.convertImpressionToMap(impression, tag);
    openWrapMethodChannel.callPlatformMethodWithTag<void>(
        tag: tag,
        methodName: 'setImpression',
        argument: {...adIdMap, ...impressionMap});
  }

  /// Default constructor
  ///
  /// [pubId] Identifier of the publisher
  /// [profileId] Profile ID of an ad tag
  /// [adUnitId] Ad unit id used to identify unique placement on screen
  POBAd({
    required this.pubId,
    required this.profileId,
    required this.adUnitId,
    required this.tag,
  });

  /// Transfer native callbacks to [POBAdListener]'s implementations.
  void onAdCallBack(MethodCall call);

  /// Returns details about the winning bid that will be used to render the ad
  Future<POBBid> getBid() async {
    Map<Object?, Object?>? bidMap =
        await openWrapMethodChannel.callPlatformMethodWithTag(
            tag: tag, methodName: 'getBid', argument: adIdMap);
    return POBBid.fromMap(bidMap);
  }
}

/// Base EventHandlerListener which implements [POBAdListener] and invokes
/// common methods via method channel to communicate to native platforms
@protected
class EventHandlerListener implements POBAdEventListener {
  @protected
  POBAd ad;

  @protected
  EventHandlerListener({required this.ad});

  @override
  POBAdServerAdEvent get onAdClick =>
      () => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onAdClick',
          argument: ad.adIdMap);

  @override
  POBAdServerAdEvent get onAdClosed =>
      () => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onAdClosed',
          argument: ad.adIdMap);

  @override
  POBAdServerAdEvent get onAdLeftApplication =>
      () => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onAdLeftApplication',
          argument: ad.adIdMap);

  @override
  POBAdServerAdEvent get onAdOpened =>
      () => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onAdOpened',
          argument: ad.adIdMap);

  @override
  POBEventOpenWrapPartnerWin get onOpenWrapPartnerWin =>
      (String bidId) => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onOpenWrapPartnerWin',
          argument: <String, dynamic>{keyAdId: ad.adId, 'bidId': bidId});

  @override
  POBAdServerAdEvent get onAdServerWin =>
      () => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onAdServerWin',
          argument: ad.adIdMap);

  @override
  POBAdServerAdEvent get onAdImpression =>
      () => openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: ad.tag,
          methodName: '$eventHandlerTag#onAdImpression',
          argument: ad.adIdMap);
}

abstract class POBAdListener<T extends POBAd> {
  /// Notifies the listener that an ad has been received successfully.
  ///
  /// [ad] The Ad instance invoking this method.
  final POBAdEvent<T>? onAdReceived;

  /// Notifies the listener that a user interaction will open another app (e.g. Chrome browser),
  /// leaving the current app. To handle user clicks that open the landing page URL in the
  /// internal browser, use 'onAdClicked()' instead.
  ///
  /// [ad] The Ad instance invoking this method.
  final POBAdEvent<T>? onAppLeaving;

  /// Notifies that the OpenWrap view will open an ad on top of the current view.
  ///
  /// [ad] The Ad instance invoking this method.
  final POBAdEvent<T>? onAdOpened;

  /// Notifies that the OpenWrap view has closed the ad on top of the current view.
  ///
  /// [ad] The Ad instance invoking this method.
  final POBAdEvent<T>? onAdClosed;

  /// Notifies that the ad has been clicked
  ///
  /// [ad] The Ad instance invoking this method.
  final POBAdEvent<T>? onAdClicked;

  /// Notifies that the impression has occured for the Ad instance
  ///
  /// [ad] The Ad instance invoking this method.
  final POBAdEvent<T>? onAdImpression;

  @protected
  const POBAdListener({
    required this.onAdClicked,
    required this.onAdClosed,
    required this.onAdOpened,
    required this.onAppLeaving,
    required this.onAdReceived,
    required this.onAdImpression,
  });
}
