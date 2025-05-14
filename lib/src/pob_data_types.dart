import 'dart:developer';
import 'helpers/pob_utils.dart';

import 'pob_constants.dart';

/// Provides setters to pass user information
class POBUserInfo {
  /// The year of birth in YYYY format.
  /// Example :
  /// adRequest.setBirthYear(1988);
  int? birthYear;

  /// Set the user gender,
  /// Possible options are:
  /// OTHER
  /// MALE,
  /// FEMALE
  POBGender? gender;

  /// City of user
  /// For example: setCity("London");
  String? city;

  /// Google metro code, You can set Designated market area (DMA) code of the user
  /// in this field. This field is applicable for US users only
  /// For example, New York, NY is also known as 501. Los Angeles, CA, on the
  /// other hand has been assigned the number 803.
  String? metro;

  /// The user's zip code may be useful in delivering geographically relevant ads
  String? zip;

  /// Region code using ISO-3166-2; 2-letter state code if USA
  String? region;

  /// Comma separated list of keywords, interests, or intent.
  String? userKeywords;
}

/// Provides setters to pass application information like store URL, domain,
/// IAB categories etc.
/// It is very important to provide transparency for buyers of your app inventory.
class POBApplicationInfo {
  /// Indicates the domain of the mobile application (e.g., "mygame.foo.com")
  String? domain;

  /// URL of application on Play store
  /// Sets URL of application on Play store. It is mandatory to pass a valid
  /// storeURL. It is very important for platform identification.
  Uri? storeURL;

  /// Indicates whether the mobile application is a paid version or not.
  /// Possible values are:
  /// false - Free version
  /// true - Paid version
  bool? paid;

  /// Comma separated list of IAB categories for the application. e.g. "IAB-1, IAB-2"
  String? categories;

  /// Comma separated list of keywords about the app
  String? appKeywords;
}

/// Defines gender of user
enum POBGender { male, female, other }

/// Enum to define the location source.
enum POBLocationSource {
  /// Indicates that location is inferred using the platform specific APIs
  gps,

  /// Indicates that location is inferred using IP address
  ipAddress,

  /// Indicates that location is provided by application user.
  user
}

///Log levels to filter logs
enum POBLogLevel {
  /// All level of logs
  all,

  /// Error, warning, info, debug and verbose logs
  verbose,

  /// Error, warning, info and debug logs
  debug,

  /// Error, warning and info logs
  info,

  /// Error and warning logs
  warn,

  /// Error logs only
  error,

  /// No logs
  off
}

/// Error codes OpenWrapSDK gives in error callback.
class POBError {
  /// You may not passing mandatory parameters like Publisher ID, Sizes
  /// and other ad tag details.
  static const invalidRequest = 1001;

  /// There was no ads available to deliver for ad request.
  static const noAdsAvailable = 1002;

  /// There was an error while retrieving the data from the network.
  static const networkError = 1003;

  /// Failed to process ad request by Ad Server.
  static const serverError = 1004;

  /// Ad request was timed out.
  static const timeoutError = 1005;

  /// Internal error.
  static const internalError = 1006;

  /// Invalid ad response. SDK does not able to parse the response received from Server.
  static const invalidResponse = 1007;

  /// Ad request gets cancelled.
  static const requestCancelled = 1008;

  /// There was some issue while rendering the creative.
  static const renderError = 1009;

  /// Ad server SDK sent unexpected/delayed OpenWrap win response.
  static const openwrapSignalingError = 1010;

  /// Indicates an ad is expired.
  static const adExpired = 1011;

  /// Indicates an ad request is not allowed.
  static const adRequestNotAllowed = 1012;

  /// Indicates an Ad is already shown.
  static const adAlreadyShown = 2001;

  /// Indicates an Ad is not ready to show yet.
  static const adNotReady = 2002;

  /// Indicates error due to client side auction loss.
  static const clientSideAuctionLost = 3001;

  /// Indicates error due to ad server side auction loss.
  static const adServerAuctionLost = 3002;

  /// Indicates error due to ad not used.
  static const adNotUsed = 3003;

  /// Indicates partner details are not found.
  static const noPartnerDetails = 4001;

  /// Indicates invalid reward selection.
  static const invalidRewardSelected = 5001;

  /// Indicates Rewarded ad has encountered some configuration error.
  static const rewardNotSelected = 5002;

  int errorCode;

  String errorMessage;

  POBError({required this.errorCode, required this.errorMessage});

  @override
  String toString() {
    return 'POBError{errorCode=$errorCode, errorMessage=\'$errorMessage\'}';
  }
}

/// Defines size of an ad.
class POBAdSize {
  /// Most used Banner Ad Size for android phone, iPhone, tablet and iPad
  static final bannerSize320x50 = POBAdSize(width: 320, height: 50);
  static final bannerSize320x100 = POBAdSize(width: 320, height: 100);
  static final bannerSize300x250 = POBAdSize(width: 300, height: 250);
  static final bannerSize250x250 = POBAdSize(width: 250, height: 250);

  /// Most used Banner Ad Size for tablet and iPad
  static final bannerSize468x60 = POBAdSize(width: 468, height: 60);
  static final bannerSize728x90 = POBAdSize(width: 728, height: 90);
  static final bannerSize768x90 = POBAdSize(width: 768, height: 90);
  static final bannerSize120x600 = POBAdSize(width: 120, height: 600);

  /// Width parameter of an ad.
  final int width;

  /// Height parameter of an ad.
  final int height;

  POBAdSize({required this.width, required this.height});

  @override
  String toString() {
    return '${width}x$height';
  }
}

/// Class to represent the OpenWrap ad request.
class POBRequest {
  /// Enable/Disable debug information in the response.
  /// By default, debug is disabled and no debug information will be available
  /// in bid response.
  /// False means no debug information will be available
  bool debug = false;

