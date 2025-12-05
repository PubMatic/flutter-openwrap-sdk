import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'event_handler/pob_banner_event.dart';
import 'helpers/pob_utils.dart';
import 'openwrap_sdk_method_channel.dart';
import 'pob_ad.dart';
import 'pob_ad_instance_manager.dart';
import 'pob_constants.dart';
import 'pob_data_types.dart';
import 'pob_type_definition.dart';

/// Class that displays the banner ad.
///
/// It renders a banner ad from either the ad server SDK or open wrap partner
/// whichever gets a chance in the auction.
class POBBannerAd extends POBAd {
  POBBannerAdListener? _listener;

  /// Handler to a send request to the ad server sdk.
  POBBannerEvent? _eventHandler;

  /// Flag to check for header bidding result.
  // ignore: prefer_final_fields
  bool _isAdServerWin = false;

  /// Widget class to host native banner view.
  late POBBannerWidget _bannerWidget;

  /// Flag to check whether ad has been loaded or not.
  bool _isAdLoaded = false;

  /// Reference of state class to update the adwidget internally.
  _POBBannerWidgetState? _widgetState;

  /// Initializes and returns newly allocated banner object for supporting
  /// `OpenWrap only configuration`.
  ///
  /// [pubId] Identifier of the publisher
  /// [profileId] Profile ID of an ad tag
  /// [adUnitId] Ad unit id used to identify unique placement on screen
  /// [adSizes] List of banner ad sizes
  POBBannerAd(
      {required String pubId,
      required int profileId,
      required String adUnitId,
      required List<POBAdSize> adSizes})
      : super(
            pubId: pubId,
            profileId: profileId,
            adUnitId: adUnitId,
            tag: tagPOBBannerView) {
    _init();
    _initBannerAd(adSizes);
  }

  /// Initializes and returns newly allocated banner object for supporting
  /// 'AdServer Ad SDK Configuration`.
  ///
  /// [pubId] Identifier of the publisher
  /// [profileId] Profile ID of an ad tag
  /// [adUnitId] Ad unit id used to identify unique placement on screen
  /// [bannerEvent] Valid instance of class implementing [POBBannerEvent]
  POBBannerAd.eventHandler(
      {required String pubId,
      required int profileId,
      required String adUnitId,
      required POBBannerEvent bannerEvent})
      : super(
            adUnitId: adUnitId,
            profileId: profileId,
            pubId: pubId,
            tag: tagPOBBannerView) {
    _init();
    _eventHandler = bannerEvent;
    _eventHandler?.setEventListener(_POBBannerEventListenerImpl(ad: this));
    final sizes = _eventHandler?.requestedAdSizes();
    if (sizes != null) {
      _initBannerAd(sizes);
    } else {
      log("$tag: Can't initlize instance of $POBBannerAd as the received ad sizes from event handler are null.");
    }
  }

  void _init() {
    adId = POBAdInstanceManager.instance.loadAd(this);
    adIdMap = {keyAdId: adId};
    _bannerWidget = POBBannerWidget._(this);
  }

  /// Invoke method channel to create native instance of POBBannerView.
  void _initBannerAd(List<POBAdSize> adSizes) =>
      openWrapMethodChannel.callPlatformMethod<void>(
          methodName: 'initBannerAd',
          argument: <String, dynamic>{
            ...adIdMap,
            keyPubId: pubId,
            keyProfileId: profileId,
            keyAdUnitId: adUnitId,
            keyAdSizes: POBUtils.convertAdSizesToListOfMap(adSizes),
            keyHeaderBidding: _eventHandler != null
          });

