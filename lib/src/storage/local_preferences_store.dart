class LocalPreferencesStore {
  const LocalPreferencesStore();

  // Persistent storage adapter point.
  // Wire SharedPreferences/Hive here when desired.
  Future<void> saveString(String key, String value) async {}
  Future<String?> readString(String key) async => null;
}
