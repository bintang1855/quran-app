import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/surah.dart';
import '../models/juz.dart';
import '../models/detailsurah.dart';

class QuranCacheService extends GetxService {
  final GetStorage _storage = GetStorage();

  static const String _allSurahKey = 'cached_all_surah';
  static const String _allJuzKey = 'cached_all_juz';
  static const String _detailSurahPrefix = 'cached_detail_surah_';
  static const String _lastUpdateKey = 'cache_last_update';

  static const int _cacheDurationDays = 7;

  List<Surah>? _allSurahMemory;
  List<Juz>? _allJuzMemory;
  final Map<String, Detailsurah> _detailSurahMemory = {};

  @override
  void onInit() {
    super.onInit();
    _checkAndClearOldCache();
  }

  void _checkAndClearOldCache() {
    final lastUpdate = _storage.read<int>(_lastUpdateKey);
    if (lastUpdate != null) {
      final cacheDate = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();
      final difference = now.difference(cacheDate).inDays;

      if (difference > _cacheDurationDays) {
        clearAllCache();
      }
    }
  }

  Future<List<Surah>> getAllSurah() async {
    if (_allSurahMemory != null && _allSurahMemory!.isNotEmpty) {
      print('✅ Surah loaded from memory cache');
      return _allSurahMemory!;
    }

    try {
      final cachedData = _storage.read(_allSurahKey);
      if (cachedData != null && cachedData is List && cachedData.isNotEmpty) {
        print('✅ Surah loaded from disk cache (${cachedData.length} items)');
        _allSurahMemory = cachedData
            .map((e) => Surah.fromJson(e as Map<String, dynamic>))
            .toList();
        return _allSurahMemory!;
      }
    } catch (e) {
      print('⚠️ Error reading surah cache: $e');
    }

    try {
      print('🌐 Fetching surah from API...');
      Uri url = Uri.parse("https://quran-api-chi.vercel.app/surah");
      var res = await http.get(url);

      if (res.statusCode == 200) {
        List data = (json.decode(res.body) as Map<String, dynamic>)["data"];

        if (data.isNotEmpty) {
          _allSurahMemory = data.map((e) => Surah.fromJson(e)).toList();

          await _storage.write(_allSurahKey, data);
          await _storage.write(
            _lastUpdateKey,
            DateTime.now().millisecondsSinceEpoch,
          );

          print('✅ Surah fetched and cached (${data.length} items)');
          return _allSurahMemory!;
        }
      }
    } catch (e) {
      print('❌ Error fetching surah from API: $e');
    }

    return [];
  }

  Future<List<Juz>> getAllJuz() async {
    if (_allJuzMemory != null && _allJuzMemory!.isNotEmpty) {
      print('✅ Juz loaded from memory cache');
      return _allJuzMemory!;
    }

    try {
      final cachedData = _storage.read(_allJuzKey);
      if (cachedData != null && cachedData is List && cachedData.isNotEmpty) {
        print('✅ Juz loaded from disk cache (${cachedData.length} items)');
        _allJuzMemory = cachedData
            .map((e) => Juz.fromJson(e as Map<String, dynamic>))
            .toList();
        return _allJuzMemory!;
      }
    } catch (e) {
      print('⚠️ Error reading juz cache: $e');
    }

    try {
      print('🌐 Fetching juz from API...');
      List<Juz> allJuz = [];
      List<Map<String, dynamic>> juzDataList = [];

      for (int i = 1; i <= 30; i++) {
        Uri url = Uri.parse("https://quran-api-chi.vercel.app/juz/$i");
        var res = await http.get(url);

        if (res.statusCode == 200) {
          Map<String, dynamic> data =
              (json.decode(res.body) as Map<String, dynamic>)["data"];

          Juz juz = Juz.fromJson(data);
          allJuz.add(juz);
          juzDataList.add(data);
        }
      }

      if (allJuz.isNotEmpty) {
        _allJuzMemory = allJuz;

        await _storage.write(_allJuzKey, juzDataList);
        await _storage.write(
          _lastUpdateKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        print('✅ Juz fetched and cached (${allJuz.length} items)');
        return _allJuzMemory!;
      }
    } catch (e) {
      print('❌ Error fetching juz from API: $e');
    }

    return [];
  }

  Future<Detailsurah?> getDetailSurah(String surahNumber) async {
    if (_detailSurahMemory.containsKey(surahNumber)) {
      print('✅ Detail Surah $surahNumber loaded from memory cache');
      return _detailSurahMemory[surahNumber];
    }

    try {
      final cacheKey = '$_detailSurahPrefix$surahNumber';
      final cachedData = _storage.read(cacheKey);
      if (cachedData != null && cachedData is Map) {
        print('✅ Detail Surah $surahNumber loaded from disk cache');
        final detailSurah = Detailsurah.fromJson(
          cachedData as Map<String, dynamic>,
        );
        _detailSurahMemory[surahNumber] = detailSurah;
        return detailSurah;
      }
    } catch (e) {
      print('⚠️ Error reading detail surah cache: $e');
    }

    try {
      print('🌐 Fetching detail surah $surahNumber from API...');
      Uri url = Uri.parse(
        "https://quran-api-chi.vercel.app/surah/$surahNumber",
      );
      var res = await http.get(url);

      if (res.statusCode == 200) {
        Map<String, dynamic> data =
            (json.decode(res.body) as Map<String, dynamic>)["data"];

        if (data.isNotEmpty) {
          final detailSurah = Detailsurah.fromJson(data);

          _detailSurahMemory[surahNumber] = detailSurah;
          await _storage.write('$_detailSurahPrefix$surahNumber', data);
          await _storage.write(
            _lastUpdateKey,
            DateTime.now().millisecondsSinceEpoch,
          );

          print('✅ Detail Surah $surahNumber fetched and cached');
          return detailSurah;
        }
      }
    } catch (e) {
      print('❌ Error fetching detail surah from API: $e');
    }

    return null;
  }

  void clearAllCache() {
    _allSurahMemory = null;
    _allJuzMemory = null;
    _detailSurahMemory.clear();

    _storage.remove(_allSurahKey);
    _storage.remove(_allJuzKey);
    _storage.remove(_lastUpdateKey);

    final keys = _storage.getKeys();
    for (var key in keys) {
      if (key.startsWith(_detailSurahPrefix)) {
        _storage.remove(key);
      }
    }
  }

  void clearSurahCache() {
    _allSurahMemory = null;
    _storage.remove(_allSurahKey);
  }

  void clearJuzCache() {
    _allJuzMemory = null;
    _storage.remove(_allJuzKey);
  }

  void clearDetailSurahCache(String surahNumber) {
    _detailSurahMemory.remove(surahNumber);
    _storage.remove('$_detailSurahPrefix$surahNumber');
  }
}
