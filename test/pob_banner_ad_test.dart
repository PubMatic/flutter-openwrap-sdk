// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/services.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

dynamic testData;
void main() {
  late String methodCallName;

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
      request.enableReturnAllBidStatus = false;
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
      expect(testData['enableReturnAllBidStatus'],
          request.enableReturnAllBidStatus);
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
  });
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
