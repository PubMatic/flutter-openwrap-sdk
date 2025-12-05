import 'package:flutter/services.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

dynamic testData;
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_openwrap_sdk'),
            (message) async {
      var names = message.method.split('#');
      if (names[0] == 'POBRewardedAd' || names[0] == 'initRewardedAd') {
        testData = message.arguments;
      }

      if (names[0] == 'initRewardedAd') {
        return null;
      }

      var methodName = message.method.split('#')[1];
      if (methodName == 'isReady') {
        return Future(() => true);
      }

      if (names[1] == 'getBid') {
        return Future(() => {
              'price': 3.0,
              'width': POBAdSize.bannerSize320x50.width,
              'height': POBAdSize.bannerSize320x50.height,
              'status': 1,
              'partnerName': 'pubmatic',
              'refreshInterval': 60,
              'rewardAmount': 50,
              'rewardCurrencyType': 'coins'
            });
      }
      return null;
    });
  });

  group('Rewarded ad Testing', () {
    POBRewardedAd rewardedAd;
    test('Public APIs Testing', () async {
      rewardedAd = POBRewardedAd(
          pubId: '156276', profileId: 1165, adUnitId: 'OpenWrapRewardedAdUnit');
      expect(testData['pubId'], "156276");
      expect(testData['profileId'], 1165);
      expect(testData['adUnitId'], "OpenWrapRewardedAdUnit");
      testData = null;

      rewardedAd.loadAd();
      expect(testData['adId'], rewardedAd.adId);
      testData = null;

      rewardedAd.showAd();
      expect(testData['adId'], rewardedAd.adId);
      testData = null;

      await rewardedAd.isReady();
      expect(testData['adId'], rewardedAd.adId);
      testData = null;

      POBBid bid = await rewardedAd.getBid();
      expect(bid.price, 3);
      expect(bid.height, POBAdSize.bannerSize320x50.height);
      expect(bid.width, POBAdSize.bannerSize320x50.width);
      expect(bid.status, 1);
      expect(bid.partnerName, 'pubmatic');
      expect(bid.refreshInterval, 60);
      expect(bid.rewardAmount, 50);
      expect(bid.rewardCurrencyType, 'coins');

      rewardedAd.destroy();
      expect(testData['adId'], rewardedAd.adId);
      testData = null;
    });

    test('setSkipAlertDialogInfo method', () {
      rewardedAd = POBRewardedAd(
          pubId: '156276', profileId: 1165, adUnitId: 'OpenWrapRewardedAdUnit');
      testData = null;

      rewardedAd.setSkipAlertDialogInfo(
          'Skip Alert', 'Are you sure?', 'Resume', 'Close');

      expect(testData['adId'], rewardedAd.adId);
      expect(testData['title'], 'Skip Alert');
      expect(testData['message'], 'Are you sure?');
      expect(testData['resumeTitle'], 'Resume');
      expect(testData['closeTitle'], 'Close');
      testData = null;
    });

    test('listener setter', () {
      rewardedAd = POBRewardedAd(
          pubId: '156276', profileId: 1165, adUnitId: 'OpenWrapRewardedAdUnit');
      testData = null;

      POBRewardedAdListener listener = POBRewardedAdListener();
      rewardedAd.listener = listener;

      expect(testData['adId'], rewardedAd.adId);
      testData = null;
    });

    test('onAdCallBack method - all callback cases', () {
      rewardedAd = POBRewardedAd(
          pubId: '156276', profileId: 1165, adUnitId: 'OpenWrapRewardedAdUnit');

      bool onAdReceivedCalled = false;
      bool onAppLeavingCalled = false;
      bool onAdOpenedCalled = false;
      bool onAdClosedCalled = false;
      bool onAdClickedCalled = false;
      bool onAdImpressionCalled = false;
      bool onAdFailedToLoadCalled = false;
      bool onAdFailedToShowCalled = false;
      bool onAdExpiredCalled = false;
      bool onReceiveRewardCalled = false;
      POBError? receivedError;
      POBReward? receivedReward;

      rewardedAd.listener = POBRewardedAdListener(
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
        onReceiveReward: (ad, reward) {
          onReceiveRewardCalled = true;
          receivedReward = reward;
        },
      );

      // Test onAdReceived callback
      rewardedAd.onAdCallBack(MethodCall('onAdReceived', null));
      expect(onAdReceivedCalled, isTrue);

      // Test onAppLeaving callback
      rewardedAd.onAdCallBack(MethodCall('onAppLeaving', null));
      expect(onAppLeavingCalled, isTrue);

      // Test onAdOpened callback
      rewardedAd.onAdCallBack(MethodCall('onAdOpened', null));
      expect(onAdOpenedCalled, isTrue);

      // Test onAdClosed callback
      rewardedAd.onAdCallBack(MethodCall('onAdClosed', null));
      expect(onAdClosedCalled, isTrue);

      // Test onAdClicked callback
      rewardedAd.onAdCallBack(MethodCall('onAdClicked', null));
      expect(onAdClickedCalled, isTrue);

      // Test onAdImpression callback
      rewardedAd.onAdCallBack(MethodCall('onAdImpression', null));
      expect(onAdImpressionCalled, isTrue);

      // Test onAdFailedToLoad callback
      Map<String, dynamic> errorData = {
        'errorCode': 1001,
        'errorMessage': 'Load failed'
      };
      rewardedAd.onAdCallBack(MethodCall('onAdFailedToLoad', errorData));
      expect(onAdFailedToLoadCalled, isTrue);
      expect(receivedError?.errorCode, 1001);
      expect(receivedError?.errorMessage, 'Load failed');

      // Test onAdFailedToShow callback
      Map<String, dynamic> showErrorData = {
        'errorCode': 2001,
        'errorMessage': 'Show failed'
      };
      rewardedAd.onAdCallBack(MethodCall('onAdFailedToShow', showErrorData));
      expect(onAdFailedToShowCalled, isTrue);
      expect(receivedError?.errorCode, 2001);
      expect(receivedError?.errorMessage, 'Show failed');

      // Test onAdExpired callback
      rewardedAd.onAdCallBack(MethodCall('onAdExpired', null));
      expect(onAdExpiredCalled, isTrue);

      // Test onReceiveReward callback
      Map<String, dynamic> rewardData = {
        'currencyType': 'coins',
        'amount': 100
      };
      rewardedAd.onAdCallBack(MethodCall('onReceiveReward', rewardData));
      expect(onReceiveRewardCalled, isTrue);
      expect(receivedReward?.currencyType, 'coins');
      expect(receivedReward?.amount, 100);
    });

    test('POBRewardedAdListener constructor', () {
      // Test with all callbacks
      POBRewardedAdListener listener1 = POBRewardedAdListener(
        onAdReceived: (ad) {},
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
        onAdClicked: (ad) {},
        onAppLeaving: (ad) {},
        onAdImpression: (ad) {},
        onAdFailedToLoad: (ad, error) {},
        onAdFailedToShow: (ad, error) {},
        onAdExpired: (ad) {},
        onReceiveReward: (ad, reward) {},
      );
      expect(listener1, isNotNull);
      expect(listener1.onAdReceived, isNotNull);
      expect(listener1.onAdFailedToLoad, isNotNull);
      expect(listener1.onAdFailedToShow, isNotNull);
      expect(listener1.onAdExpired, isNotNull);
      expect(listener1.onReceiveReward, isNotNull);

      // Test with minimal callbacks (null values)
      POBRewardedAdListener listener2 = POBRewardedAdListener();
      expect(listener2, isNotNull);
      expect(listener2.onAdReceived, isNull);
      expect(listener2.onAdFailedToLoad, isNull);
      expect(listener2.onAdFailedToShow, isNull);
      expect(listener2.onAdExpired, isNull);
      expect(listener2.onReceiveReward, isNull);
    });

    test('onAdCallBack with null listener', () {
      rewardedAd = POBRewardedAd(
          pubId: '156276', profileId: 1165, adUnitId: 'OpenWrapRewardedAdUnit');

      // Test that callbacks don't crash when listener is null
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdReceived', null)),
          returnsNormally);
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAppLeaving', null)),
          returnsNormally);
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdOpened', null)),
          returnsNormally);
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdClosed', null)),
          returnsNormally);
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdClicked', null)),
          returnsNormally);
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdImpression', null)),
          returnsNormally);
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdExpired', null)),
          returnsNormally);
    });

    test('destroy method clears listener', () async {
      rewardedAd = POBRewardedAd(
          pubId: '156276', profileId: 1165, adUnitId: 'OpenWrapRewardedAdUnit');

      POBRewardedAdListener listener = POBRewardedAdListener();
      rewardedAd.listener = listener;

      await rewardedAd.destroy();

      // After destroy, callbacks should not crash (listener is cleared internally)
      expect(() => rewardedAd.onAdCallBack(MethodCall('onAdReceived', null)),
          returnsNormally);
    });
  });
}
