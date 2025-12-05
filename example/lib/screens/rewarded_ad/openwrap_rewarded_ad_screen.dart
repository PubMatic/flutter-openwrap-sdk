import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:toast/toast.dart';

import '../../helper/constants.dart';

class OpenWrapRewardedAdScreen extends StatefulWidget {
  const OpenWrapRewardedAdScreen({Key? key}) : super(key: key);

  @override
  State<OpenWrapRewardedAdScreen> createState() => _OpenWrapRewardedAdScreen();
}

class _OpenWrapRewardedAdScreen extends State<OpenWrapRewardedAdScreen> {
  late POBRewardedAd _rewarded;

  @override
  void initState() {
    super.initState();
    final POBApplicationInfo applicationInfo = POBApplicationInfo();

    if (Platform.isAndroid) {
      // A valid Play Store Url of an Android application is required.
      applicationInfo.storeURL = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example.android&hl=en');
    } else if (Platform.isIOS) {
      // Set a valid App Store URL, containing the app id of your iOS app.
      applicationInfo.storeURL = Uri.parse(
          'https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8');
    }

    // This app information is a global configuration & you need not set this for
    // every ad request(of any ad type).
    OpenWrapSDK.setApplicationInfo(applicationInfo);

    // Initialise rewardedAd.
    // For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-5#test-profileplacements
    _rewarded = POBRewardedAd(
      pubId: pubId,
      profileId: videoProfileId,
      adUnitId: owRewardedAdUnitId,
    );

    // Optional listener to listen rewardedAd events.
    _rewarded.listener = _RewardedAdListener();
  }

  void loadAd() {
    // Call loadAd method on rewardedAd instance.
    _rewarded.loadAd();
  }

  void showAd() async {
    // Check if rewardedAd is ready before calling showAd method.
    final bool? isReady = await _rewarded.isReady();
    if (isReady == true) {
      _rewarded.showAd();
    } else {
      Toast.show('Ad is not Ready', duration: 2, gravity: Toast.center);
    }
  }

  @override
  void dispose() {
    _rewarded.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text('Rewarded Ad'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 175,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                        minimumSize: const Size(90, 40),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: const Text(
                        'Load Ad',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        loadAd();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                        minimumSize: const Size(90, 40),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: const Text(
                        'Show Ad',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        showAd();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Implementation of POBRewardedListener.
class _RewardedAdListener implements POBRewardedAdListener {
  final String _tag = 'RewardedAdListener';

  /// Callback method Notifies that an ad has been received successfully.
  @override
  POBAdEvent<POBRewardedAd>? get onAdReceived => (POBRewardedAd ad) {
        Toast.show('Rewarded Ad Received', duration: 2, gravity: Toast.center);
        developer.log('$_tag: Rewarded Ad : Ad Received');
      };

  /// Callback method notifies an error encountered while loading an ad.
  @override
  POBAdFailed<POBRewardedAd>? get onAdFailedToLoad =>
      (POBRewardedAd ad, POBError error) =>
          developer.log('$_tag: Rewarded Ad : Ad failed with error - $error');

  /// Callback method notifies an error encountered while showing an ad.
  @override
  POBAdFailed<POBRewardedAd>? get onAdFailedToShow =>
      (POBRewardedAd ad, POBError error) =>
          developer.log('$_tag: Rewarded Ad: Ad failed with error $error');

  /// Callback method notifies that the rewarded ad will be presented as a modal on top of the current view controller
  @override
  POBAdEvent<POBRewardedAd>? get onAdOpened =>
      (POBRewardedAd ad) => developer.log('$_tag: Rewarded Ad : Ad Opened');

  /// Callback method notifies that the rewarded ad has been animated off the screen.
  @override
  POBAdEvent<POBRewardedAd>? get onAdClosed =>
      (POBRewardedAd ad) => developer.log('$_tag: Rewarded Ad : Ad Closed');

  /// Callback method Notifies whenever current app goes in the background due to user click
  @override
  POBAdEvent<POBRewardedAd>? get onAppLeaving =>
      (POBRewardedAd ad) => developer.log('$_tag: Rewarded Ad : App Leaving');

  /// Callback method notifies ad expiration
  @override
  POBAdEvent<POBRewardedAd>? get onAdExpired =>
      (POBRewardedAd ad) => developer.log('$_tag: Rewarded Ad : Ad Expired');

  /// Callback method notifies ad click
  @override
  POBAdEvent<POBRewardedAd>? get onAdClicked =>
      (POBRewardedAd ad) => developer.log('$_tag: Rewarded Ad : Ad Clicked');

  /// Callback method notifies rewarded ad reward received.
  @override
  POBAdEventReward<POBRewardedAd>? get onReceiveReward =>
      (POBRewardedAd ad, POBReward reward) => developer.log(
          '$_tag: Rewarded Ad : Ad should reward - ${reward.amount}(${reward.currencyType})');

  /// Callback method notifies that the rewarded ad impression occurred.
  @override
  POBAdEvent<POBRewardedAd>? get onAdImpression =>
      (POBRewardedAd ad) => developer.log('$_tag: Rewarded Ad : Ad Impression');
}
