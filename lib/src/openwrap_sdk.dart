import 'dart:io';
import 'pob_data_types.dart';
import 'openwrap_sdk_method_channel.dart';

/// Provides global configurations for the OpenWrap SDK, e.g., enabling logging,
/// location access, GDPR, etc. These configurations are globally applicable for
/// OpenWrap SDK; you don't have to set these for every ad request.
class OpenWrapSDK {
  static const String _tag = 'OpenWrapSDK';

  static Future<void> initialize(
      {required String publisherId, required List<int> profileIds}) async {
    // Initialize the OpenWrap SDK with the provided publisher ID and profile IDs
    await openWrapMethodChannel.callPlatformMethodWithTag<void>(
      tag: _tag,
      methodName: 'init',
      argument: <String, dynamic>{
        'publisherId': publisherId,
        'profileIds': profileIds,
      },
    );
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
}
