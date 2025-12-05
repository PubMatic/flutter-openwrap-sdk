import 'package:flutter_openwrap_sdk/src/pob_ad_instance_manager.dart';
import 'package:flutter_openwrap_sdk/src/pob_ad.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock POBAd class for testing
class MockPOBAd extends POBAd {
  final String mockName;

  MockPOBAd(this.mockName)
      : super(
          pubId: 'testPubId',
          adUnitId: 'testAdUnitId',
          profileId: 123,
          tag: 'MockPOBAd',
        );

  @override
  void onAdCallBack(call) {
    // Mock implementation
  }
}

void main() {
  late POBAdInstanceManager manager;
  late MockPOBAd mockAd1;
  late MockPOBAd mockAd2;

  setUpAll(() {
    manager = POBAdInstanceManager.instance;
  });

  setUp(() {
    // Clear the map before each test to ensure clean state
    manager.adMap.clear();
    mockAd1 = MockPOBAd('ad1');
    mockAd2 = MockPOBAd('ad2');
  });

  tearDown(() {
    // Clean up after each test
    manager.adMap.clear();
  });

  group('Singleton Pattern', () {
    test('should return the same instance every time', () {
      POBAdInstanceManager instance1 = POBAdInstanceManager.instance;
      POBAdInstanceManager instance2 = POBAdInstanceManager.instance;

      expect(instance1, same(instance2));
      expect(instance1, same(manager));
    });

    test('should maintain state across multiple access calls', () {
      manager.addToMap(1, mockAd1);

      POBAdInstanceManager anotherReference = POBAdInstanceManager.instance;
      POBAd? retrievedAd = anotherReference.getValueFromMap(1);

      expect(retrievedAd, same(mockAd1));
    });
  });

  group('loadAd method', () {
    test('should add ad to map and return incremented index', () {
      int index1 = manager.loadAd(mockAd1);
      int index2 = manager.loadAd(mockAd2);

      expect(index2, index1 + 1); // Should increment by 1
      expect(manager.adMap[index1], same(mockAd1));
      expect(manager.adMap[index2], same(mockAd2));
    });

    test('should increment index for each new ad', () {
      int index1 = manager.loadAd(mockAd1);
      int index2 = manager.loadAd(mockAd2);
      MockPOBAd mockAd3 = MockPOBAd('ad3');
      int index3 = manager.loadAd(mockAd3);

      expect(index2, index1 + 1);
      expect(index3, index2 + 1);
      expect(manager.adMap.length, 3);
    });

    test('should handle multiple ads correctly', () {
      List<MockPOBAd> ads = [];
      List<int> indices = [];

      for (int i = 0; i < 5; i++) {
        MockPOBAd ad = MockPOBAd('ad$i');
        ads.add(ad);
        int index = manager.loadAd(ad);
        indices.add(index);
      }

      // Verify indices are sequential
      for (int i = 1; i < indices.length; i++) {
        expect(indices[i], indices[i - 1] + 1);
      }

      expect(manager.adMap.length, 5);

      for (int i = 0; i < 5; i++) {
        expect(manager.adMap[indices[i]], same(ads[i]));
      }
    });
  });

  group('addToMap method', () {
    test('should add ad with specified key', () {
      manager.addToMap(100, mockAd1);

      expect(manager.adMap[100], same(mockAd1));
      expect(manager.adMap.length, 1);
    });

    test('should overwrite existing key', () {
      manager.addToMap(50, mockAd1);
      manager.addToMap(50, mockAd2);

      expect(manager.adMap[50], same(mockAd2));
      expect(manager.adMap.length, 1);
    });

    test('should handle multiple keys', () {
      manager.addToMap(10, mockAd1);
      manager.addToMap(20, mockAd2);

      expect(manager.adMap[10], same(mockAd1));
      expect(manager.adMap[20], same(mockAd2));
      expect(manager.adMap.length, 2);
    });

    test('should handle negative keys', () {
      manager.addToMap(-1, mockAd1);

      expect(manager.adMap[-1], same(mockAd1));
      expect(manager.adMap.length, 1);
    });
  });

  group('getValueFromMap method', () {
    test('should return ad for existing key', () {
      manager.addToMap(42, mockAd1);

      POBAd? retrievedAd = manager.getValueFromMap(42);

      expect(retrievedAd, same(mockAd1));
    });

    test('should return null for non-existing key', () {
      POBAd? retrievedAd = manager.getValueFromMap(999);

      expect(retrievedAd, isNull);
    });

    test('should return null for empty map', () {
      expect(manager.adMap.isEmpty, isTrue);

      POBAd? retrievedAd = manager.getValueFromMap(1);

      expect(retrievedAd, isNull);
    });

    test('should handle multiple retrievals', () {
      manager.addToMap(1, mockAd1);
      manager.addToMap(2, mockAd2);

      POBAd? ad1 = manager.getValueFromMap(1);
      POBAd? ad2 = manager.getValueFromMap(2);
      POBAd? ad3 = manager.getValueFromMap(3);

      expect(ad1, same(mockAd1));
      expect(ad2, same(mockAd2));
      expect(ad3, isNull);
    });

    test('should handle negative keys', () {
      manager.addToMap(-5, mockAd1);

      POBAd? retrievedAd = manager.getValueFromMap(-5);

      expect(retrievedAd, same(mockAd1));
    });
  });

  group('unregister method', () {
    test('should remove ad with existing key', () {
      manager.addToMap(30, mockAd1);
      expect(manager.adMap[30], same(mockAd1));

      manager.unregister(30);

      expect(manager.adMap.containsKey(30), isFalse);
      expect(manager.adMap.length, 0);
    });

    test('should handle non-existing key gracefully', () {
      manager.addToMap(10, mockAd1);
      expect(manager.adMap.length, 1);

      manager.unregister(999); // Non-existing key

      expect(manager.adMap.length, 1); // Should remain unchanged
      expect(manager.adMap[10], same(mockAd1));
    });

    test('should handle empty map', () {
      expect(manager.adMap.isEmpty, isTrue);

      expect(() => manager.unregister(1), returnsNormally);

      expect(manager.adMap.isEmpty, isTrue);
    });

    test('should remove specific ad without affecting others', () {
      manager.addToMap(1, mockAd1);
      manager.addToMap(2, mockAd2);
      expect(manager.adMap.length, 2);

      manager.unregister(1);

      expect(manager.adMap.containsKey(1), isFalse);
      expect(manager.adMap[2], same(mockAd2));
      expect(manager.adMap.length, 1);
    });

    test('should handle negative keys', () {
      manager.addToMap(-10, mockAd1);

      manager.unregister(-10);

      expect(manager.adMap.containsKey(-10), isFalse);
    });
  });

  group('adMap direct access', () {
    test('should allow direct access to internal map', () {
      expect(manager.adMap, isA<Map<int, POBAd>>());
      expect(manager.adMap.isEmpty, isTrue);
    });

    test('should reflect changes made through direct access', () {
      manager.adMap[100] = mockAd1;

      POBAd? retrievedAd = manager.getValueFromMap(100);

      expect(retrievedAd, same(mockAd1));
    });

    test('should allow clearing the map directly', () {
      manager.addToMap(1, mockAd1);
      manager.addToMap(2, mockAd2);
      expect(manager.adMap.length, 2);

      manager.adMap.clear();

      expect(manager.adMap.isEmpty, isTrue);
      expect(manager.getValueFromMap(1), isNull);
      expect(manager.getValueFromMap(2), isNull);
    });
  });

  group('Integration tests', () {
    test('should work correctly with loadAd and unregister combination', () {
      int index1 = manager.loadAd(mockAd1);
      int index2 = manager.loadAd(mockAd2);

      expect(manager.adMap.length, 2);

      manager.unregister(index1);

      expect(manager.adMap.length, 1);
      expect(manager.getValueFromMap(index1), isNull);
      expect(manager.getValueFromMap(index2), same(mockAd2));
    });

    test('should maintain correct state after mixed operations', () {
      // Load ads
      int index1 = manager.loadAd(mockAd1);
      manager.addToMap(50, mockAd2);

      // Verify state
      expect(manager.adMap.length, 2);
      expect(manager.getValueFromMap(index1), same(mockAd1));
      expect(manager.getValueFromMap(50), same(mockAd2));

      // Remove one ad
      manager.unregister(index1);

      // Verify final state
      expect(manager.adMap.length, 1);
      expect(manager.getValueFromMap(index1), isNull);
      expect(manager.getValueFromMap(50), same(mockAd2));
    });

    test('should handle index continuation behavior', () {
      // Load some ads and record their indices
      int index1 = manager.loadAd(mockAd1);
      int index2 = manager.loadAd(mockAd2);

      // Verify sequential indices
      expect(index2, index1 + 1);

      // Clear the map but keep the manager instance
      manager.adMap.clear();

      // Load new ad - index should continue incrementing (singleton behavior)
      MockPOBAd mockAd3 = MockPOBAd('ad3');
      int newIndex = manager.loadAd(mockAd3);

      // The index continues from where it left off (singleton behavior)
      expect(newIndex, greaterThan(index2));
      expect(manager.adMap.length, 1);
      expect(manager.getValueFromMap(newIndex), same(mockAd3));
    });

    test('should handle edge case operations', () {
      // Test with zero key
      manager.addToMap(0, mockAd1);
      expect(manager.getValueFromMap(0), same(mockAd1));

      // Test unregister with zero key
      manager.unregister(0);
      expect(manager.getValueFromMap(0), isNull);

      // Test large positive key
      manager.addToMap(999999, mockAd2);
      expect(manager.getValueFromMap(999999), same(mockAd2));
    });
  });
}
