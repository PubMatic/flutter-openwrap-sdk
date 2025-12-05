import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'helpers/pob_utils.dart';
import 'openwrap_sdk_method_channel.dart';
import 'pob_data_types.dart';
import 'pob_type_definition.dart';

/// Provides global configurations for the OpenWrap SDK, e.g., enabling logging,
/// location access, GDPR, etc. These configurations are globally applicable for
/// OpenWrap SDK; you don't have to set these for every ad request.
class OpenWrapSDK {
  static const String _tag = 'OpenWrapSDK';

  static void initialize(
      {required final OpenWrapSDKConfig config,
      final OpenWrapSDKListener? listener}) async {
    Map<Object?, Object?>? result = await openWrapMethodChannel
        .callPlatformMethodWithTag(
            tag: _tag,
            methodName: 'initialize',
            argument: <String, dynamic>{
          'publisherId': config.publisherId,
          'profileIds': config.profileIds
        });

    if (result != null) {
      if (result.containsKey("success")) {
        listener?.onOpenWrapSDKInitialize?.call();
      } else {
        Map<Object?, Object?> errorMap =
            result["error"] as Map<Object?, Object?>;
        listener?.onOpenWrapSDKInitializeError
            ?.call(POBUtils.convertMapToPOBError(errorMap));
      }
    } else {
      listener?.onOpenWrapSDKInitializeError?.call(POBError(
        errorCode: POBError.internalError,
        errorMessage: "Internal Error Occurred",
      ));
    }
  }

  /// Sets log level across all ad formats. Default log level is LogLevel.Warn.
  /// [logLevel] log level to set.
  static Future<void> setLogLevel(final POBLogLevel logLevel) async {
    // Log level on Flutter are in reverse order in compare to iOS
    int logIndex = Platform.isIOS
        ? POBLogLevel.values.length - logLevel.index - 1
        : logLevel.index;
    return openWrapMethodChannel.callPlatformMethodWithTag<void>(
        tag: _tag, methodName: 'setLogLevel', argument: logIndex);
  }

  /// Returns the OpenWrap SDK's version.
  static Future<String?> getVersion() => openWrapMethodChannel
      .callPlatformMethodWithTag<String>(tag: _tag, methodName: 'getVersion');

