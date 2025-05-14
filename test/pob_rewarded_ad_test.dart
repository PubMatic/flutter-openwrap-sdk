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
  });
}