  /// Initiate the loading of a banner ad; if the [POBRequest] is available on
  /// the native OpenWrap SDK, then it proceeds with further execution;
  /// otherwise, it will log an error.
  Future<void> loadAd() async =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: tag, methodName: 'loadAd', argument: adIdMap);

  /// Returns the [POBAdSize] of the rendered ad creative.
  Future<POBAdSize?> getCreativeSize() async {
    if (_eventHandler != null && _isAdServerWin) {
      return await _eventHandler!.getAdSize.call();
    }

    Map<Object?, Object?>? result = POBUtils.cast(await openWrapMethodChannel
        .callPlatformMethodWithTag<Map<Object?, Object?>>(
            tag: tag, methodName: 'getCreativeSize', argument: adIdMap));
    int? width = POBUtils.cast<int>(result?['w']);
    int? height = POBUtils.cast<int>(result?['h']);
    if (width != null && height != null) {
      return POBAdSize(width: width, height: height);
    }
    return null;
  }

  /// Cancels existing ad requests and initiates new ad request.
  ///
  /// It may skip force refresh in below cases:
  /// 1. If ad creative is being loaded.
  /// 2. user interacting with ad (Opening Internal browser or expanding ad).
  /// 3. Waiting response from ad server SDK if applicable.
  ///
  /// Returns Status YES/NO, about force refresh, as described it can skip in
  /// few cases by returning 'NO'.
  Future<bool?> forceRefresh() =>
      openWrapMethodChannel.callPlatformMethodWithTag<bool>(
          tag: tag, methodName: 'forceRefresh', argument: adIdMap);

  /// Pauses the auto refresh, By default, banner refreshes automatically as per
  /// configured refresh interval on openwrap portal. Calling this method
  /// prevents the refresh cycle to happen even if a refresh interval has been
  /// specified.
  ///
  /// It is recommended to use this method whenever the ad widget is about to be hidden
  /// from the user for any period of time, to avoid unnecessary ad requests. You can
  /// then call [resumeAutoRefresh] to resume the refresh when banner becomes visible.
  Future<void> pauseAutoRefresh() =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: tag, methodName: 'pauseAutoRefresh', argument: adIdMap);

  /// Resumes the autorefresh as per configured refresh interval on openwrap portal,
  /// call this method only if you have previously paused autorefresh using [pauseAutoRefresh].
  /// This method has no effect if a refresh interval has not been set.
  Future<void> resumeAutoRefresh() =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: tag, methodName: 'resumeAutoRefresh', argument: adIdMap);

  /// Sets a [POBBannerAdListener] to receive callbacks.
  set listener(POBBannerAdListener listener) => _listener = listener;

  /// Creates the instance of [POBBannerWidget] and returns it.
  POBBannerWidget get getAdWidget => _bannerWidget;

  /// Returns true if the banner ad widget is currently mounted in the widget tree.
  bool get isMounted => _widgetState?.mounted ?? false;

  /// Invoke this method when your screen is about to destroy. It cleans the
  /// resources.
  Future<void> destroy() {
    _listener = null;
    _eventHandler?.destroy.call();
    _eventHandler = null;
    return openWrapMethodChannel
        .callPlatformMethodWithTag<void>(
            tag: tag, methodName: 'destroy', argument: adIdMap)
        .then((value) => POBAdInstanceManager.instance.unregister(adId));
  }

  @override
  void onAdCallBack(MethodCall call) {
    switch (call.method) {
      case 'onAdReceived':
        _isAdLoaded = true;
        _widgetState?._updateAdWidget();
        _listener?.onAdReceived?.call(this);
        break;
      case 'onAppLeaving':
        _listener?.onAppLeaving?.call(this);
        break;
      case 'onAdOpened':
        _listener?.onAdOpened?.call(this);
        break;
      case 'onAdClosed':
        _listener?.onAdClosed?.call(this);
        break;
      case 'onAdClicked':
        _listener?.onAdClicked?.call(this);
        break;
      case 'onAdImpression':
        _listener?.onAdImpression?.call(this);
        break;
      case 'onAdFailed':
        _isAdLoaded = false;
        POBError error =
            POBUtils.convertMapToPOBError(POBUtils.cast(call.arguments));
        _listener?.onAdFailed?.call(this, error);
        break;
      case 'requestAd':
        Map<String, String>? openWrapTargeting =
            POBUtils.convertMapOfObjectToMapOfString(
                POBUtils.cast(call.arguments[keyOpenWrapTargeting]));
        _eventHandler?.requestAd(openWrapTargeting: openWrapTargeting);
        break;
      case 'onAdSizeChanged':
        POBAdSize size =
            POBUtils.convertMapToPOBAdSize(POBUtils.cast(call.arguments));
        _listener?.onAdSizeChanged?.call(this, size);
        break;
    }
  }
}

// UI widgets difficult to unit test.
// coverage:ignore-start
/// StatefulWidget to fetch the native banner view from respective platforms.
class POBBannerWidget extends StatefulWidget {
  final POBBannerAd _bannerAd;

  const POBBannerWidget._(POBBannerAd ad, {Key? key})
      : _bannerAd = ad,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _POBBannerWidgetState();
}

class _POBBannerWidgetState extends State<POBBannerWidget> {
  Widget _adWidget = const SizedBox.shrink();
  bool _isAlreadyMounted = false;

  @override
  void initState() {
    super.initState();
    // Setting the reference of newly created state object.
    // If it is non null then state object is already been created and thus
    // _isAlreadyMounted throws error when build method gets called.
    if (widget._bannerAd._widgetState != null) {
      _isAlreadyMounted = true;
    } else {
      widget._bannerAd._widgetState = this;
    }
    if (widget._bannerAd._isAdLoaded) {
      _updateAdWidget();
    }
  }

