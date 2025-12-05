import 'package:flutter_openwrap_sdk/src/openwrap_sdk_method_channel.dart';
import 'package:flutter_openwrap_sdk/src/pob_ad_instance_manager.dart';
import 'package:flutter_openwrap_sdk/src/pob_ad.dart';
import 'package:flutter_openwrap_sdk/src/pob_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

// Mock POBAd class for testing
class MockPOBAd extends POBAd {
  bool callbackReceived = false;
  MethodCall? lastCall;

  MockPOBAd()
      : super(
          pubId: 'testPubId',
          adUnitId: 'testAdUnitId',
          profileId: 123,
          tag: 'MockPOBAd',
        ) {
    adId = 123;
    adIdMap = {keyAdId: adId};
  }

  @override
  void onAdCallBack(MethodCall call) {
    callbackReceived = true;
    lastCall = call;
  }
}

void main() {
  late MockPOBAd mockAd;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAd = MockPOBAd();
  });

  tearDown(() {
    // Clean up instance manager
    POBAdInstanceManager.instance.adMap.clear();
  });

  group('callPlatformMethodWithTag', () {
    test('should invoke method with tag and arguments', () async {
      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
              (message) async {
        expect(message.method, 'TestTag#testMethod');
        expect(message.arguments, {'key': 'value'});
        return 'test_result';
      });

      String? result =
          await openWrapMethodChannel.callPlatformMethodWithTag<String>(
        tag: 'TestTag',
        methodName: 'testMethod',
        argument: {'key': 'value'},
      );

      expect(result, 'test_result');
    });

    test('should invoke method with tag without arguments', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
              (message) async {
        expect(message.method, 'TestTag#testMethod');
        expect(message.arguments, isNull);
        return 42;
      });

      int? result = await openWrapMethodChannel.callPlatformMethodWithTag<int>(
        tag: 'TestTag',
        methodName: 'testMethod',
      );

      expect(result, 42);
    });
  });

  group('callPlatformMethod', () {
    test('should invoke method with arguments', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
              (message) async {
        expect(message.method, 'testMethod');
        expect(message.arguments, {'data': 'test'});
        return true;
      });

      bool? result = await openWrapMethodChannel.callPlatformMethod<bool>(
        methodName: 'testMethod',
        argument: {'data': 'test'},
      );

      expect(result, true);
    });

    test('should invoke method without arguments', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
              (message) async {
        expect(message.method, 'testMethod');
        expect(message.arguments, isNull);
        return 'success';
      });

      String? result = await openWrapMethodChannel.callPlatformMethod<String>(
        methodName: 'testMethod',
      );

      expect(result, 'success');
    });
  });

  group('onMethodCallHandler', () {
    test('should handle callback with valid ad ID and existing ad instance',
        () {
      // Add mock ad to instance manager
      POBAdInstanceManager.instance.addToMap(mockAd.adId, mockAd);

      // Create method call with valid ad ID
      MethodCall call = MethodCall('testCallback', {keyAdId: mockAd.adId});

      // Call the handler
      openWrapMethodChannel.onMethodCallHandler(call);

      // Verify callback was received
      expect(mockAd.callbackReceived, isTrue);
      expect(mockAd.lastCall?.method, 'testCallback');
    });

    test('should handle callback with valid ad ID but missing ad instance', () {
      // Don't add mock ad to instance manager (simulate missing instance)
      int nonExistentAdId = 999;

      // Create method call with non-existent ad ID
      MethodCall call = MethodCall('testCallback', {keyAdId: nonExistentAdId});

      // Call the handler (should log error but not crash)
      expect(() => openWrapMethodChannel.onMethodCallHandler(call),
          returnsNormally);
    });

    test('should handle callback with null ad ID', () {
      // Create method call with null ad ID
      MethodCall call = MethodCall('testCallback', {keyAdId: null});

      // Call the handler (should log error but not crash)
      expect(() => openWrapMethodChannel.onMethodCallHandler(call),
          returnsNormally);
    });

    test('should handle callback with missing ad ID key', () {
      // Create method call without ad ID key
      MethodCall call = MethodCall('testCallback', {'otherKey': 'value'});

      // Call the handler (should log error but not crash)
      expect(() => openWrapMethodChannel.onMethodCallHandler(call),
          returnsNormally);
    });

    test('should handle callback with non-integer ad ID', () {
      // Create method call with string ad ID (should be cast to null)
      MethodCall call = MethodCall('testCallback', {keyAdId: 'invalid'});

      // Call the handler (should log error but not crash)
      expect(() => openWrapMethodChannel.onMethodCallHandler(call),
          returnsNormally);
    });
  });

  group('singleton instance', () {
    test('should use global openWrapMethodChannel instance', () {
      expect(openWrapMethodChannel, isNotNull);
    });

    test('should handle method calls through global instance', () {
      // Test that the global instance is properly initialized and can handle calls
      expect(
          () =>
              openWrapMethodChannel.onMethodCallHandler(MethodCall('test', {})),
          returnsNormally);
    });
  });
}