  /// Maximum network timeout for Ad request.
  /// Default time out is 5 seconds.
  int _networkTimeoutInSec = 5;

  /// Disables bid summary that is sent in the response, if true.
  /// Default value is false.
  bool enableReturnAllBidStatus = false;

  /// This is used to specify OpenWrap version Id of the publisher.
  /// If this is not specified, live version of the profile is considered.
  int? versionId;

  /// Indicates whether this request is a test request.
  /// By default, mode is disabled.
  /// When enabled, this request is treated as a test request.
  /// PubMatic may deliver only test ads which are not billable.
  /// Please disable the Test Mode for requests before you submit your
  /// application to the play store.
  bool testMode = false;

  /// Custom server URL for debugging purpose.
  /// If it is set, ad request will be made to the provided url
  String? adServerUrl;

  /// Network timeout (in seconds) for making an Ad request.
  /// Default value is 5 seconds. Provided value should be greater than 0.
  int get getNetworkTimeout => _networkTimeoutInSec;

  set setNetworkTimeout(int networkTimeoutInSec) {
    if (networkTimeoutInSec > 0) {
      _networkTimeoutInSec = networkTimeoutInSec;
    } else {
      log('Please provide network timeout value greater than 0.');
    }
  }
}

/// Class to represent the OpenWrap ad impression
class POBImpression {
  /// This parameter is used to request a test creative.
  String? testCreativeId;

  /// Fold placement of the ad to be served.
  /// For the possible values refer: [POBAdPosition]
  /// Default is [POBAdPosition.unknown]
  POBAdPosition adPosition = POBAdPosition.unknown;

  /// Custom parameters in the form of a Map. To set multiple values against same key,
  /// use array. Only use list of string as values.
  Map<String, List<String>>? customParams;
}

/// Class to hold information of rewards.
class POBReward {
  /// Parameter for the type of reward
  String currencyType;

  /// Parameter for amount of reward
  int amount;

  POBReward({required this.currencyType, required this.amount});

  @override
  String toString() {
    return 'POBReward{currencyType=\'$currencyType\', amount=\'$amount\'}';
  }
}

/// Fold placement of the ad to be served.
enum POBAdPosition {
  /// Unable to determine the ad position, use this value
  unknown,

  /// Ad position is visible
  aboveTheFold,

  /// Ad position is not visible and it needs user to scroll the page to make it visible
  belowTheFold,

  /// Header position
  header,

  /// Footer position
  footer,

  /// In side menu
  sidebar,

  /// Ad is in full screen
  fullScreen
}

/// Holds information of winning bid along with all the bids that participated in the auction.
class POBBid {
  /// Bid id of the bid
  String? bidId;

  /// Impression Id. Also used as a bid id
  String? impressionId;

  /// Bundle / itunes id of the advertised app
  String? bundle;

  /// Net Ecpm price / bid value
  late double price;

  /// Width of bid creative
  late int width;

  /// Height of bid creative
  late int height;

  /// Bid status.
  /// Bid status is 1 if ecpm price is greater than 0 else it is 0.
  late int status;

  /// Identifier of the bid creative
  String? creativeId;

  /// Win notice URL called by the exchange if the bid wins
  String? nurl;

  /// Loss notice URL called by the exchange if the bid lose.
  String? lurl;

  /// Ad creative
  String? creative;

  /// Creative type
  String? creativeType;

  /// Name of the winning partner
  String? partnerName;

  /// Deal Id. Used for PMP deals.
  String? dealId;

  /// Refresh interval in seconds
  late int refreshInterval;

  /// Map of targeting information, that needs to be passed to ad server SDK.
  /// If the bid is not valid bid (check with its status) it returns null
  /// else returns valid bid targeting info map
  Map<String, String>? targetingInfo;

  /// Reward amount to offer to the user
  /// null if no reward found
  int? rewardAmount;

  /// Currency for the reward, e.g. coin, life, etc.
  /// null if no reward found
  String? rewardCurrencyType;

  /// Private constructor
  POBBid._();

  /// Named constructor that creates and returns [POBBid] using Map<Object?, Object?>
  static POBBid fromMap(final Map<Object?, Object?>? map) {
    POBBid bid = POBBid._()
      ..bidId = POBUtils.cast(map?[keyBidId])
      ..impressionId = POBUtils.cast(map?[keyImpressionId])
      ..height = POBUtils.cast(map?[keyHeight]) ?? 0
      ..width = POBUtils.cast(map?[keyWidth]) ?? 0
      ..bundle = POBUtils.cast(map?[keyBundle])
      ..creative = POBUtils.cast(map?[keyCreative])
      ..creativeId = POBUtils.cast(map?[keyCreativeId])
      ..creativeType = POBUtils.cast(map?[keyCreativeType])
      ..dealId = POBUtils.cast(map?[keyDealId])
      ..lurl = POBUtils.cast(map?[keyLurl])
      ..nurl = POBUtils.cast(map?[keyNurl])
      ..partnerName = POBUtils.cast(map?[keyPartnerName])
      ..price = POBUtils.cast(map?[keyPrice]) ?? 0.0
      ..refreshInterval = POBUtils.cast(map?[keyRefreshInterval]) ?? 0
      ..rewardAmount = POBUtils.cast(map?[keyRewardAmount])
      ..rewardCurrencyType = POBUtils.cast(map?[keyRewardCurrencyType])
      ..status = POBUtils.cast(map?[keyStatus]) ?? 0
      ..targetingInfo = POBUtils.convertMapOfObjectToMapOfString(
          POBUtils.cast<Map<Object?, Object?>>(map?[keyTargetingInfo]));
    return bid;
  }
}
