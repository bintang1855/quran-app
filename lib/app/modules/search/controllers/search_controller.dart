import 'package:get/get.dart';
import 'package:quranapp/app/data/models/surah.dart';
import 'package:quranapp/app/data/models/juz.dart' as juz;
import 'package:quranapp/app/modules/home/controllers/home_controller.dart';

class SearchControllerApp extends GetxController {
  List<Surah> allSurahList = [];
  List<juz.Juz> allJuzList = [];

  RxList<Surah> searchSurahResults = <Surah>[].obs;
  RxList<juz.Juz> searchJuzResults = <juz.Juz>[].obs;

  RxInt currentTab = 0.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    if (Get.arguments != null) {
      allSurahList = Get.arguments['surah'] ?? [];
      allJuzList = Get.arguments['juz'] ?? [];
    }

    if (allSurahList.isEmpty || allJuzList.isEmpty) {
      final homeController = Get.find<HomeController>();

      if (allSurahList.isEmpty) {
        allSurahList = await homeController.getAllSurah();
      }

      if (allJuzList.isEmpty) {
        allJuzList = await homeController.getAllJuz();
      }
    }

    searchSurahResults.value = allSurahList;
    searchJuzResults.value = allJuzList;

    isLoading.value = false;
  }

  void searchSurah(String query) {
    if (query.isEmpty) {
      searchSurahResults.value = allSurahList;
    } else {
      searchSurahResults.value = allSurahList.where((surah) {
        final numberMatch = surah.number.toString().contains(query);

        final nameMatch =
            surah.name?.transliteration?.id?.toLowerCase().contains(
              query.toLowerCase(),
            ) ??
            false;

        final translationMatch =
            surah.name?.translation?.id?.toLowerCase().contains(
              query.toLowerCase(),
            ) ??
            false;

        final arabMatch = surah.name?.short?.contains(query) ?? false;

        return numberMatch || nameMatch || translationMatch || arabMatch;
      }).toList();
    }
  }

  void searchJuz(String query) {
    if (query.isEmpty) {
      searchJuzResults.value = allJuzList;
    } else {
      searchJuzResults.value = allJuzList.where((juzItem) {
        final juzNumberMatch = juzItem.juz.toString().contains(query);

        final startInfoMatch =
            juzItem.juzStartInfo?.toLowerCase().contains(query.toLowerCase()) ??
            false;

        final endInfoMatch =
            juzItem.juzEndInfo?.toLowerCase().contains(query.toLowerCase()) ??
            false;

        return juzNumberMatch || startInfoMatch || endInfoMatch;
      }).toList();
    }
  }

  void changeTab(int index) {
    currentTab.value = index;
  }
}
