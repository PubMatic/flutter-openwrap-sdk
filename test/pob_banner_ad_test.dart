// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/services.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

dynamic testData;
void main() {
  late String? methodCallName;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
            (message) {
      methodCallName = message.method;
      testData = message.arguments;

      var names = message.method.split('#');
      if (names[0] == 'initBannerAd') {
        return null;
      }

      if (names[1] == 'getCreativeSize') {
        return Future(() => {'w': 320, 'h': 50});
      }

      if (names[1] == 'getBid') {
        return Future(() => {
              'price': 3.0,
              'width': POBAdSize.bannerSize320x50.width,
              'height': POBAdSize.bannerSize320x50.height,
              'status': 1,
              'partnerName': 'pubmatic',
              'refreshInterval': 60
            });
      }

      if (names[1] == 'forceRefresh') {
        return Future(() => true);
      }

      if (names[1] == 'pauseAutoRefresh' || names[1] == 'resumeAutoRefresh') {
        return Future(() => null);
      }
      return null;
    });
  });

  group('BannerView Testing', () {
    POBBannerAd bannerAd;
    test('Public APIs Testing', () async {
      bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);
      expect(testData['pubId'], "156276");
      expect(testData['profileId'], 1165);
      expect(testData['adUnitId'], "OpenWrapBannerAdUnit");
      testData = null;

      bannerAd.loadAd();
      expect(testData['adId'], bannerAd.adId);
      testData = null;

      POBAdSize? adSize = await bannerAd.getCreativeSize();
      expect(adSize?.width, POBAdSize.bannerSize320x50.width);
      expect(adSize?.height, POBAdSize.bannerSize320x50.height);

      POBBid bid = await bannerAd.getBid();
      expect(bid.price, 3);
      expect(bid.height, POBAdSize.bannerSize320x50.height);
      expect(bid.width, POBAdSize.bannerSize320x50.width);
      expect(bid.status, 1);
      expect(bid.partnerName, 'pubmatic');
      expect(bid.refreshInterval, 60);

      bannerAd.destroy();
      expect(testData['adId'], bannerAd.adId);
      testData = null;
    });

    test('BannerView request', () {
      bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);

      POBRequest request = POBRequest();
      request.returnAllBidStatus = false;
      request.debug = true;
      request.testMode = false;
      request.setNetworkTimeout = 100;
      request.versionId = 2;
      request.adServerUrl = "www.google.com";
      testData = null;
      bannerAd.request = request;

      expect(testData['debug'], request.debug);
      expect(testData['networkTimeout'], request.getNetworkTimeout);
      expect(testData['versionId'], request.versionId);
      expect(testData['testMode'], request.testMode);
      expect(testData['adServerUrl'], request.adServerUrl);
      expect(testData['returnAllBidStatus'], request.returnAllBidStatus);
    });

    test('BannerView Impression', () {
      bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);

      POBImpression? impression = POBImpression();
      //Asserting default values
      expect(impression.adPosition, POBAdPosition.unknown);

      impression.adPosition = POBAdPosition.footer;
      impression.testCreativeId = "creative";
      impression.customParams = {
        "map1": ['a', 'b']
      };

      bannerAd.impression = impression;

      expect(testData['adPosition'], impression.adPosition.index);
      expect(testData['testCreativeId'], impression.testCreativeId);
      expect(testData['customParams'], impression.customParams);
    });

    test('Test Callbacks', () {
      bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);

      bannerAd.listener = POBBannerAdListenerImpl();

      bannerAd.onAdCallBack(const MethodCall('onAdReceived'));
      expect('onAdReceived', testData);

      bannerAd.onAdCallBack(const MethodCall('onAdClicked'));
      expect('onAdClicked', testData);

      bannerAd.onAdCallBack(const MethodCall('onAdClosed'));
      expect('onAdClosed', testData);

      bannerAd.onAdCallBack(const MethodCall('onAdFailed',
          {'errorCode': 1001, 'errorMessage': 'test error message.'}));
      expect('onAdFailed', testData);

      bannerAd.onAdCallBack(const MethodCall('onAdOpened'));
      expect('onAdOpened', testData);

      bannerAd.onAdCallBack(const MethodCall('onAppLeaving'));
      expect('onAppLeaving', testData);

      bannerAd.onAdCallBack(const MethodCall('onAdImpression'));
      expect('onAdImpression', testData);

      bannerAd.onAdCallBack(
          const MethodCall('onAdSizeChanged', {'width': 320, 'height': 50}));
      expect('onAdSizeChanged', testData);
    });
  });

  group('Banner Event Handler', () {
    test('POBBanner.event handler named constructor', () {
      DummyBannerEvent event = DummyBannerEvent();
      POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: event);
      expect(testData['pubId'], "156276");
      expect(testData['profileId'], 1165);
      expect(testData['adUnitId'], "OpenWrapBannerAdUnit");
      expect(testData['isHeaderBidding'], true);

      testData = null;
    });

    test('POBBannerEvent event listener callbacks tests', () {
      DummyBannerEvent event = DummyBannerEvent();
      POBBannerAd bannerAd = POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: event);
      event.listener.onAdImpression.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdImpression');

      event.listener.onAdServerWin.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdServerWin');

      event.listener.onFailed.call({'errorCode': 1000});
      expect(testData['adId'], bannerAd.adId);
      expect(testData['errorCode'], 1000);
      expect(methodCallName, 'POBBannerView#EventHandler#onFailed');

      event.listener.onOpenWrapPartnerWin.call('1111');
      expect(testData['adId'], bannerAd.adId);
      expect(testData['bidId'], '1111');
      expect(methodCallName, 'POBBannerView#EventHandler#onOpenWrapPartnerWin');

      event.listener.onAdClick.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdClick');

      event.listener.onAdClosed.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdClosed');

      event.listener.onAdLeftApplication.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdLeftApplication');

      event.listener.onAdOpened.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdOpened');

      event.listener.onAdImpression.call();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdImpression');
    });

    test('Event Handler getCreativeSize api test case', () async {
      DummyBannerEvent event = DummyBannerEvent();
      POBBannerAd bannerAd = POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: event);
      event.listener.onAdServerWin();
      POBAdSize? result = await bannerAd.getCreativeSize();
      expect(result, POBAdSize.bannerSize120x600);
    });

    test('Event Handler request Ad', () {
      POBBannerAd bannerAd = POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: DummyBannerEvent());

      Map expectedData = <Object?, Object?>{'a': 'b'};
      testData = null;
      bannerAd.onAdCallBack(
          MethodCall('requestAd', {'openWrapTargeting': expectedData}));

      expect(testData, isNotNull);
      expect(testData, <String, String>{'a': 'b'});
    });

    test('forceRefresh method', () async {
      POBBannerAd bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);
      testData = null;

      bool? result = await bannerAd.forceRefresh();
      expect(testData['adId'], bannerAd.adId);
      expect(result, isTrue); // Mock returns true
      testData = null;
    });

    test('pauseAutoRefresh method', () {
      POBBannerAd bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);
      testData = null;

      bannerAd.pauseAutoRefresh();
      expect(testData['adId'], bannerAd.adId);
      testData = null;
    });

    test('resumeAutoRefresh method', () {
      POBBannerAd bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);
      testData = null;

      bannerAd.resumeAutoRefresh();
      expect(testData['adId'], bannerAd.adId);
      testData = null;
    });

    test('getAdWidget getter', () {
      POBBannerAd bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);

      POBBannerWidget widget = bannerAd.getAdWidget;
      expect(widget, isNotNull);
      expect(widget, isA<POBBannerWidget>());
    });

    test('getCreativeSize with event handler and ad server win', () async {
      DummyBannerEvent event = DummyBannerEvent();
      POBBannerAd bannerAd = POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: event);

      // Simulate ad server win
      event.listener.onAdServerWin();

      POBAdSize? result = await bannerAd.getCreativeSize();
      expect(result, POBAdSize.bannerSize120x600); // From DummyBannerEvent
    });

    test('getCreativeSize when result is null', () async {
      POBBannerAd bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);

      // Override mock to return null for getCreativeSize
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
              (message) {
        methodCallName = message.method;
        testData = message.arguments;

        var names = message.method.split('#');
        if (names[0] == 'initBannerAd') {
          return null;
        }

        if (names[1] == 'getCreativeSize') {
          return Future(() => null); // Return null
        }

        return null;
      });

      POBAdSize? result = await bannerAd.getCreativeSize();
      expect(result, isNull);
    });

    test('POBBannerAdListener constructor', () {
      // Test with all callbacks
      POBBannerAdListener listener1 = POBBannerAdListener(
        onAdReceived: (ad) {},
        onAppLeaving: (ad) {},
        onAdClicked: (ad) {},
        onAdClosed: (ad) {},
        onAdOpened: (ad) {},
        onAdImpression: (ad) {},
        onAdFailed: (ad, error) {},
      );
      expect(listener1, isNotNull);
      expect(listener1.onAdReceived, isNotNull);
      expect(listener1.onAdFailed, isNotNull);

      // Test with minimal callbacks (null values)
      POBBannerAdListener listener2 = POBBannerAdListener();
      expect(listener2, isNotNull);
      expect(listener2.onAdReceived, isNull);
      expect(listener2.onAdFailed, isNull);
    });

    test('_POBBannerEventListenerImpl methods', () {
      DummyBannerEvent event = DummyBannerEvent();
      POBBannerAd bannerAd = POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: event);

      testData = null;
      methodCallName = null;

      // Test onAdServerWin - should set _isAdServerWin to true
      event.listener.onAdServerWin();
      expect(testData['adId'], bannerAd.adId);
      expect(methodCallName, 'POBBannerView#EventHandler#onAdServerWin');

      // Test onOpenWrapPartnerWin - should set _isAdServerWin to false
      testData = null;
      methodCallName = null;
      event.listener.onOpenWrapPartnerWin('testBidId');
      expect(testData['adId'], bannerAd.adId);
      expect(testData['bidId'], 'testBidId');
      expect(methodCallName, 'POBBannerView#EventHandler#onOpenWrapPartnerWin');

      // Test onFailed - should set _isAdServerWin to false and call platform method
      testData = null;
      methodCallName = null;
      Map<String, Object> error = {
        'errorCode': 1001,
        'errorMessage': 'Test error'
      };
      event.listener.onFailed(error);
      expect(testData['adId'], bannerAd.adId);
      expect(testData['errorCode'], 1001);
      expect(testData['errorMessage'], 'Test error');
      expect(methodCallName, 'POBBannerView#EventHandler#onFailed');
    });

    test('eventHandler constructor with null requestedAdSizes', () {
      // Create a dummy event that returns null for requestedAdSizes
      DummyBannerEventWithNullSizes event = DummyBannerEventWithNullSizes();

      // This should log an error and not crash
      expect(
          () => POBBannerAd.eventHandler(
              pubId: "156276",
              profileId: 1165,
              adUnitId: "OpenWrapBannerAdUnit",
              bannerEvent: event),
          returnsNormally);
    });

    test('onAdCallBack with null listener', () {
      POBBannerAd bannerAd = POBBannerAd(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          adSizes: [POBAdSize.bannerSize320x50]);

      // Test that callbacks don't crash when listener is null
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdReceived', null)),
          returnsNormally);
      expect(() => bannerAd.onAdCallBack(MethodCall('onAppLeaving', null)),
          returnsNormally);
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdOpened', null)),
          returnsNormally);
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdClosed', null)),
          returnsNormally);
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdClicked', null)),
          returnsNormally);
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdImpression', null)),
          returnsNormally);

      Map<String, dynamic> errorData = {
        'errorCode': 1001,
        'errorMessage': 'Test error'
      };
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdFailed', errorData)),
          returnsNormally);
    });

    test('destroy method clears listener and event handler', () async {
      DummyBannerEvent event = DummyBannerEvent();
      POBBannerAd bannerAd = POBBannerAd.eventHandler(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapBannerAdUnit",
          bannerEvent: event);

      POBBannerAdListener listener = POBBannerAdListener();
      bannerAd.listener = listener;

      await bannerAd.destroy();

      // After destroy, callbacks should not crash (listener is cleared internally)
      expect(() => bannerAd.onAdCallBack(MethodCall('onAdReceived', null)),
          returnsNormally);
    });
  });
}

