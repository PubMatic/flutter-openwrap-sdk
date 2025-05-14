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
        ..enableReturnAllBidStatus = false
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
      expect(testData['enableReturnAllBidStatus'],
          request.enableReturnAllBidStatus);
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
