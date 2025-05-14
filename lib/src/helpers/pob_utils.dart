import '../pob_constants.dart';
import '../pob_data_types.dart';

/// Common utility class.
class POBUtils {
  /// Converts Map<String, dynamic> to [POBError] object
  static POBError convertMapToPOBError(final Map<Object?, Object?>? map) {
    int? errorCode = POBUtils.cast(map?[keyErrorCode]);
    String? message = POBUtils.cast(map?[keyErrorMessage]);
    return POBError(
      errorCode: errorCode ?? POBError.internalError,
      errorMessage: message ?? "Internal Error Occurred",
    );
  }

  /// Converts Map<String, dynamic> to [POBReward] object
  static POBReward convertMapToPOBReward(final Map<Object?, Object?>? map) {
    int? amount = POBUtils.cast<int>(map?['amount']);
    String? currencyType = POBUtils.cast<String>(map?['currencyType']);
    return POBReward(currencyType: currencyType ?? "", amount: amount ?? 0);
  }

  /// Converts a list of [POBAdSize] into a list of [Map] of width and height.
  static List<Map<String, int>> convertAdSizesToListOfMap(
      final List<POBAdSize> adSizes) {
    List<Map<String, int>> resultantList = [];
    for (final adSize in adSizes) {
      resultantList.add({'w': adSize.width, 'h': adSize.height});
    }

    return resultantList;
  }

  /// Convert [POBRequest] to [Map].
  static Map<String, dynamic> convertRequestToMap(POBRequest request) {
    Map<String, dynamic> requestMap = {};

    requestMap['debug'] = request.debug;
    requestMap['networkTimeout'] = request.getNetworkTimeout;
    requestMap['versionId'] = request.versionId;
    requestMap['testMode'] = request.testMode;
    requestMap['adServerUrl'] = request.adServerUrl;
    // requestMap['enableReturnAllBidStatus'] = request.enableReturnAllBidStatus;

    return requestMap;
  }

  /// Convert [POBImpression] to [Map]
  static Map<String, dynamic> convertImpressionToMap(
      POBImpression impression, String tag) {
    Map<String, dynamic> impressionMap = {};
    if (tag != tagPOBInterstitial && tag != tagPOBRewardedAd) {
      impressionMap['adPosition'] = impression.adPosition.index;
    }
    impressionMap['testCreativeId'] = impression.testCreativeId;
    impressionMap['customParams'] = impression.customParams;

    return impressionMap;
  }

  /// Converts Map<Object?, Object?> to Map<String, String>.
  static Map<String, String>? convertMapOfObjectToMapOfString(
      Map<Object?, Object?>? map) {
    if (map == null || map.isEmpty) {
      return null;
    }
    Map<String, String> data = {};
    map.forEach((key, value) {
      if (key != null && value != null) {
        data[key.toString()] = value.toString();
      }
    });
    return data;
  }

  /// Casts given object into expected type. Returns null otherwise
  static T? cast<T>(Object? object) => object is T ? object : null;
}
