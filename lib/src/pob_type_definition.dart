// coverage:ignore-file - Type definitions and function signatures only

import 'package:flutter/widgets.dart';

import 'event_handler/pob_base_event.dart';
import 'pob_ad.dart';
import 'pob_data_types.dart';

/// Function definition used to set [POBAdEventListener] in the event handler
typedef POBEventListener<T extends POBAdEventListener> = void Function(
    T listener);

/// Function definition used to notify OpenWrapSDK Flutter Plugin on openWrapPartnerWin
typedef POBEventOpenWrapPartnerWin = void Function(String bid);

/// Function definition to pass the errors from event handle back to the listener
typedef POBEventError = void Function(Map<String, Object> error);

/// Function definition used to make request to the event handler with the openwrap targeting
typedef POBEventRequestAd = void Function(
    {Map<String, String>? openWrapTargeting});

/// Function Definition to give of any call back from event handler with
/// no input param and void as return type
typedef POBAdServerAdEvent = void Function();

/// Function Definition to give Ad Failed call back to the listener
typedef POBAdFailed<T extends POBAd> = void Function(T ad, POBError error);

/// Function Definition to give Ad size change call back to the listener
typedef POBAdSizeChanged<T extends POBAd> = void Function(T ad, POBAdSize size);

/// Function Definition to give Ad expired call back to the listener
typedef POBAdEvent<T extends POBAd> = void Function(T ad);

/// Function Definition to give reward received call back to the listener
typedef POBAdEventReward<T extends POBAd> = void Function(
    T ad, POBReward reward);

/// Function definition to return [POBAdSize].
typedef POBEventGetAdSize = Future<POBAdSize?> Function();

/// Function definition to return [List] of [POBAdSize].
typedef POBEventGetAdSizes = List<POBAdSize>? Function();

/// Function definition to return AdServer SDK [Widget].
typedef POBEventAdServerWidget = Widget Function();

/// Generic function definition for OpenWrap SDK events.
typedef POBSDKEvent = void Function();

/// Generic function definition for OpenWrap SDK error events.
typedef POBSDKErrorEvent = void Function(POBError error);