class DummyBannerEventWithNullSizes implements POBBannerEvent {
  late POBBannerEventListener listener;

  @override
  POBAdServerAdEvent get destroy => () {};

  @override
  POBEventAdServerWidget get getAdServerWidget => () => Container();

  @override
  POBEventGetAdSize get getAdSize => () async => POBAdSize.bannerSize120x600;

  @override
  POBEventRequestAd get requestAd =>
      ({Map<String, String>? openWrapTargeting}) =>
          testData = openWrapTargeting;

  @override
  POBEventGetAdSizes get requestedAdSizes => () => null; // Returns null

  @override
  get setEventListener =>
      (POBBannerEventListener eventListener) => listener = eventListener;
}

class POBBannerAdListenerImpl implements POBBannerAdListener {
  @override
  POBAdEvent<POBBannerAd>? get onAdReceived =>
      (POBBannerAd ad) => testData = 'onAdReceived';

  @override
  POBAdEvent<POBBannerAd>? get onAdClicked =>
      (POBBannerAd ad) => testData = 'onAdClicked';

  @override
  POBAdEvent<POBBannerAd>? get onAdClosed =>
      (POBBannerAd ad) => testData = 'onAdClosed';

  @override
  POBAdFailed<POBBannerAd>? get onAdFailed =>
      (POBBannerAd ad, POBError error) => testData = 'onAdFailed';

