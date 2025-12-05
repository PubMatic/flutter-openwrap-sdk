import 'package:test/test.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:flutter_openwrap_sdk/src/helpers/pob_utils.dart';

void main() {
  group('convertMapToPOBError method tests', () {
    test('Testing with valid errorCode and message', () {
      int errorCode = 1001;
      String errorMessage = 'Server error';
      Map errorMap = {'errorCode': errorCode, 'errorMessage': errorMessage};
      POBError? error = POBUtils.convertMapToPOBError(errorMap);
      expect(error, isNotNull);
      expect(error.errorCode, errorCode);
      expect(error.errorMessage, errorMessage);
    });

    test('Testing with invalid errorCode', () {
      double errorCode = 10.5;
      String errorMessage = 'Server error';
      Map errorMap = {'errorCode': errorCode, 'errorMessage': errorMessage};
      POBError? error = POBUtils.convertMapToPOBError(errorMap);
      expect(error, isNotNull);
      expect(error.errorCode, POBError.internalError);
      expect(error.errorMessage, 'Server error');
    });

    test('Testing with invalid message', () {
      int errorCode = 1001;
      int errorMessage = 999;
      Map errorMap = {'errorCode': errorCode, 'errorMessage': errorMessage};
      POBError? error = POBUtils.convertMapToPOBError(errorMap);
      expect(error, isNotNull);
      expect(error.errorCode, errorCode);
      expect(error.errorMessage, "Internal Error Occurred");
    });

    test('Testing with null errorCode', () {
      int? errorCode;
      String errorMessage = 'Server error';
      Map errorMap = {'errorCode': errorCode, 'errorMessage': errorMessage};
      POBError? error = POBUtils.convertMapToPOBError(errorMap);
      expect(error, isNotNull);
      expect(error.errorCode, POBError.internalError);
      expect(error.errorMessage, "Server error");
    });

    test('Testing with null message', () {
      int errorCode = 1001;
      String? errorMessage;
      Map errorMap = {'errorCode': errorCode, 'errorMessage': errorMessage};
      POBError? error = POBUtils.convertMapToPOBError(errorMap);
      expect(error, isNotNull);
      expect(error.errorCode, errorCode);
      expect(error.errorMessage, "Internal Error Occurred");
    });

    test('Testing with null map', () {
      POBError error = POBUtils.convertMapToPOBError(null);
      expect(error, isNotNull);
      expect(error.errorCode, POBError.internalError);
      expect(error.errorMessage, "Internal Error Occurred");
    });

    test('Testing with empty map', () {
      Map<String, dynamic> errorMap = {};
      POBError error = POBUtils.convertMapToPOBError(errorMap);
      expect(error, isNotNull);
      expect(error.errorCode, POBError.internalError);
      expect(error.errorMessage, "Internal Error Occurred");
    });
  });

  group('convertMapToPOBReward method tests', () {
    test('Testing with valid amount and currencyType', () {
      int amount = 100;
      String currencyType = 'coins';
      Map rewardMap = {'amount': amount, 'currencyType': currencyType};
      POBReward reward = POBUtils.convertMapToPOBReward(rewardMap);
      expect(reward, isNotNull);
      expect(reward.amount, amount);
      expect(reward.currencyType, currencyType);
    });

    test('Testing with invalid amount', () {
      String amount = 'invalid';
      String currencyType = 'coins';
      Map rewardMap = {'amount': amount, 'currencyType': currencyType};
      POBReward reward = POBUtils.convertMapToPOBReward(rewardMap);
      expect(reward, isNotNull);
      expect(reward.amount, 0); // Default value
      expect(reward.currencyType, currencyType);
    });

    test('Testing with invalid currencyType', () {
      int amount = 100;
      int currencyType = 123;
      Map rewardMap = {'amount': amount, 'currencyType': currencyType};
      POBReward reward = POBUtils.convertMapToPOBReward(rewardMap);
      expect(reward, isNotNull);
      expect(reward.amount, amount);
      expect(reward.currencyType, ""); // Default value
    });

    test('Testing with null amount', () {
      int? amount;
      String currencyType = 'coins';
      Map rewardMap = {'amount': amount, 'currencyType': currencyType};
      POBReward reward = POBUtils.convertMapToPOBReward(rewardMap);
      expect(reward, isNotNull);
      expect(reward.amount, 0); // Default value
      expect(reward.currencyType, currencyType);
    });

    test('Testing with null currencyType', () {
      int amount = 100;
      String? currencyType;
      Map rewardMap = {'amount': amount, 'currencyType': currencyType};
      POBReward reward = POBUtils.convertMapToPOBReward(rewardMap);
      expect(reward, isNotNull);
      expect(reward.amount, amount);
      expect(reward.currencyType, ""); // Default value
    });

    test('Testing with null map', () {
      POBReward reward = POBUtils.convertMapToPOBReward(null);
      expect(reward, isNotNull);
      expect(reward.amount, 0); // Default value
      expect(reward.currencyType, ""); // Default value
    });

    test('Testing with empty map', () {
      Map<String, dynamic> rewardMap = {};
      POBReward reward = POBUtils.convertMapToPOBReward(rewardMap);
      expect(reward, isNotNull);
      expect(reward.amount, 0); // Default value
      expect(reward.currencyType, ""); // Default value
    });
  });

  group('convertAdSizesToListOfMap method tests', () {
    test('Testing count of items in returned list', () {
      POBAdSize adSize1 = POBAdSize(width: 100, height: 100);
      POBAdSize adSize2 = POBAdSize(width: 200, height: 200);
      List convertedAdSizes =
          POBUtils.convertAdSizesToListOfMap([adSize1, adSize2]);
      expect(convertedAdSizes, isNotNull);
      expect(convertedAdSizes.length, 2);
    });

    test('Testing values of returned list', () {
      int width = 100;
      int height = 50;
      POBAdSize pobAdSize = POBAdSize(width: width, height: height);
      List convertedAdSizes = POBUtils.convertAdSizesToListOfMap([pobAdSize]);
      expect(convertedAdSizes.length, 1);
      Map<String, int> expectedAdSize =
          convertedAdSizes.first as Map<String, int>;
      expect(expectedAdSize, isNotNull);
      expect(expectedAdSize["w"], 100);
      expect(expectedAdSize["h"], 50);
    });

    test('Testing with empty list', () {
      List<POBAdSize> emptyList = [];
      List convertedAdSizes = POBUtils.convertAdSizesToListOfMap(emptyList);
      expect(convertedAdSizes, isNotNull);
      expect(convertedAdSizes.length, 0);
    });
  });

  group('convertRequestToMap method tests', () {
    test('Testing with valid POBRequest', () {
      POBRequest request = POBRequest();
      request.debug = true;
      request.setNetworkTimeout = 30;
      request.versionId = 2;
      request.testMode = true;
      request.adServerUrl = 'https://test.com';
      request.returnAllBidStatus = false;

      Map<String, dynamic> result = POBUtils.convertRequestToMap(request);
      expect(result, isNotNull);
      expect(result['debug'], true);
      expect(result['networkTimeout'], 30);
      expect(result['versionId'], 2);
      expect(result['testMode'], true);
      expect(result['adServerUrl'], 'https://test.com');
      expect(result['returnAllBidStatus'], false);
    });

    test('Testing with default POBRequest values', () {
      POBRequest request = POBRequest();
      Map<String, dynamic> result = POBUtils.convertRequestToMap(request);
      expect(result, isNotNull);
      expect(result.containsKey('debug'), true);
      expect(result.containsKey('networkTimeout'), true);
      expect(result.containsKey('versionId'), true);
      expect(result.containsKey('testMode'), true);
      expect(result.containsKey('adServerUrl'), true);
      expect(result.containsKey('returnAllBidStatus'), true);
    });
  });

  group('convertImpressionToMap method tests', () {
    test('Testing with banner tag (includes adPosition)', () {
      POBImpression impression = POBImpression();
      impression.adPosition = POBAdPosition.header;
      impression.testCreativeId = 'test123';
      impression.customParams = {
        'key1': ['value1', 'value2']
      };
      impression.gpid = 'test-gpid';

      Map<String, dynamic> result =
          POBUtils.convertImpressionToMap(impression, 'POBBannerView');
      expect(result, isNotNull);
      expect(result['adPosition'], POBAdPosition.header.index);
      expect(result['testCreativeId'], 'test123');
      expect(result['customParams'], {
        'key1': ['value1', 'value2']
      });
      expect(result['gpid'], 'test-gpid');
    });

    test('Testing with interstitial tag (excludes adPosition)', () {
      POBImpression impression = POBImpression();
      impression.adPosition = POBAdPosition.header;
      impression.testCreativeId = 'test123';
      impression.customParams = {
        'key1': ['value1']
      };
      impression.gpid = 'test-gpid';

      Map<String, dynamic> result =
          POBUtils.convertImpressionToMap(impression, 'POBInterstitial');
      expect(result, isNotNull);
      expect(result.containsKey('adPosition'),
          false); // Should not include adPosition
      expect(result['testCreativeId'], 'test123');
      expect(result['customParams'], {
        'key1': ['value1']
      });
      expect(result['gpid'], 'test-gpid');
    });

    test('Testing with rewarded ad tag (excludes adPosition)', () {
      POBImpression impression = POBImpression();
      impression.adPosition = POBAdPosition.footer;
      impression.testCreativeId = 'rewarded123';
      impression.customParams = {
        'reward': ['coins']
      };
      impression.gpid = 'rewarded-gpid';

      Map<String, dynamic> result =
          POBUtils.convertImpressionToMap(impression, 'POBRewardedAd');
      expect(result, isNotNull);
      expect(result.containsKey('adPosition'),
          false); // Should not include adPosition
      expect(result['testCreativeId'], 'rewarded123');
      expect(result['customParams'], {
        'reward': ['coins']
      });
      expect(result['gpid'], 'rewarded-gpid');
    });

    test('Testing with null values', () {
      POBImpression impression = POBImpression();
      impression.testCreativeId = null;
      impression.customParams = null;
      impression.gpid = null;

      Map<String, dynamic> result =
          POBUtils.convertImpressionToMap(impression, 'POBBannerView');
      expect(result, isNotNull);
      expect(
          result['adPosition'], POBAdPosition.unknown.index); // Default value
      expect(result['testCreativeId'], null);
      expect(result['customParams'], null);
      expect(result['gpid'], null);
    });
  });

  group('cast method tests', () {
    test('Testing successful cast to int', () {
      Object value = 42;
      int? result = POBUtils.cast<int>(value);
      expect(result, 42);
    });

    test('Testing successful cast to String', () {
      Object value = 'hello';
      String? result = POBUtils.cast<String>(value);
      expect(result, 'hello');
    });

    test('Testing successful cast to bool', () {
      Object value = true;
      bool? result = POBUtils.cast<bool>(value);
      expect(result, true);
    });

    test('Testing failed cast (int to String)', () {
      Object value = 42;
      String? result = POBUtils.cast<String>(value);
      expect(result, null);
    });

    test('Testing failed cast (String to int)', () {
      Object value = 'hello';
      int? result = POBUtils.cast<int>(value);
      expect(result, null);
    });

    test('Testing cast with null object', () {
      Object? value = null;
      int? result = POBUtils.cast<int>(value);
      expect(result, null);
    });

    test('Testing cast to List', () {
      Object value = [1, 2, 3];
      List<int>? result = POBUtils.cast<List<int>>(value);
      expect(result, [1, 2, 3]);
    });

    test('Testing cast to Map', () {
      Object value = {'key': 'value'};
      Map<String, String>? result = POBUtils.cast<Map<String, String>>(value);
      expect(result, {'key': 'value'});
    });
  });

  group('convertMapOfObjectToMapOfString method tests', () {
    test('Convert map of object to map of string util method test', () {
      //Return null case.
      expect(POBUtils.convertMapOfObjectToMapOfString(null), isNull);
      expect(POBUtils.convertMapOfObjectToMapOfString({}), isNull);

      //Passing targeting.
      Map<Object?, Object?> targeting = {
        'a': 'b',
        'c': null,
        null: null,
        // ignore: equal_keys_in_map
        null: 'd',
        3: 5,
        4.5: true
      };
      expect(POBUtils.convertMapOfObjectToMapOfString(targeting),
          <String, String>{'a': 'b', '3': '5', '4.5': 'true'});
    });

    test('Testing with empty map after filtering', () {
      Map<Object?, Object?> targeting = {
        null: null,
        'key': null,
        null: 'value',
      };
      Map<String, String>? result =
          POBUtils.convertMapOfObjectToMapOfString(targeting);
      expect(result, isNotNull);
      expect(result, <String, String>{});
    });

    test('Testing with mixed valid and invalid entries', () {
      Map<Object?, Object?> targeting = {
        'valid1': 'value1',
        'valid2': 'value2',
        null: 'invalid',
        'invalid': null,
        null: null,
      };
      expect(POBUtils.convertMapOfObjectToMapOfString(targeting),
          <String, String>{'valid1': 'value1', 'valid2': 'value2'});
    });
  });

  group('convertToStringDynamicMap method tests', () {
    test('Testing with null value', () {
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(null);
      expect(result, isNull);
    });

    test('Testing with non-map value', () {
      Map<String, dynamic>? result =
          POBUtils.convertToStringDynamicMap('not a map');
      expect(result, isNull);
    });

    test('Testing with simple map', () {
      dynamic input = {'key1': 'value1', 'key2': 123, 'key3': true};
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['key1'], 'value1');
      expect(result['key2'], 123);
      expect(result['key3'], true);
    });

    test('Testing with nested map', () {
      dynamic input = {
        'level1': {
          'level2': {'level3': 'deep value'}
        }
      };
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['level1'], isA<Map<String, dynamic>>());
      expect(result['level1']['level2'], isA<Map<String, dynamic>>());
      expect(result['level1']['level2']['level3'], 'deep value');
    });

    test('Testing with list containing primitives', () {
      dynamic input = {
        'items': [1, 2, 3, 'four', true]
      };
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['items'], isA<List>());
      expect(result['items'], [1, 2, 3, 'four', true]);
    });

    test('Testing with list containing maps', () {
      dynamic input = {
        'items': [
          {'id': 1, 'name': 'first'},
          {'id': 2, 'name': 'second'}
        ]
      };
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['items'], isA<List>());
      expect(result['items'].length, 2);
      expect(result['items'][0], isA<Map<String, dynamic>>());
      expect(result['items'][0]['id'], 1);
      expect(result['items'][0]['name'], 'first');
      expect(result['items'][1]['id'], 2);
      expect(result['items'][1]['name'], 'second');
    });

    test('Testing with nested lists', () {
      dynamic input = {
        'matrix': [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9]
        ]
      };
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['matrix'], isA<List>());
      expect(result['matrix'][0], [1, 2, 3]);
      expect(result['matrix'][1], [4, 5, 6]);
      expect(result['matrix'][2], [7, 8, 9]);
    });

    test('Testing with complex nested structure', () {
      dynamic input = {
        'user': {
          'name': 'John',
          'age': 30,
          'addresses': [
            {
              'type': 'home',
              'street': '123 Main St',
              'coordinates': [40.7128, -74.0060]
            },
            {
              'type': 'work',
              'street': '456 Office Blvd',
              'coordinates': [40.7589, -73.9851]
            }
          ],
          'metadata': {
            'verified': true,
            'tags': ['premium', 'active']
          }
        }
      };
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['user']['name'], 'John');
      expect(result['user']['age'], 30);
      expect(result['user']['addresses'], isA<List>());
      expect(result['user']['addresses'].length, 2);
      expect(result['user']['addresses'][0]['type'], 'home');
      expect(
          result['user']['addresses'][0]['coordinates'], [40.7128, -74.0060]);
      expect(result['user']['metadata']['verified'], true);
      expect(result['user']['metadata']['tags'], ['premium', 'active']);
    });

    test('Testing with integer keys converted to string keys', () {
      dynamic input = {1: 'one', 2: 'two', 3: 'three'};
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['1'], 'one');
      expect(result['2'], 'two');
      expect(result['3'], 'three');
    });

    test('Testing with empty map', () {
      dynamic input = {};
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!.isEmpty, true);
    });

    test('Testing with null values in map', () {
      dynamic input = {'key1': 'value1', 'key2': null, 'key3': 'value3'};
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['key1'], 'value1');
      expect(result['key2'], null);
      expect(result['key3'], 'value3');
    });

    test('Testing with empty list', () {
      dynamic input = {'items': []};
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['items'], isA<List>());
      expect(result['items'].isEmpty, true);
    });

    test('Testing with mixed types in list', () {
      dynamic input = {
        'mixed': [
          'string',
          123,
          true,
          {'nested': 'map'},
          [1, 2, 3],
          null
        ]
      };
      Map<String, dynamic>? result = POBUtils.convertToStringDynamicMap(input);
      expect(result, isNotNull);
      expect(result!['mixed'].length, 6);
      expect(result['mixed'][0], 'string');
      expect(result['mixed'][1], 123);
      expect(result['mixed'][2], true);
      expect(result['mixed'][3], isA<Map<String, dynamic>>());
      expect(result['mixed'][3]['nested'], 'map');
      expect(result['mixed'][4], [1, 2, 3]);
      expect(result['mixed'][5], null);
    });
  });
}
