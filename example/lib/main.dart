import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_openwrap_sdk/flutter_openwrap_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

import './helper/constants.dart';
import 'screens/screens.dart';

const String _tag = "MainScreen";

void main() {
  runApp(const MainScreen());
}

const List<String> adType = [
  'Banner',
  'MREC Display',
  'Interstitial Display',
  'Interstitial Video',
  'Rewarded'
];

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    _initializeOpenWrapSDK();
    OpenWrapSDK.setLogLevel(POBLogLevel.all);
    OpenWrapSDK.setDSAComplianceStatus(POBDSAComplianceStatus.required);
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    const permission = Permission.location;
    await permission.request();
  }

  void _initializeOpenWrapSDK() {
    // Invoke the initialize method to warm up the OpenWrap SDK.
    OpenWrapSDK.initialize(
        config: const OpenWrapSDKConfig(pubId, [profileId, videoProfileId]),
        listener: OpenWrapSDKListener(
          onOpenWrapSDKInitialize: () =>
              developer.log('$_tag: OpenWrap SDK initialization successful'),
          onOpenWrapSDKInitializeError: (error) => developer.log(
              '$_tag: OpenWrap SDK initialization failed with error : $error'),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PubMatic Flutter Sample App'),
        ),
        body: const MyListView(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyListView extends StatelessWidget {
  const MyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 12.0, 12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              for (var index in Iterable<int>.generate(adType.length))
                SubRow(index)
            ],
          ),
        ),
      ),
    );
  }
}

class SubRow extends StatelessWidget {
  final int adTypeIndex;
  const SubRow(this.adTypeIndex, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (adTypeIndex) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => const OpenWrapBannerScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => const OpenWrapMRECDisplayScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => const OpenWrapInterstitialScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) =>
                      const OpenWrapVideoInterstitialScreen()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => const OpenWrapRewardedAdScreen()),
            );
            break;
        }
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
          child: ExcludeSemantics(
            child: Text(
              adType[adTypeIndex],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        if (adTypeIndex + 1 != adType.length)
          Divider(
            thickness: 1.0,
            color: Colors.grey[300],
          )
      ]),
    );
  }
}
