import 'pob_ad.dart';

/// Class for managing the ad instances with unique integer id. Helps to redirect
/// callback and method channel calls to respective instances.
class POBAdInstanceManager {
  // Private constructor
  POBAdInstanceManager._();

  // Singleton instance
  static final POBAdInstanceManager _instance = POBAdInstanceManager._();

  // Getter to access the instance
  static POBAdInstanceManager get instance => _instance;

  // Map variable to store int keys and Object values
  final Map<int, POBAd> adMap = {};

  int _adIndex = 0;

  int loadAd(POBAd ad) {
    int index = _adIndex++;
    adMap[index] = ad;
    return index;
  }

  // Add a method to manipulate the map if needed
  void addToMap(int key, POBAd value) {
    adMap[key] = value;
  }

  // Add a method to retrieve a value from the map if needed
  POBAd? getValueFromMap(int key) {
    return adMap[key];
  }

  /// Remove ad instnace with key id from map.
  void unregister(int id) {
    adMap.remove(id);
  }
}
