import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:test/test.dart';

void main() {
  test('Testing Getter and Setters of UserInfo', () {
    final userInfo = POBUserInfo();
    userInfo.birthYear = 2000;
    userInfo.city = 'Pune';
    userInfo.gender = POBGender.male;
    userInfo.metro = '501';
    userInfo.region = 'IN';
    userInfo.userKeywords = 'keywords';
    userInfo.zip = 'XYZ';

    expect(userInfo.birthYear, 2000);
    expect(userInfo.city, 'Pune');
    expect(userInfo.gender, POBGender.male);
    expect(userInfo.metro, '501');
    expect(userInfo.region, 'IN');
    expect(userInfo.userKeywords, 'keywords');
    expect(userInfo.zip, 'XYZ');
  });

  test("ApplicationInfo Getter and Setters testing", () {
    final applicationInfo = POBApplicationInfo();
    //Setting dummy values
    applicationInfo.paid = true;
    applicationInfo.categories = 'IAB-1,IAB-2';
    applicationInfo.domain = 'mygame.foo.com';
    applicationInfo.appKeywords = "action";
    applicationInfo.storeURL = Uri.parse("www.google.com");

    expect(applicationInfo.paid, true);
    expect(applicationInfo.categories, "IAB-1,IAB-2");
    expect(applicationInfo.domain, 'mygame.foo.com');
    expect(applicationInfo.storeURL, Uri.parse("www.google.com"));
    expect(applicationInfo.appKeywords, "action");
  });

  group('POBError tests', () {
    String message = 'Server error';
    int errorCode = 1001;

    test('Testing Constructor of POBError', () {
      final pobError = POBError(errorCode: errorCode, errorMessage: message);
      expect(pobError, isNotNull);
      expect(pobError.errorCode, errorCode);
      expect(pobError.errorMessage, message);
    });

    test('Testing setter of POBError.message', () {
      final pobError = POBError(errorCode: errorCode, errorMessage: message);
      String expErrorMessage = 'Client error';
      pobError.errorMessage = expErrorMessage;
      expect(pobError.errorMessage, expErrorMessage);
    });

    test('Testing setter of POBError.errorCode', () {
      final pobError = POBError(errorCode: errorCode, errorMessage: message);
      int expErrorCode = 1002;
      pobError.errorCode = expErrorCode;
      expect(pobError.errorCode, expErrorCode);
    });

    test('Testing static constants of POBError', () {
      expect(POBError.invalidRequest, 1001);
      expect(POBError.noAdsAvailable, 1002);
      expect(POBError.networkError, 1003);
      expect(POBError.serverError, 1004);
      expect(POBError.timeoutError, 1005);
      expect(POBError.internalError, 1006);
      expect(POBError.invalidResponse, 1007);
      expect(POBError.requestCancelled, 1008);
      expect(POBError.renderError, 1009);
      expect(POBError.openwrapSignalingError, 1010);
      expect(POBError.adExpired, 1011);
      expect(POBError.adRequestNotAllowed, 1012);
      expect(POBError.adAlreadyShown, 2001);
      expect(POBError.adNotReady, 2002);
      expect(POBError.clientSideAuctionLost, 3001);
      expect(POBError.adServerAuctionLost, 3002);
      expect(POBError.adNotUsed, 3003);
      expect(POBError.noPartnerDetails, 4001);
      expect(POBError.invalidRewardSelected, 5001);
      expect(POBError.rewardNotSelected, 5002);
    });

    test('Test toString method', () {
      final pobError = POBError(errorCode: errorCode, errorMessage: message);
      String toStringMsg =
          'POBError{errorCode=$errorCode, errorMessage=\'$message\'}';
      expect(toStringMsg, pobError.toString());
    });
  });

  group('POBAdSize tests', () {
    int width = 320;
    int height = 50;

    test('Testing constructor of POBAdSize', () {
      POBAdSize adSize = POBAdSize(width: width, height: height);
      expect(adSize, isNotNull);
      expect(adSize.width, width);
      expect(adSize.height, height);
    });

    test('Testing toString method of POBAdSize', () {
      POBAdSize adSize = POBAdSize(width: width, height: height);
      String toStringMsg = '${width}x$height';
      expect(adSize.toString(), toStringMsg);
    });

    test('Testing static constants of POBAdSize', () {
      expect(POBAdSize.bannerSize320x50.width, 320);
      expect(POBAdSize.bannerSize320x50.height, 50);

      expect(POBAdSize.bannerSize320x100.width, 320);
      expect(POBAdSize.bannerSize320x100.height, 100);

      expect(POBAdSize.bannerSize300x250.width, 300);
      expect(POBAdSize.bannerSize300x250.height, 250);

      expect(POBAdSize.bannerSize250x250.width, 250);
      expect(POBAdSize.bannerSize250x250.height, 250);

      expect(POBAdSize.bannerSize468x60.width, 468);
      expect(POBAdSize.bannerSize468x60.height, 60);

      expect(POBAdSize.bannerSize728x90.width, 728);
      expect(POBAdSize.bannerSize728x90.height, 90);

      expect(POBAdSize.bannerSize768x90.width, 768);
      expect(POBAdSize.bannerSize768x90.height, 90);

      expect(POBAdSize.bannerSize120x600.width, 120);
      expect(POBAdSize.bannerSize120x600.height, 600);
    });
  });

  test('POBRequest', () {
    POBRequest request = POBRequest();
    request.setNetworkTimeout = 34;
    expect(request.getNetworkTimeout, 34);
  });

  group('POBBid tests', () {
    test('POBBid tests with valid inputs', () {
      Map<Object?, Object?> bidMap = {
        'bidId': 'bid_id',
        'impressionId': 'impression_id',
        'bundle': 'bundle_id',
        'price': 3.0,
        'width': POBAdSize.bannerSize320x50.width,
        'height': POBAdSize.bannerSize320x50.height,
        'status': 1,
        'creativeId': 'creative_id',
        'nurl': 'https://pubmatic.com/nurl',
        'lurl': 'https://pubmatic.com/lurl',
        'creative': 'test_creative',
        'creativeType': 'display',
        'partnerName': 'pubmatic',
        'dealId': 'deal_id',
        'refreshInterval': 60,
        'targetingInfo': {'a': '0', 'b': '1'},
        'rewardAmount': 50,
        'rewardCurrencyType': 'coin'
      };

      POBBid bid = POBBid.fromMap(bidMap);
      expect(bid, isNotNull);
      expect(bid.bidId, 'bid_id');
      expect(bid.impressionId, 'impression_id');
      expect(bid.bundle, 'bundle_id');
      expect(bid.price, 3.0);
      expect(bid.width, POBAdSize.bannerSize320x50.width);
      expect(bid.height, POBAdSize.bannerSize320x50.height);
      expect(bid.status, 1);
      expect(bid.creativeId, 'creative_id');
      expect(bid.nurl, 'https://pubmatic.com/nurl');
      expect(bid.lurl, 'https://pubmatic.com/lurl');
      expect(bid.creative, 'test_creative');
      expect(bid.creativeType, 'display');
      expect(bid.partnerName, 'pubmatic');
      expect(bid.dealId, 'deal_id');
      expect(bid.refreshInterval, 60);
      expect(bid.targetingInfo, {'a': '0', 'b': '1'});
      expect(bid.rewardAmount, 50);
      expect(bid.rewardCurrencyType, 'coin');
    });

    test('POBBid tests with invalid inputs', () {
      Map<Object?, Object?> bidMap = {
        'price': 1,
        'width': POBAdSize.bannerSize320x50.width,
        'height': POBAdSize.bannerSize320x50.height,
        'status': 1,
        'refreshInterval': 60,
        'targetingInfo': {'a': '0', 'b': 1},
        'rewardAmount': 50,
        'rewardCurrencyType': 'coin'
      };

      POBBid bid = POBBid.fromMap(bidMap);
      expect(bid, isNotNull);

      /// price expects double value. It is set to 0.0 for invalid data
      expect(bid.price, 0.0);

      expect(bid.width, POBAdSize.bannerSize320x50.width);
      expect(bid.height, POBAdSize.bannerSize320x50.height);
      expect(bid.status, 1);

      /// Optional properties are null by default
      expect(bid.creativeType, isNull);

      expect(bid.refreshInterval, 60);

      expect(bid.targetingInfo, {'a': '0', 'b': '1'});
      expect(bid.rewardAmount, 50);
      expect(bid.rewardCurrencyType, 'coin');
    });
  });
}
