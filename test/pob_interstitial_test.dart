// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

dynamic testData;
void main() {
  String? methodCall;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
            (message) async {
      testData = message.arguments;
      methodCall = message.method;
      var names = message.method.split('#');
      if (names[0] == 'initInterstitialAd') {
        return null;
      }

      if (names[1] == 'isReady') {
        return Future(() => true);
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
      return null;
    });
  });

  group('Interstitial Testing', () {
    POBInterstitial interstitial;
    test('Public APIs Testing', () async {
      interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");
      expect(testData['pubId'], "156276");
      expect(testData['profileId'], 1165);
      expect(testData['adUnitId'], "OpenWrapInterstitialAdUnit");
      testData = null;

      interstitial.loadAd();
      expect(testData['adId'], interstitial.adId);
      testData = null;

      interstitial.showAd();
      expect(testData['adId'], interstitial.adId);
      testData = null;

      await interstitial.isReady();
      expect(testData['adId'], interstitial.adId);
      testData = null;

      POBBid bid = await interstitial.getBid();
      expect(bid.price, 3);
      expect(bid.height, POBAdSize.bannerSize320x50.height);
      expect(bid.width, POBAdSize.bannerSize320x50.width);
      expect(bid.status, 1);
      expect(bid.partnerName, 'pubmatic');
      expect(bid.refreshInterval, 60);

      interstitial.destroy();
      expect(testData['adId'], interstitial.adId);
      testData = null;
    });

    test('Interstitial request', () {
      interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");

      POBRequest? request = POBRequest()
        ..returnAllBidStatus = false
        ..debug = true
        ..testMode = false
        ..setNetworkTimeout = 100
        ..adServerUrl = "www.google.com"
        ..versionId = 2;

      testData = null;
      interstitial.request = request;

      expect(testData['debug'], request.debug);
      expect(testData['networkTimeout'], request.getNetworkTimeout);
      expect(testData['versionId'], request.versionId);
      expect(testData['testMode'], request.testMode);
      expect(testData['adServerUrl'], request.adServerUrl);
      expect(testData['returnAllBidStatus'], request.returnAllBidStatus);
    });

    test('Interstitial Impression', () {
      interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");

      POBImpression? impression = POBImpression()
        ..adPosition = POBAdPosition.footer
        ..testCreativeId = "creative"
        ..customParams = {
          "map1": ['a', 'b']
        };

      interstitial.impression = impression;

      expect((testData as Map).containsKey('adPosition'), false);
      expect(testData['testCreativeId'], impression.testCreativeId);
      expect(testData['customParams'], impression.customParams);
    });
  });

  group('GAM Interstitial Testing', () {
    POBInterstitial interstitial;
    POBInterstitialEvent eventHandler;
    test('Test with OpenWrapEventHandler', () {
      eventHandler = OpenWrapDummyEventHandler();
      interstitial = POBInterstitial(
        pubId: "156276",
        profileId: 1165,
        adUnitId: "OpenWrapInterstitialAdUnit",
        eventHandler: eventHandler,
      );
      expect(testData['pubId'], "156276");
      expect(testData['profileId'], 1165);
      expect(testData['adUnitId'], "OpenWrapInterstitialAdUnit");
      expect(testData['isHeaderBidding'], true);
      testData = null;

      interstitial.loadAd();
      expect(testData['adId'], interstitial.adId);
    });
  });

  group('Interstitial Event Handler', () {
    test('POBInterstitial.event handler named constructor', () {
      OpenWrapDummyEventHandler event = OpenWrapDummyEventHandler();
      POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit",
          eventHandler: event);
      expect(testData['pubId'], "156276");
      expect(testData['profileId'], 1165);
      expect(testData['adUnitId'], "OpenWrapInterstitialAdUnit");
      expect(testData['isHeaderBidding'], true);

      testData = null;
    });

    test('POBInterstitialEvent event listener callbacks tests', () {
      OpenWrapDummyEventHandler event = OpenWrapDummyEventHandler();
      var interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit",
          eventHandler: event);
      event.listener.onAdServerWin.call();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdServerWin');

      event.listener.onFailedToLoad.call({'errorCode': 1000});
      expect(testData['adId'], interstitial.adId);
      expect(testData['errorCode'], 1000);
      expect(methodCall, 'POBInterstitial#EventHandler#onFailedToLoad');

      event.listener.onFailedToShow.call({'errorCode': 1000});
      expect(testData['adId'], interstitial.adId);
      expect(testData['errorCode'], 1000);
      expect(methodCall, 'POBInterstitial#EventHandler#onFailedToShow');

      event.listener.onOpenWrapPartnerWin.call('1111');
      expect(testData['adId'], interstitial.adId);
      expect(testData['bidId'], '1111');
      expect(methodCall, 'POBInterstitial#EventHandler#onOpenWrapPartnerWin');

      event.listener.onAdClick.call();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdClick');

      event.listener.onAdClosed.call();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdClosed');

      event.listener.onAdLeftApplication.call();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdLeftApplication');

      event.listener.onAdOpened.call();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdOpened');

      event.listener.onAdImpression.call();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdImpression');
    });

    test('Event Handler request Ad', () {
      OpenWrapDummyEventHandler event = OpenWrapDummyEventHandler();
      var interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit",
          eventHandler: event);

      Map expectedData = <Object?, Object?>{'a': 'b'};
      interstitial.onAdCallBack(
          MethodCall('requestAd', {'openWrapTargeting': expectedData}));

      expect(testData, isNotNull);
      expect(testData, <String, String>{'a': 'b'});
    });

    test('listener setter', () {
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");
      testData = null;

      POBInterstitialListener listener = POBInterstitialListener();
      interstitial.listener = listener;

      expect(testData['adId'], interstitial.adId);
      testData = null;
    });

    test('videoListener setter', () {
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");
      testData = null;

      POBVideoListener videoListener = POBVideoListener(
        onVideoPlaybackCompleted: (ad) {},
      );
      interstitial.videoListener = videoListener;

      expect(testData['adId'], interstitial.adId);
      testData = null;
    });

    test('onAdCallBack method - all callback cases', () {
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");

      bool onAdReceivedCalled = false;
      bool onAppLeavingCalled = false;
      bool onAdOpenedCalled = false;
      bool onAdClosedCalled = false;
      bool onAdClickedCalled = false;
      bool onAdImpressionCalled = false;
      bool onAdFailedToLoadCalled = false;
      bool onAdFailedToShowCalled = false;
      bool onAdExpiredCalled = false;
      bool onVideoPlaybackCompletedCalled = false;
      POBError? receivedError;

      // Set interstitial listener
      interstitial.listener = POBInterstitialListener(
        onAdReceived: (ad) => onAdReceivedCalled = true,
        onAppLeaving: (ad) => onAppLeavingCalled = true,
        onAdOpened: (ad) => onAdOpenedCalled = true,
        onAdClosed: (ad) => onAdClosedCalled = true,
        onAdClicked: (ad) => onAdClickedCalled = true,
        onAdImpression: (ad) => onAdImpressionCalled = true,
        onAdFailedToLoad: (ad, error) {
          onAdFailedToLoadCalled = true;
          receivedError = error;
        },
        onAdFailedToShow: (ad, error) {
          onAdFailedToShowCalled = true;
          receivedError = error;
        },
        onAdExpired: (ad) => onAdExpiredCalled = true,
      );

      // Set video listener
      interstitial.videoListener = POBVideoListener(
        onVideoPlaybackCompleted: (ad) => onVideoPlaybackCompletedCalled = true,
      );

      // Test onAdReceived callback
      interstitial.onAdCallBack(MethodCall('onAdReceived', null));
      expect(onAdReceivedCalled, isTrue);

      // Test onAppLeaving callback
      interstitial.onAdCallBack(MethodCall('onAppLeaving', null));
      expect(onAppLeavingCalled, isTrue);

      // Test onAdOpened callback
      interstitial.onAdCallBack(MethodCall('onAdOpened', null));
      expect(onAdOpenedCalled, isTrue);

      // Test onAdClosed callback
      interstitial.onAdCallBack(MethodCall('onAdClosed', null));
      expect(onAdClosedCalled, isTrue);

      // Test onAdClicked callback
      interstitial.onAdCallBack(MethodCall('onAdClicked', null));
      expect(onAdClickedCalled, isTrue);

      // Test onAdImpression callback
      interstitial.onAdCallBack(MethodCall('onAdImpression', null));
      expect(onAdImpressionCalled, isTrue);

      // Test onAdFailedToLoad callback
      Map<String, dynamic> errorData = {
        'errorCode': 1001,
        'errorMessage': 'Load failed'
      };
      interstitial.onAdCallBack(MethodCall('onAdFailedToLoad', errorData));
      expect(onAdFailedToLoadCalled, isTrue);
      expect(receivedError?.errorCode, 1001);
      expect(receivedError?.errorMessage, 'Load failed');

      // Test onAdFailedToShow callback
      Map<String, dynamic> showErrorData = {
        'errorCode': 2001,
        'errorMessage': 'Show failed'
      };
      interstitial.onAdCallBack(MethodCall('onAdFailedToShow', showErrorData));
      expect(onAdFailedToShowCalled, isTrue);
      expect(receivedError?.errorCode, 2001);
      expect(receivedError?.errorMessage, 'Show failed');

      // Test onAdExpired callback
      interstitial.onAdCallBack(MethodCall('onAdExpired', null));
      expect(onAdExpiredCalled, isTrue);

      // Test onVideoPlaybackCompleted callback
      interstitial.onAdCallBack(MethodCall('onVideoPlaybackCompleted', null));
      expect(onVideoPlaybackCompletedCalled, isTrue);
    });

    test('onAdCallBack with event handler callbacks', () {
      OpenWrapDummyEventHandler eventHandler = OpenWrapDummyEventHandler();
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit",
          eventHandler: eventHandler);

      testData = null;

      // Test requestAd callback
      Map<String, dynamic> requestAdData = {
        'openWrapTargeting': {'key1': 'value1', 'key2': 'value2'}
      };
      interstitial.onAdCallBack(MethodCall('requestAd', requestAdData));
      expect(testData, {'key1': 'value1', 'key2': 'value2'});

      // Test show callback - this calls eventHandler.show()
      testData = null;
      interstitial.onAdCallBack(MethodCall('show', null));
      // The show method in dummy handler doesn't set testData, so we just verify it doesn't crash
      expect(() => interstitial.onAdCallBack(MethodCall('show', null)),
          returnsNormally);
    });

    test('onAdCallBack with null listeners', () {
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit");

      // Test that callbacks don't crash when listeners are null
      expect(() => interstitial.onAdCallBack(MethodCall('onAdReceived', null)),
          returnsNormally);
      expect(() => interstitial.onAdCallBack(MethodCall('onAppLeaving', null)),
          returnsNormally);
      expect(() => interstitial.onAdCallBack(MethodCall('onAdOpened', null)),
          returnsNormally);
      expect(() => interstitial.onAdCallBack(MethodCall('onAdClosed', null)),
          returnsNormally);
      expect(() => interstitial.onAdCallBack(MethodCall('onAdClicked', null)),
          returnsNormally);
      expect(
          () => interstitial.onAdCallBack(MethodCall('onAdImpression', null)),
          returnsNormally);
      expect(() => interstitial.onAdCallBack(MethodCall('onAdExpired', null)),
          returnsNormally);
      expect(
          () => interstitial
              .onAdCallBack(MethodCall('onVideoPlaybackCompleted', null)),
          returnsNormally);
    });

    test('POBInterstitialListener constructor', () {
      // Test with all callbacks
      POBInterstitialListener listener1 = POBInterstitialListener(
        onAdReceived: (ad) {},
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
        onAdClicked: (ad) {},
        onAppLeaving: (ad) {},
        onAdImpression: (ad) {},
        onAdFailedToLoad: (ad, error) {},
        onAdFailedToShow: (ad, error) {},
        onAdExpired: (ad) {},
      );
      expect(listener1, isNotNull);
      expect(listener1.onAdReceived, isNotNull);
      expect(listener1.onAdFailedToLoad, isNotNull);
      expect(listener1.onAdFailedToShow, isNotNull);
      expect(listener1.onAdExpired, isNotNull);

      // Test with minimal callbacks (null values)
      POBInterstitialListener listener2 = POBInterstitialListener();
      expect(listener2, isNotNull);
      expect(listener2.onAdReceived, isNull);
      expect(listener2.onAdFailedToLoad, isNull);
      expect(listener2.onAdFailedToShow, isNull);
      expect(listener2.onAdExpired, isNull);
    });

    test('POBVideoListener constructor', () {
      bool callbackCalled = false;

      POBVideoListener videoListener = POBVideoListener(
        onVideoPlaybackCompleted: (ad) {
          callbackCalled = true;
        },
      );

      expect(videoListener, isNotNull);
      expect(videoListener.onVideoPlaybackCompleted, isNotNull);

      // Test the callback
      videoListener.onVideoPlaybackCompleted(POBInterstitial(
        pubId: "test",
        profileId: 123,
        adUnitId: "test",
      ));
      expect(callbackCalled, isTrue);
    });

    test('_EventHandlerInterstitialListener methods', () {
      OpenWrapDummyEventHandler eventHandler = OpenWrapDummyEventHandler();
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit",
          eventHandler: eventHandler);

      testData = null;
      methodCall = null;

      // Test onAdExpired
      eventHandler.listener.onAdExpired();
      expect(testData['adId'], interstitial.adId);
      expect(methodCall, 'POBInterstitial#EventHandler#onAdExpired');

      // Test onFailedToLoad
      testData = null;
      methodCall = null;
      Map<String, Object> loadError = {
        'errorCode': 1001,
        'errorMessage': 'Load failed'
      };
      eventHandler.listener.onFailedToLoad(loadError);
      expect(testData['adId'], interstitial.adId);
      expect(testData['errorCode'], 1001);
      expect(testData['errorMessage'], 'Load failed');
      expect(methodCall, 'POBInterstitial#EventHandler#onFailedToLoad');

      // Test onFailedToShow
      testData = null;
      methodCall = null;
      Map<String, Object> showError = {
        'errorCode': 2001,
        'errorMessage': 'Show failed'
      };
      eventHandler.listener.onFailedToShow(showError);
      expect(testData['adId'], interstitial.adId);
      expect(testData['errorCode'], 2001);
      expect(testData['errorMessage'], 'Show failed');
      expect(methodCall, 'POBInterstitial#EventHandler#onFailedToShow');
    });

    test('destroy method clears all listeners and event handler', () async {
      OpenWrapDummyEventHandler eventHandler = OpenWrapDummyEventHandler();
      POBInterstitial interstitial = POBInterstitial(
          pubId: "156276",
          profileId: 1165,
          adUnitId: "OpenWrapInterstitialAdUnit",
          eventHandler: eventHandler);

      POBInterstitialListener listener = POBInterstitialListener();
      POBVideoListener videoListener = POBVideoListener(
        onVideoPlaybackCompleted: (ad) {},
      );

      interstitial.listener = listener;
      interstitial.videoListener = videoListener;

      await interstitial.destroy();

      // After destroy, callbacks should not crash (listeners are cleared internally)
      expect(() => interstitial.onAdCallBack(MethodCall('onAdReceived', null)),
          returnsNormally);
      expect(
          () => interstitial
              .onAdCallBack(MethodCall('onVideoPlaybackCompleted', null)),
          returnsNormally);
    });
  });
}

class OpenWrapDummyEventHandler implements POBInterstitialEvent {
  late POBInterstitialEventListener listener;
  @override
  POBAdServerAdEvent get destroy => () {
        log('destroy');
      };

  @override
  POBEventRequestAd get requestAd =>
      ({Map<String, String>? openWrapTargeting}) {
        testData = openWrapTargeting;
        log(openWrapTargeting?.toString() ?? 'No Targeting');
      };

  @override
  POBEventListener<POBInterstitialEventListener>
      get setInterstitialEventListener =>
          (POBInterstitialEventListener listener) {
            this.listener = listener;
            log(listener.toString());
          };

  @override
  get show => () {
        Future(() => log('completed'));
      };
}