  void _updateAdWidget() async {
    POBBannerAd ad = widget._bannerAd;

    POBAdSize? size = await ad.getCreativeSize();

    if (size != null) {
      if (mounted) {
        setState(() {
          _adWidget = SizedBox(
            // Assign UniqueKey to all the widgets so that each widget can be
            // identified uniquely and removed from hierarchy at the time of refresh.
            key: UniqueKey(),
            width: size.width.toDouble(),
            height: size.height.toDouble(),

            // If eventHandler is null, then it is an OpenWrap Ad Server configuration;
            // in that case, it returns the OpenWrap SDK native banner view.
            // Else is it the header bidding case, here it returns winning ad from the
            // OpenWrap or Ad server sdk, based on the integration type.
            child: ad._eventHandler == null
                ? _getOpenWrapWidget(ad)
                : Stack(
                    children: <Widget>[
                      ad._isAdServerWin
                          ? _getOpenWrapWidget(ad)
                          : ad._eventHandler!.getAdServerWidget(),
                      ad._isAdServerWin
                          ? ad._eventHandler!.getAdServerWidget()
                          : _getOpenWrapWidget(ad),
                    ],
                  ),
          );
        });
      } else {
        log('${ad.tag}: Cannot set state of $_POBBannerWidgetState as it is not mounted.');
      }
    } else {
      log('${ad.tag}: Failed to update $this as received creative sizes are null.');
    }
  }

  @override
  void reassemble() {
    if (!_isAlreadyMounted) {
      widget._bannerAd._widgetState = null;
    }
    super.reassemble();
  }

  @override
  void dispose() {
    if (!_isAlreadyMounted) {
      widget._bannerAd._widgetState = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAlreadyMounted) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('This POBBannerWidget is already in the Widget tree.'),
        ErrorHint(
            'Make sure that POBBannerWidget is not present in widget tree before inserting it again.'),
      ]);
    }
    return _adWidget;
  }

  /// Return OpenWrap SDK native banner ad.
  Widget _getOpenWrapWidget(POBBannerAd ad) {
    // return platform specific views
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
          // Assign UniqueKey to all the widgets so that each widget can be
          // identified uniquely and removed from hierarchy at the time of refresh.
          key: UniqueKey(),
          viewType: ad.tag,
          surfaceFactory: (context, controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: ad.tag,
              layoutDirection: TextDirection.ltr,
              creationParams: ad.adIdMap,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          });
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        // Assign UniqueKey to all the widgets so that each widget can be
        // identified uniquely and removed from hierarchy at the time of refresh.
        key: UniqueKey(),
        viewType: ad.tag,
        layoutDirection: TextDirection.ltr,
        creationParams: ad.adIdMap,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return Text(
          '$defaultTargetPlatform is not yet supported by the OW plugin.');
    }
  }
}
// coverage:ignore-end

/// Class to transfer callback from [POBBannerEvent]'s implementation to native
/// event handler client.
class _POBBannerEventListenerImpl extends EventHandlerListener
    implements POBBannerEventListener {
  final POBBannerAd _bannerAd;
  _POBBannerEventListenerImpl({required POBBannerAd ad})
      : _bannerAd = ad,
        super(ad: ad);

  @override
  POBAdServerAdEvent get onAdServerWin => () {
        super.onAdServerWin();
        _bannerAd._isAdServerWin = true;
      };

  @override
  POBEventOpenWrapPartnerWin get onOpenWrapPartnerWin => (String bidId) {
        super.onOpenWrapPartnerWin(bidId);
        _bannerAd._isAdServerWin = false;
      };

  @override
  POBEventError get onFailed => (Map<String, Object> error) {
        _bannerAd._isAdServerWin = false;
        openWrapMethodChannel.callPlatformMethodWithTag<void>(
            tag: ad.tag,
            methodName: '$eventHandlerTag#onFailed',
            argument: {...ad.adIdMap, ...error});
      };
}

/// Class for interaction with the POBBannerView.
/// All methods are guaranteed to occur on the main thread.
class POBBannerAdListener extends POBAdListener<POBBannerAd> {
  const POBBannerAdListener({
    POBAdEvent<POBBannerAd>? onAdReceived,
    POBAdEvent<POBBannerAd>? onAppLeaving,
    POBAdEvent<POBBannerAd>? onAdClicked,
    POBAdEvent<POBBannerAd>? onAdClosed,
    POBAdEvent<POBBannerAd>? onAdOpened,
    POBAdEvent<POBBannerAd>? onAdImpression,
    this.onAdFailed,
    this.onAdSizeChanged,
  }) : super(
          onAdClicked: onAdClicked,
          onAdClosed: onAdClosed,
          onAdOpened: onAdOpened,
          onAppLeaving: onAppLeaving,
          onAdReceived: onAdReceived,
          onAdImpression: onAdImpression,
        );

  /// Notifies the listener of an [error] encountered while loading or rendering
  /// an ad.
  final POBAdFailed<POBBannerAd>? onAdFailed;

  /// Notifies the listener of an ad size change
  final POBAdSizeChanged<POBBannerAd>? onAdSizeChanged;
}
