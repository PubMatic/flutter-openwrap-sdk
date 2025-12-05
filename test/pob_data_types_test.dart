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

    POBRequest request2 = POBRequest();
    request2.setNetworkTimeout = -23;
    expect(request2.getNetworkTimeout, 5);
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

  group('POBReward tests', () {
    test('POBReward constructor and toString method', () {
      // Test with typical reward values
      POBReward reward1 = POBReward(currencyType: 'coins', amount: 100);
      expect(reward1.currencyType, 'coins');
      expect(reward1.amount, 100);
      expect(reward1.toString(),
          'POBReward{currencyType=\'coins\', amount=\'100\'}');

      // Test with different currency type and amount
      POBReward reward2 = POBReward(currencyType: 'points', amount: 50);
      expect(reward2.currencyType, 'points');
      expect(reward2.amount, 50);
      expect(reward2.toString(),
          'POBReward{currencyType=\'points\', amount=\'50\'}');

      // Test with zero amount
      POBReward reward3 = POBReward(currencyType: 'gems', amount: 0);
      expect(
          reward3.toString(), 'POBReward{currencyType=\'gems\', amount=\'0\'}');

      // Test with negative amount (edge case)
      POBReward reward4 = POBReward(currencyType: 'lives', amount: -1);
      expect(reward4.toString(),
          'POBReward{currencyType=\'lives\', amount=\'-1\'}');

      // Test with empty currency type
      POBReward reward5 = POBReward(currencyType: '', amount: 25);
      expect(reward5.toString(), 'POBReward{currencyType=\'\', amount=\'25\'}');

      // Test with special characters in currency type
      POBReward reward6 =
          POBReward(currencyType: 'test\'s currency', amount: 999);
      expect(reward6.toString(),
          'POBReward{currencyType=\'test\'s currency\', amount=\'999\'}');

      // Test with large amount
      POBReward reward7 = POBReward(currencyType: 'dollars', amount: 1000000);
      expect(reward7.toString(),
          'POBReward{currencyType=\'dollars\', amount=\'1000000\'}');
    });
  });

  group('POBExternalUserId tests', () {
    test('Testing constructor with required parameters only', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'liveramp.com',
        id: 'user123',
      );

      expect(externalUserId.source, 'liveramp.com');
      expect(externalUserId.id, 'user123');
      expect(externalUserId.atype, 0); // Default value
      expect(externalUserId.ext, isNull);
    });

    test('Testing constructor with all parameters', () {
      Map<String, dynamic> extMap = {'consent': 'granted', 'version': '1.0'};

      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'adserver.org',
        id: 'xyz789',
        atype: 1,
        ext: extMap,
      );

      expect(externalUserId.source, 'adserver.org');
      expect(externalUserId.id, 'xyz789');
      expect(externalUserId.atype, 1);
      expect(externalUserId.ext, extMap);
    });

    test('Testing toMap method with required parameters only', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'liveramp.com',
        id: 'user123',
      );

      Map<String, dynamic> result = externalUserId.toMap();

      expect(result['source'], 'liveramp.com');
      expect(result['id'], 'user123');
      expect(result['atype'], 0);
      expect(result.containsKey('ext'), false); // ext should not be in map
    });

    test('Testing toMap method with all parameters', () {
      Map<String, dynamic> extMap = {'key': 'value'};

      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'adserver.org',
        id: 'xyz789',
        atype: 2,
        ext: extMap,
      );

      Map<String, dynamic> result = externalUserId.toMap();

      expect(result['source'], 'adserver.org');
      expect(result['id'], 'xyz789');
      expect(result['atype'], 2);
      expect(result['ext'], extMap);
    });

    test('Testing fromMap method with all parameters', () {
      Map<String, dynamic> inputMap = {
        'source': 'criteo.com',
        'id': 'abc456',
        'atype': 3,
        'ext': {'param1': 'value1', 'param2': 'value2'}
      };

      POBExternalUserId externalUserId = POBExternalUserId.fromMap(inputMap);

      expect(externalUserId.source, 'criteo.com');
      expect(externalUserId.id, 'abc456');
      expect(externalUserId.atype, 3);
      expect(externalUserId.ext, isNotNull);
      expect(externalUserId.ext!['param1'], 'value1');
      expect(externalUserId.ext!['param2'], 'value2');
    });

    test('Testing fromMap method with missing optional parameters', () {
      Map<String, dynamic> inputMap = {
        'source': 'liveramp.com',
        'id': 'user123',
      };

      POBExternalUserId externalUserId = POBExternalUserId.fromMap(inputMap);

      expect(externalUserId.source, 'liveramp.com');
      expect(externalUserId.id, 'user123');
      expect(externalUserId.atype, 0); // Default value
      expect(externalUserId.ext, isNull);
    });

    test('Testing fromMap method with null values', () {
      Map<String, dynamic> inputMap = {
        'source': null,
        'id': null,
        'atype': null,
        'ext': null,
      };

      POBExternalUserId externalUserId = POBExternalUserId.fromMap(inputMap);

      expect(externalUserId.source, ''); // Default empty string
      expect(externalUserId.id, ''); // Default empty string
      expect(externalUserId.atype, 0); // Default value
      expect(externalUserId.ext, isNull);
    });

    test('Testing fromMap method with nested ext map', () {
      Map<String, dynamic> inputMap = {
        'source': 'datasource.com',
        'id': 'nested123',
        'atype': 1,
        'ext': {
          'level1': {
            'level2': {'level3': 'deep value'}
          },
          'array': [1, 2, 3]
        }
      };

      POBExternalUserId externalUserId = POBExternalUserId.fromMap(inputMap);

      expect(externalUserId.source, 'datasource.com');
      expect(externalUserId.id, 'nested123');
      expect(externalUserId.atype, 1);
      expect(externalUserId.ext, isNotNull);
      expect(externalUserId.ext!['level1'], isA<Map<String, dynamic>>());
      expect(externalUserId.ext!['level1']['level2']['level3'], 'deep value');
      expect(externalUserId.ext!['array'], [1, 2, 3]);
    });

    test('Testing toString method with ext null', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'test.com',
        id: 'testId',
        atype: 5,
      );

      String result = externalUserId.toString();
      expect(result,
          'POBExternalUserId{source: test.com, id: testId, atype: 5, ext: null}');
    });

    test('Testing toString method with ext present', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'test.com',
        id: 'testId',
        atype: 5,
        ext: {'key': 'value'},
      );

      String result = externalUserId.toString();
      expect(
          result,
          'POBExternalUserId{source: test.com, id: testId, atype: 5, ext: '
          '{key: value}}');
    });

    test('Testing atype mutation', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'test.com',
        id: 'testId',
        atype: 1,
      );

      expect(externalUserId.atype, 1);

      externalUserId.atype = 10;
      expect(externalUserId.atype, 10);
    });

    test('Testing ext mutation', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'test.com',
        id: 'testId',
      );

      expect(externalUserId.ext, isNull);

      Map<String, dynamic> newExt = {'updated': 'value'};
      externalUserId.ext = newExt;
      expect(externalUserId.ext, newExt);
      expect(externalUserId.ext!['updated'], 'value');
    });

    test('Testing with empty strings', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: '',
        id: '',
        atype: 0,
      );

      expect(externalUserId.source, '');
      expect(externalUserId.id, '');

      Map<String, dynamic> result = externalUserId.toMap();
      expect(result['source'], '');
      expect(result['id'], '');
    });

    test('Testing roundtrip conversion (toMap and fromMap)', () {
      POBExternalUserId original = POBExternalUserId(
        source: 'roundtrip.com',
        id: 'user999',
        atype: 7,
        ext: {
          'test': 'data',
          'nested': {'inner': 'value'}
        },
      );

      Map<String, dynamic> map = original.toMap();
      POBExternalUserId reconstructed = POBExternalUserId.fromMap(map);

      expect(reconstructed.source, original.source);
      expect(reconstructed.id, original.id);
      expect(reconstructed.atype, original.atype);
      expect(reconstructed.ext!['test'], original.ext!['test']);
      expect(reconstructed.ext!['nested']['inner'],
          original.ext!['nested']['inner']);
    });

    test('Testing with special characters in source and id', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'source-with-special.chars_123',
        id: r'id@with#special$chars%',
      );

      expect(externalUserId.source, 'source-with-special.chars_123');
      expect(externalUserId.id, r'id@with#special$chars%');

      String result = externalUserId.toString();
      expect(result, contains('source-with-special.chars_123'));
      expect(result, contains(r'id@with#special$chars%'));
    });

    test('Testing with very large atype value', () {
      POBExternalUserId externalUserId = POBExternalUserId(
        source: 'test.com',
        id: 'testId',
        atype: 999999,
      );

      expect(externalUserId.atype, 999999);

      Map<String, dynamic> map = externalUserId.toMap();
      expect(map['atype'], 999999);

      POBExternalUserId reconstructed = POBExternalUserId.fromMap(map);
      expect(reconstructed.atype, 999999);
    });

    test('Testing fromMap with empty ext map', () {
      Map<String, dynamic> inputMap = {
        'source': 'test.com',
        'id': 'testId',
        'ext': {}
      };

      POBExternalUserId externalUserId = POBExternalUserId.fromMap(inputMap);

      expect(externalUserId.ext, isNotNull);
      expect(externalUserId.ext!.isEmpty, true);
    });
  });
}
