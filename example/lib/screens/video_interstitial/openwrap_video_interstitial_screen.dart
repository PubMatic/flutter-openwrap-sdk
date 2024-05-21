import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:toast/toast.dart';

import '../../helper/constants.dart';

class OpenWrapVideoInterstitialScreen extends StatefulWidget {
  const OpenWrapVideoInterstitialScreen({Key? key}) : super(key: key);

  @override
  State<OpenWrapVideoInterstitialScreen> createState() =>
      _OpenWrapVideoInterstitialScreen();
}

class _OpenWrapVideoInterstitialScreen
    extends State<OpenWrapVideoInterstitialScreen> {
  POBInterstitial? _interstitial;

  @override
  void initState() {
    super.initState();
    POBApplicationInfo applicationInfo = POBApplicationInfo();

    if (Platform.isAndroid) {
      // A valid Play Store Url of an Android application is required.
      applicationInfo.storeURL = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example.android&hl=en');
    } else if (Platform.isIOS) {
      // Set a valid App Store URL, containing the app id of your iOS app
      applicationInfo.storeURL = Uri.parse(
          'https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8');
    }

    /// This app information is a global configuration & you
    /// Need not set this for every ad request(of any ad type)
    OpenWrapSDK.setApplicationInfo(applicationInfo);

    /// Initialise interstitial ad
    /// For test IDs refer - https://help.pubmatic.com/openwrap/docs/test-and-debug-your-integration-5#test-profileplacements
    _interstitial = POBInterstitial(
      pubId: pubId,
      profileId: videoProfileId,
      adUnitId: owInterstitialAdUnitId,
    );

    /// Optional listener to listen interstitial events
    _interstitial?.listener = _InterstitialListener();

    ///optional listener to listen interstitial video events
    _interstitial?.videoListener = _InterstitialVideoListener();
  }

  void loadAd() {
    /// Call loadAd() on interstitial instance
    _interstitial?.loadAd();
  }

  void showAd() async {
    /// Check if interstitial as is ready before calling showAd()
    bool isReady = await _interstitial?.isReady() ?? false;
    if (isReady) {
      _interstitial?.showAd();
    } else {
      Toast.show('Ad is not Ready', duration: 2, gravity: Toast.center);
    }
  }

  @override
  void dispose() {
    /// Destroy interstitial before destroying screen
    _interstitial?.destroy();
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
        title: const Text('Interstitial Video'),
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

/// Implementation of POBVideoListener
class _InterstitialVideoListener implements POBVideoListener {
  final String _tag = 'POBVideoListener';

  /// Callback method notifies that playback of the VAST video has been completed
  @override
  POBAdEvent<POBInterstitial> get onVideoPlaybackCompleted =>
      (POBInterstitial ad) => developer.log('$_tag - onVideoPlaybackCompleted');
}

/// Implementation of POBInterstitialListener
class _InterstitialListener implements POBInterstitialListener {
  final String _tag = 'POBInterstitialListener';

  /// Callback method Notifies that an ad has been received successfully.
  @override
  POBAdEvent<POBInterstitial>? get onAdReceived => (POBInterstitial ad) {
        Toast.show('Interstitial Ad Received',
            duration: 2, gravity: Toast.center);
        developer.log('$_tag: onAdReceived');
      };

  /// Callback method notifies an error encountered while loading an ad.
  @override
  POBAdFailed<POBInterstitial>? get onAdFailedToLoad =>
      (POBInterstitial ad, POBError error) => developer.log(
          '$_tag: onAdFailedToLoad : Ad failed to load with error -$error');

  /// Callback method notifies an error encountered while showing an ad.
  @override
  POBAdFailed<POBInterstitial>? get onAdFailedToShow =>
      (POBInterstitial ad, POBError error) => developer.log(
          '$_tag: onAdFailedToShow : Ad failed to show with error -$error');

  /// Callback method notifies that the interstitial ad will be presented as a modal on top of the current view controller
  @override
  POBAdEvent<POBInterstitial>? get onAdOpened =>
      (POBInterstitial ad) => developer.log('$_tag: onAdOpened');

  /// Callback method notifies that the interstitial ad has been animated off the screen.
  @override
  POBAdEvent<POBInterstitial>? get onAdClosed =>
      (POBInterstitial ad) => developer.log('$_tag: onAdClosed');

  /// Callback method Notifies whenever current app goes in the background due to user click
  @override
  POBAdEvent<POBInterstitial>? get onAppLeaving =>
      (POBInterstitial ad) => developer.log('$_tag: onAppLeaving');

  /// Callback method notifies ad expiration
  @override
  POBAdEvent<POBInterstitial>? get onAdExpired =>
      (POBInterstitial ad) => developer.log('$_tag: onAdExpired');

  /// Callback method notifies ad click
  @override
  POBAdEvent<POBInterstitial>? get onAdClicked =>
      (POBInterstitial ad) => developer.log('$_tag: onAdClicked');

  /// Callback method notifies ad impression
  @override
  POBAdEvent<POBInterstitial>? get onAdImpression =>
      (POBInterstitial ad) => developer.log('$_tag: onAdImpression');
}