  /// Used to enable/disable location access.
  /// This value decides whether the OpenWrap SDK should access device location
  /// using Core Location APIs to serve location-based ads. When set to false,
  /// the SDK will not attempt to access device location. When set to true,
  /// the SDK will periodically try to fetch location efficiently.
  /// Note that, this only occurs if location services are enabled and the user
  /// has already authorized the use of location services for the application.
  /// The OpenWrap SDK never asks
  /// permission to use location services by itself.
  ///
  /// The default value is true.
  ///
  /// [allow] enable or disable location access behavior
  ///
  static Future<void> allowLocationAccess(final bool allow) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag, methodName: 'allowLocationAccess', argument: allow);

  /// Tells OpenWrap SDK to use the internal SDK browser, instead of the default
  /// device browser, for opening landing pages when the user clicks on an ad.
  /// By default, the use of an internal browser is disabled.
  ///
  ///   From version 2.7.0, the default behaviour changed to using device's
  /// default browser
  ///
  /// [internalBrowserState] boolean value that enables/disables the use of
  /// internal browser.
  static Future<void> setUseInternalBrowser(final bool internalBrowserState) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag,
          methodName: 'setUseInternalBrowser',
          argument: internalBrowserState);

  /// Sets user's location and its source. It is useful in delivering
  /// geographically relevant ads.
  ///
  /// If your application is already accessing the device location, it is highly
  /// recommended to set the location coordinates inferred from the device GPS.
  /// If you are inferring location from any other source, make sure you set the
  /// appropriate location source.
  ///
  /// [source] User's current location
  static Future<void> setLocation(final POBLocationSource source,
          final double latitude, final double longitude) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag,
          methodName: 'setLocation',
          argument: <String, dynamic>{
            'source': source.index,
            'latitude': latitude,
            'longitude': longitude
          });

  /// Indicates whether the visitor is COPPA-specific or not.
  /// For COPPA (Children's Online Privacy Protection Act) compliance,
  /// if the visitor's age is below 13, then such visitors should not be served
  /// targeted ads.
  ///
  /// Possible options are:
  /// * False - Indicates that the visitor is not COPPA-specific and can be served
  ///         targeted ads.
  /// * True  - Indicates that the visitor is COPPA-specific and should be served
  ///         only COPPA-compliant ads.
  ///
  /// [coppaState] Visitor state for COPPA compliance.
  static Future<void> setCoppa(final bool coppaState) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag, methodName: 'setCoppa', argument: coppaState);

  /// Enable/disable secure ad calls.
  ///
  /// By default, OpenWrap SDK initiates secure ad calls from an application to
  /// the ad server and
  /// delivers only secure ads. You can allow non secure ads by passing false
  /// to this method.
  ///
  /// [requestSecureCreative] false for disable secure creative mode.
  /// Default is set to true.
  ///
  /// **Deprecated:** This API is deprecated in v3.0.0 and will be removed from future plugin version. Going forward, the ow_sdk flutter plugin will support only secure creatives.
  @Deprecated('This API is deprecated in OpenWrap SDK Flutter plugin v3.0.0')
  static Future<void> setSSLEnabled(final bool requestSecureCreative) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag,
          methodName: 'setSSLEnabled',
          argument: requestSecureCreative);

  /// Indicates whether Android advertisement ID should be sent in the request
  /// or not.
  /// By default advertisement ID will be used.
  ///
  /// Possible values are:
  /// * True : Advertisement id will be sent in the request.
  /// * False : Advertisement id will not be sent in the request.
  ///
  /// [allow] state of advertisement id usage
  static Future<void> allowAdvertisingId(final bool allow) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag, methodName: 'allowAdvertisingId', argument: allow);

  /// Sets Application information, which contains various attributes about app,
  /// such as
  /// application category, store URL, domain, etc for more relevant ads.
  ///
  /// [applicationInfo] Instance of POBApplicationInfo class with required
  /// application details
  static Future<void> setApplicationInfo(
          final POBApplicationInfo applicationInfo) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag,
          methodName: 'setApplicationInfo',
          argument: <String, dynamic>{
            'domain': applicationInfo.domain,
            'storeURL': applicationInfo.storeURL?.toString(),
            'paid': applicationInfo.paid,
            'categories': applicationInfo.categories,
            'appKeywords': applicationInfo.appKeywords
          });

  /// Sets user information, such as birth year, gender, region, etc for more
  /// relevant ads.
  ///
  /// [userInfo] Instance of POBUserInfo class with required user details
  static Future<void> setUserInfo(final POBUserInfo userInfo) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag,
          methodName: 'setUserInfo',
          argument: <String, dynamic>{
            'birthYear': userInfo.birthYear,
            'gender': userInfo.gender?.index,
            'city': userInfo.city,
            'metro': userInfo.metro,
            'zip': userInfo.zip,
            'region': userInfo.region,
            'userKeywords': userInfo.userKeywords
          });

  /// Sets the DSA (Digital Services Act) required flag.
  ///
  /// [dsaComplianceStatus] DSA required flag. Values -
  ///
  /// 1. [POBDSAComplianceStatus.notRequired] = Not required
  /// 2. [POBDSAComplianceStatus.optional] = Supported, bid responses with or without the DSA object will be accepted
  /// 3. [POBDSAComplianceStatus.required] = Required, bid responses without a DSA object will not be accepted
  /// 4. [POBDSAComplianceStatus.requiredPubOnlinePlatform] = Required, bid responses without DSA object will not be accepted, Publisher is an Online Platform
  ///
  /// Default value is [POBDSAComplianceStatus.notRequired]
  static Future<void> setDSAComplianceStatus(
          final POBDSAComplianceStatus dsaComplianceStatus) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag,
          methodName: 'setDSAComplianceStatus',
          argument: dsaComplianceStatus.index);

  /// Gets the current DSA (Digital Services Act) required flag.
  ///
  /// 1. [POBDSAComplianceStatus.notRequired] = Not required
  /// 2. [POBDSAComplianceStatus.optional] = Supported, bid responses with or without the DSA object will be accepted
  /// 3. [POBDSAComplianceStatus.required] = Required, bid responses without a DSA object will not be accepted
  /// 4. [POBDSAComplianceStatus.requiredPubOnlinePlatform] = Required, bid responses without DSA object will not be accepted, Publisher is an Online Platform
  static Future<POBDSAComplianceStatus> getDSAComplianceStatus() async {
    int? dsaComplianceStatus =
        await openWrapMethodChannel.callPlatformMethodWithTag<int>(
            tag: _tag, methodName: 'getDSAComplianceStatus');

    return POBDSAComplianceStatus.values[
        dsaComplianceStatus ?? POBDSAComplianceStatus.notRequired.index];
  }

  /// API to Add the External user id /Data Partner ids which helps publisher in better user targeting
  ///
  /// [userId] instance of POBExternalUserId class
  static Future<void> addExternalUserId(final POBExternalUserId userId) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag, methodName: 'addExternalUserId', argument: userId.toMap());

  /// API to get all set external user ids
  static Future<List<POBExternalUserId>> getExternalUserIds() async {
    List<Object?>? userIdList =
        await openWrapMethodChannel.callPlatformMethodWithTag<List<Object?>>(
            tag: _tag, methodName: 'getExternalUserIds');

    if (userIdList == null) {
      return [];
    }

    return userIdList
        .map((e) => POBExternalUserId.fromMap(
            Map<String, dynamic>.from(e as Map<Object?, Object?>)))
        .toList();
  }

  /// API to remove the external user ids of a particular source
  ///
  /// [source] name of source
  static Future<void> removeExternalUserIds(final String source) =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag, methodName: 'removeExternalUserIds', argument: source);

  /// API to remove all external user ids
  static Future<void> removeAllExternalUserIds() =>
      openWrapMethodChannel.callPlatformMethodWithTag<void>(
          tag: _tag, methodName: 'removeAllExternalUserIds');
}