  @override
  POBAdEvent<POBBannerAd>? get onAdOpened =>
      (POBBannerAd ad) => testData = 'onAdOpened';

  @override
  POBAdEvent<POBBannerAd>? get onAppLeaving =>
      (POBBannerAd ad) => testData = 'onAppLeaving';

  @override
  POBAdEvent<POBBannerAd>? get onAdImpression =>
      (POBBannerAd ad) => testData = 'onAdImpression';

  @override
  POBAdSizeChanged<POBBannerAd>? get onAdSizeChanged =>
      (POBBannerAd ad, POBAdSize size) => testData = 'onAdSizeChanged';
}

class DummyBannerEvent implements POBBannerEvent {
  late POBBannerEventListener listener;
  @override
  POBAdServerAdEvent get destroy => () {};

  @override
  POBEventAdServerWidget get getAdServerWidget => () => Container();

  @override
  POBEventGetAdSize get getAdSize => () async => POBAdSize.bannerSize120x600;

  @override
  POBEventRequestAd get requestAd =>
      ({Map<String, String>? openWrapTargeting}) =>
          testData = openWrapTargeting;

  @override
  POBEventGetAdSizes get requestedAdSizes =>
      () => [POBAdSize.bannerSize120x600];

  @override
  get setEventListener =>
      (POBBannerEventListener eventListener) => listener = eventListener;
}
