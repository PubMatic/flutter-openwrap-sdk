import 'dart:developer';

import 'package:flutter/services.dart';

import 'helpers/pob_utils.dart';
import 'pob_ad.dart';
import 'pob_ad_instance_manager.dart';
import 'pob_constants.dart';

OpenWrapSDKMethodChannel openWrapMethodChannel =
    OpenWrapSDKMethodChannel._('flutter_openwrap_sdk');

/// Class responsible for transfering the method call to respective platform side.
class OpenWrapSDKMethodChannel {
  final String _tag = 'OpenWrapSDKMethodChannel';

  /// Method channel to transfer calls to respective native platforms
  final MethodChannel _platformChannel;

  /// Constructor
  OpenWrapSDKMethodChannel._(String channelName)
      : _platformChannel = MethodChannel(channelName) {
    _platformChannel.setMethodCallHandler((call) async {
      onMethodCallHandler(call);
    });
  }

  /// Transfer the method call on platform side with
  /// [tag] name of the class that method belongs
  /// [methodName] name of method
  /// [argument] Optional parameter, holding map or primitive data types.
  Future<T?> callPlatformMethodWithTag<T>({
    required final String tag,
    required final String methodName,
    final dynamic argument,
  }) =>
      _platformChannel.invokeMethod<T>('$tag#$methodName', argument);

  /// Transfer the method call on platform side with
  /// [methodName] name of method
  /// [argument] Optional parameter, holding map or primitive data types.
  Future<T?> callPlatformMethod<T>({
    required final String methodName,
    final dynamic argument,
  }) =>
      _platformChannel.invokeMethod<T>(methodName, argument);

  /// Transfer the native client callbacks to respective adformat classes.
  void onMethodCallHandler(MethodCall call) {
    log('onMethodCallHandler - ${call.method}');
    int? id = POBUtils.cast(call.arguments[keyAdId]);
    if (id != null) {
      POBAd? ad = POBAdInstanceManager.instance.getValueFromMap(id);
      if (ad != null) {
        ad.onAdCallBack(call);
      } else {
        log('$_tag: onMethodCallHandler: Received $POBAd instance from $POBAdInstanceManager\'s map for Id: $id is missing.');
      }
    } else {
      log('$_tag: onMethodCallHandler: Received instance manager ID in the $MethodCall\'s argument is null.');
    }
  }
}