/// Represents the configuration for the OpenWrap Flutter plugin.
///
/// This class represents the configuration parameters required for initializing
/// the OpenWrap Flutter plugin, including the publisher ID and the list of profile IDs.
///
/// [publisherId] The Publisher ID.
/// [profileIds] The List of Profile IDs.
@immutable
class OpenWrapSDKConfig {
  final String publisherId;
  final List<int> profileIds;

  /// Creates an instance of OpenWrapSDKConfig.
  /// [publisherId] The Publisher ID.
  /// [profileIds] The List of Profile IDs.
  const OpenWrapSDKConfig(this.publisherId, this.profileIds);

  /// Returns a new copy of the OpenWrapSDKConfig with the provided values.
  /// [publisherId] The Publisher ID.
  /// [profileIds] The List of Profile IDs.
  OpenWrapSDKConfig copyWith({
    String? publisherId,
    List<int>? profileIds,
  }) {
    return OpenWrapSDKConfig(
      publisherId ?? this.publisherId,
      profileIds ?? this.profileIds,
    );
  }
}

/// Implementers will receive notifications about the success or failure of [OpenWrapSDK.initialize].
class OpenWrapSDKListener {
  OpenWrapSDKListener(
      {this.onOpenWrapSDKInitialize, this.onOpenWrapSDKInitializeError});

  /// Called when the [OpenWrapSDK.initialize] completes successfully.
  final POBSDKEvent? onOpenWrapSDKInitialize;

  /// Called when the [OpenWrapSDK.initialize] fails.
  ///
  /// [POBError] instance that contains information about the error that occurred while [OpenWrapSDK.initialize].
  final POBSDKErrorEvent? onOpenWrapSDKInitializeError;
}
