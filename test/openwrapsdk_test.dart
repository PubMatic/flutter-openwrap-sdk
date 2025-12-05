import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  dynamic testData;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
            (message) {
      switch (message.method.split('#')[1]) {
        case "getDSAComplianceStatus":
          return Future.value(testData);
        case "initialize":
          return Future.value(testData);
        case "getVersion":
          return Future.value(testData);
        case "getExternalUserIds":
          return Future.value(testData);
        default:
          testData = message.arguments;
      }
      return null;
    });
  });

  test("OpenWrap SDK API", () {
    //setLogLevel
    OpenWrapSDK.setLogLevel(POBLogLevel.error);
    expect(testData, POBLogLevel.error.index);

    //setLogLevel for different log levels
    OpenWrapSDK.setLogLevel(POBLogLevel.all);
    expect(testData, POBLogLevel.all.index);

    //allowLocationAccess
    testData = false;
    OpenWrapSDK.allowLocationAccess(true);
    expect(testData, isTrue);

    //setUseInternalBrowser
    testData = false;
    OpenWrapSDK.setUseInternalBrowser(true);
    expect(testData, isTrue);

    //setLocation
    OpenWrapSDK.setLocation(POBLocationSource.gps, 12.2, 13.2);
    expect((testData as Map)['source'], POBLocationSource.gps.index);

    //setCoppa
    testData = false;
    OpenWrapSDK.setCoppa(true);
    expect(testData, isTrue);

    //setSSLEnabled
    testData = false;
    OpenWrapSDK.setSSLEnabled(true);
    expect(testData, isTrue);

    //allowAdvertisingId
    testData = false;
    OpenWrapSDK.allowAdvertisingId(true);
    expect(testData, isTrue);

    //ApplicationInfo
    POBApplicationInfo applicationInfo = POBApplicationInfo();
    applicationInfo.categories = 'Games';
    OpenWrapSDK.setApplicationInfo(applicationInfo);
    expect(testData['categories'], applicationInfo.categories);

    //UserInfo
    POBUserInfo userInfo = POBUserInfo();
    userInfo.birthYear = 2000;
    OpenWrapSDK.setUserInfo(userInfo);
    expect(testData['birthYear'], userInfo.birthYear);
  });

  test("DSA", () {
    OpenWrapSDK.setDSAComplianceStatus(
        POBDSAComplianceStatus.requiredPubOnlinePlatform);
    OpenWrapSDK.getDSAComplianceStatus().then((value) {
      expect(POBDSAComplianceStatus.requiredPubOnlinePlatform, value);
    });

    // Test null case for getDSAComplianceStatus
    testData = null;
    OpenWrapSDK.getDSAComplianceStatus().then((value) {
      expect(POBDSAComplianceStatus.notRequired, value);
    });
  });

  test("OpenWrapSDK initialize - success", () async {
    testData = {"success": true};
    bool callbackReceived = false;

    OpenWrapSDK.initialize(
        config: OpenWrapSDKConfig('testPublisherId', [1, 2, 3]),
        listener: OpenWrapSDKListener(
          onOpenWrapSDKInitialize: () {
            callbackReceived = true;
          },
        ));

    await Future.delayed(Duration(milliseconds: 100));
    expect(callbackReceived, isTrue);
  });

  test("OpenWrapSDK initialize - error", () async {
    testData = {
      "error": {"errorCode": 1001, "errorMessage": "Test error"}
    };
    POBError? receivedError;

    OpenWrapSDK.initialize(
        config: OpenWrapSDKConfig('testPublisherId', [1, 2, 3]),
        listener: OpenWrapSDKListener(
          onOpenWrapSDKInitializeError: (error) {
            receivedError = error;
          },
        ));

    await Future.delayed(Duration(milliseconds: 100));
    expect(receivedError, isNotNull);
    expect(receivedError?.errorCode, 1001);
    expect(receivedError?.errorMessage, "Test error");
  });

  test("OpenWrapSDK initialize - null result", () async {
    testData = null;
    POBError? receivedError;

    OpenWrapSDK.initialize(
        config: OpenWrapSDKConfig('testPublisherId', [1, 2, 3]),
        listener: OpenWrapSDKListener(
          onOpenWrapSDKInitializeError: (error) {
            receivedError = error;
          },
        ));

    await Future.delayed(Duration(milliseconds: 100));
    expect(receivedError, isNotNull);
    expect(receivedError?.errorCode, POBError.internalError);
  });

  test("getVersion", () async {
    testData = "1.0.0";
    String? version = await OpenWrapSDK.getVersion();
    expect(version, "1.0.0");
  });

  test("OpenWrapSDKConfig", () {
    OpenWrapSDKConfig config = OpenWrapSDKConfig('pub123', [1, 2, 3]);
    expect(config.publisherId, 'pub123');
    expect(config.profileIds, [1, 2, 3]);
  });

  test("OpenWrapSDKConfig copyWith", () {
    OpenWrapSDKConfig config = OpenWrapSDKConfig('pub123', [1, 2, 3]);
    OpenWrapSDKConfig updatedConfig =
        config.copyWith(publisherId: 'pub456', profileIds: [4, 5]);

    expect(updatedConfig.publisherId, 'pub456');
    expect(updatedConfig.profileIds, [4, 5]);

    OpenWrapSDKConfig partialUpdate = config.copyWith(publisherId: 'pub789');
    expect(partialUpdate.publisherId, 'pub789');
    expect(partialUpdate.profileIds, [1, 2, 3]);
  });

  group('External User ID methods tests', () {
    test('addExternalUserId - success', () async {
      POBExternalUserId userId = POBExternalUserId(
        source: 'liveramp.com',
        id: 'user123',
        atype: 1,
        ext: {'key': 'value'},
      );

      await OpenWrapSDK.addExternalUserId(userId);

      expect(testData, isNotNull);
      expect(testData['source'], 'liveramp.com');
      expect(testData['id'], 'user123');
      expect(testData['atype'], 1);
      expect(testData['ext'], {'key': 'value'});
    });

    test('addExternalUserId - without optional parameters', () async {
      POBExternalUserId userId = POBExternalUserId(
        source: 'criteo.com',
        id: 'xyz789',
      );

      await OpenWrapSDK.addExternalUserId(userId);

      expect(testData, isNotNull);
      expect(testData['source'], 'criteo.com');
      expect(testData['id'], 'xyz789');
      expect(testData['atype'], 0);
      expect(testData.containsKey('ext'), isFalse);
    });

    test('getExternalUserIds - with multiple user IDs', () async {
      testData = [
        {
          'source': 'liveramp.com',
          'id': 'user123',
          'atype': 1,
          'ext': {'key1': 'value1'}
        },
        {
          'source': 'criteo.com',
          'id': 'user456',
          'atype': 2,
          'ext': {'key2': 'value2'}
        },
        {'source': 'adserver.org', 'id': 'user789', 'atype': 0}
      ];

      List<POBExternalUserId> userIds = await OpenWrapSDK.getExternalUserIds();

      expect(userIds, isNotNull);
      expect(userIds.length, 3);

      expect(userIds[0].source, 'liveramp.com');
      expect(userIds[0].id, 'user123');
      expect(userIds[0].atype, 1);
      expect(userIds[0].ext, isNotNull);
      expect(userIds[0].ext!['key1'], 'value1');

      expect(userIds[1].source, 'criteo.com');
      expect(userIds[1].id, 'user456');
      expect(userIds[1].atype, 2);
      expect(userIds[1].ext, isNotNull);
      expect(userIds[1].ext!['key2'], 'value2');

      expect(userIds[2].source, 'adserver.org');
      expect(userIds[2].id, 'user789');
      expect(userIds[2].atype, 0);
    });

    test('getExternalUserIds - with empty list', () async {
      testData = [];

      List<POBExternalUserId> userIds = await OpenWrapSDK.getExternalUserIds();

      expect(userIds, isNotNull);
      expect(userIds.length, 0);
      expect(userIds.isEmpty, isTrue);
    });

    test('getExternalUserIds - with null response', () async {
      testData = null;

      List<POBExternalUserId> userIds = await OpenWrapSDK.getExternalUserIds();

      expect(userIds, isNotNull);
      expect(userIds.length, 0);
      expect(userIds.isEmpty, isTrue);
    });

    test('getExternalUserIds - with nested ext map', () async {
      testData = [
        {
          'source': 'datasource.com',
          'id': 'nested123',
          'atype': 3,
          'ext': {
            'level1': {
              'level2': {'level3': 'deep value'}
            },
            'array': [1, 2, 3]
          }
        }
      ];

      List<POBExternalUserId> userIds = await OpenWrapSDK.getExternalUserIds();

      expect(userIds, isNotNull);
      expect(userIds.length, 1);
      expect(userIds[0].source, 'datasource.com');
      expect(userIds[0].id, 'nested123');
      expect(userIds[0].atype, 3);
      expect(userIds[0].ext, isNotNull);
      expect(userIds[0].ext!['level1'], isA<Map<String, dynamic>>());
      expect(userIds[0].ext!['level1']['level2']['level3'], 'deep value');
      expect(userIds[0].ext!['array'], [1, 2, 3]);
    });

    test('removeExternalUserIds - with source name', () async {
      String source = 'liveramp.com';

      await OpenWrapSDK.removeExternalUserIds(source);

      expect(testData, 'liveramp.com');
    });

    test('removeExternalUserIds - with different source', () async {
      String source = 'criteo.com';

      await OpenWrapSDK.removeExternalUserIds(source);

      expect(testData, 'criteo.com');
    });

    test('removeExternalUserIds - with empty source', () async {
      String source = '';

      await OpenWrapSDK.removeExternalUserIds(source);

      expect(testData, '');
    });

    test('removeAllExternalUserIds - success', () async {
      // Set testData to a known value before the call
      testData = 'initial_value';

      await OpenWrapSDK.removeAllExternalUserIds();

      // Since removeAllExternalUserIds doesn't pass any arguments,
      // the default case in mock handler will set testData to null (message.arguments)
      // because no arguments are passed
      expect(testData, isNull);
    });

    test('addExternalUserId - with complex ext structure', () async {
      POBExternalUserId userId = POBExternalUserId(
        source: 'complex.com',
        id: 'complex123',
        atype: 5,
        ext: {
          'metadata': {
            'version': '2.0',
            'settings': {'enabled': true, 'timeout': 30}
          },
          'tags': ['premium', 'verified'],
          'count': 100
        },
      );

      await OpenWrapSDK.addExternalUserId(userId);

      expect(testData, isNotNull);
      expect(testData['source'], 'complex.com');
      expect(testData['id'], 'complex123');
      expect(testData['atype'], 5);
      expect(testData['ext'], isNotNull);
      expect(testData['ext']['metadata']['version'], '2.0');
      expect(testData['ext']['metadata']['settings']['enabled'], true);
      expect(testData['ext']['metadata']['settings']['timeout'], 30);
      expect(testData['ext']['tags'], ['premium', 'verified']);
      expect(testData['ext']['count'], 100);
    });

    test('getExternalUserIds - with missing optional fields', () async {
      testData = [
        {'source': 'minimal.com', 'id': 'min123'}
      ];

      List<POBExternalUserId> userIds = await OpenWrapSDK.getExternalUserIds();

      expect(userIds, isNotNull);
      expect(userIds.length, 1);
      expect(userIds[0].source, 'minimal.com');
      expect(userIds[0].id, 'min123');
      expect(userIds[0].atype, 0); // Default value
      expect(userIds[0].ext, isNull);
    });

    test('getExternalUserIds - with null fields', () async {
      testData = [
        {'source': null, 'id': null, 'atype': null, 'ext': null}
      ];

      List<POBExternalUserId> userIds = await OpenWrapSDK.getExternalUserIds();

      expect(userIds, isNotNull);
      expect(userIds.length, 1);
      expect(userIds[0].source, ''); // Default empty string
      expect(userIds[0].id, ''); // Default empty string
      expect(userIds[0].atype, 0); // Default value
      expect(userIds[0].ext, isNull);
    });

    test('removeExternalUserIds - with special characters', () async {
      String source = 'source-with-special.chars_123';

      await OpenWrapSDK.removeExternalUserIds(source);

      expect(testData, 'source-with-special.chars_123');
    });
  });
}
